// =====================================================================
// DOC 2 of 2 — GET THE DATA USING THE TOKEN
// Verified against doForms REST API OpenAPI v2.5.2
// ---------------------------------------------------------------------
// TOKEN: by default this pulls the token automatically from the query
// named "GetToken" (from 1_GetToken.pq), buffered so it runs ONCE per
// refresh. Set ManualToken to a pasted token to skip the login call
// entirely while developing. Tokens last 24 hours.
//
// CALL SEQUENCE (all GET, all Bearer-authorised):
//   1. GET api/v2/forms
//        -> [{ key, name, id, displayName, status, version, ... }]
//   2. GET api/v2/forms/{formKey}/projects
//        -> [{ key, name, ... }]              (need projectKey for step 3)
//   3. GET api/v2/submissions
//        ?projectKey=&formKey=&receiveTimeBegin=&receiveTimeEnd=&limit=&skip=
//        -> [{ key, id }]                     (IDENTIFIERS ONLY, paged)
//        receiveTimeBegin inclusive, receiveTimeEnd exclusive,
//        limit max 1000, page with skip
//   4. GET api/v2/forms/{formKey}/data/{recordKey}
//        -> full record; `data` holds the answers keyed by each
//           question's data name. Nested tables/repeats are arrays of
//           records. Blobs (signature/photo) are {key,id,fileName,type}.
//
// RATE LIMITS: these data endpoints allow 600 requests/minute per
// account, so step 4 (one call per submission) is fine. A GetJson
// helper below still retries with back-off if a 429 appears.
//
// USE: Blank Query > Advanced Editor > paste > set Region + Token > Done
//      > select the last step `Result` > Refresh Preview.
// =====================================================================
let
    // ================= SETTINGS =================
    Region         = "eu",     // "eu" = UK/Europe.  "" = USA.
    MonthsBack     = 6,        // rolling window, recomputed each refresh
    FormNameFilter = "",       // "" = every form; else comma-separated exact names

    // ---- TOKEN ----
    // Leave ManualToken = "" to pull the token AUTOMATICALLY from the
    // query named "GetToken" (created from 1_GetToken.pq). In M, another
    // query's name is just an identifier, so we can reference it directly.
    //
    // It is wrapped in List.Buffer so GetToken runs ONCE per refresh. A
    // plain reference would be re-evaluated for every single API call,
    // which would hammer the rate-limited login endpoint (HTTP 429).
    //
    // Paste a token into ManualToken to skip the login call entirely --
    // useful while developing, when you refresh many times.
    ManualToken    = "",

    // ================= CONSTANTS =================
    BaseUrl = if Region = "" then "https://api.mydoforms.com"
              else "https://api." & Region & ".mydoforms.com",

    // Fetch once per refresh, then reuse.
    TokenOnce = List.Buffer({ if ManualToken <> "" then ManualToken else GetToken }),
    RawToken  = TokenOnce{0},

    // GetToken returns a readable message instead of a token when the
    // login fails; surface that clearly rather than sending a junk header.
    Token =
        if RawToken = null then
            error Error.Record("doForms token error", "GetToken returned nothing.")
        else if Text.StartsWith(RawToken, "HTTP") or Text.StartsWith(RawToken, "MULTIPLE") then
            error Error.Record("doForms token error", RawToken)
        else
            RawToken,

    AuthHeader = [ Authorization = "Bearer " & Token, Accept = "application/json" ],

    // Rolling UTC window. ISO-8601 built by concatenation so no stray
    // format letters (T/Z) are passed to .NET formatting.
    NowUtc   = DateTimeZone.RemoveZone(DateTimeZone.UtcNow()),
    StartUtc = NowUtc - #duration(30 * MonthsBack, 0, 0, 0),
    FmtDate  = (dt) => Date.ToText(Date.From(dt), [Format="yyyy-MM-dd", Culture="en-US"]),
    FmtTime  = (dt) => Time.ToText(Time.From(dt), [Format="HH:mm:ss", Culture="en-US"]),
    FromDate = FmtDate(StartUtc) & "T00:00:00.000Z",                 // inclusive
    ToDate   = FmtDate(NowUtc) & "T" & FmtTime(NowUtc) & ".000Z",    // exclusive

    // ================= HTTP HELPER (429-aware) =================
    // Retries up to 4 times with increasing delay if the API throttles.
    GetJson = (relPath as text, optional qry as nullable record) =>
        let
            Attempt = (n as number) =>
                let
                    resp = Web.Contents(BaseUrl, [
                        RelativePath         = relPath,
                        Query                = if qry = null then [] else qry,
                        Headers              = AuthHeader,
                        ManualStatusHandling = {429, 500, 502, 503}
                    ]),
                    st = Value.Metadata(resp)[Response.Status],
                    out =
                        if st = 200 then
                            Json.Document(resp)
                        else if n < 4 then
                            // @ is REQUIRED: a let binding cannot call itself
                            // without the self-reference operator.
                            Function.InvokeAfter(() => @Attempt(n + 1), #duration(0, 0, 0, 10 * n))
                        else
                            error Error.Record(
                                "doForms API error",
                                "HTTP " & Text.From(st) & " on " & relPath,
                                Text.FromBinary(resp))
                in
                    out
        in
            Attempt(1),

    // ================= 1. FORMS =================
    FormsRaw    = GetJson("api/v2/forms"),
    FormsTable0 = Table.FromRecords(FormsRaw),
    FormsTable1 = Table.SelectColumns(FormsTable0, {"key","name","displayName"}, MissingField.UseNull),
    WantedNames = if FormNameFilter = "" then null
                  else List.Transform(Text.Split(FormNameFilter, ","), Text.Trim),
    FormsTable  = if WantedNames = null then FormsTable1
                  else Table.SelectRows(FormsTable1, each List.Contains(WantedNames, [name])),

    // ================= 2. PROJECT KEY PER FORM =================
    GetProjectKey = (formKey as text) as nullable text =>
        let projs = GetJson("api/v2/forms/" & formKey & "/projects")
        in  if List.Count(projs) > 0 then projs{0}[key] else null,

    // ================= 3. SUBMISSION KEYS IN WINDOW (paged) =================
    PageSize = 1000,   // API maximum
    GetSubmissionKeys = (projectKey as text, formKey as text) as list =>
        let
            // loop variable must NOT be named "skip" -- see the compiler-bug
            // note in 3_GetData_StaticToken.pq.
            FetchPage = (pageOffset as number) as list =>
                GetJson("api/v2/submissions", [
                    projectKey       = projectKey,
                    formKey          = formKey,
                    receiveTimeBegin = FromDate,
                    receiveTimeEnd   = ToDate,
                    limit            = Text.From(PageSize),
                    skip             = Text.From(pageOffset)
                ]),
            pages = List.Generate(
                () => [ pageItems = FetchPage(0), pageOffset = 0 ],
                each List.Count([pageItems]) > 0,
                each [ pageOffset = [pageOffset] + PageSize,
                       pageItems  = FetchPage([pageOffset] + PageSize) ],
                each [pageItems]
            )
        in
            List.Transform(List.Combine(pages), each _[key]),

    // ================= 4. FULL RECORD =================
    GetRecord = (formKey as text, recordKey as text) as record =>
        GetJson("api/v2/forms/" & formKey & "/data/" & recordKey),

    // ================= ORCHESTRATE =================
    WithProject  = Table.AddColumn(FormsTable, "projectKey", each try GetProjectKey([key]) otherwise null),
    OnlyProjects = Table.SelectRows(WithProject, each [projectKey] is text),
    WithKeys     = Table.AddColumn(OnlyProjects, "recordKeys",
                       each GetSubmissionKeys([projectKey], [key]), type list),
    OnlyLists    = Table.SelectRows(WithKeys, each [recordKeys] is list),
    ExpandedKeys = Table.ExpandListColumn(OnlyLists, "recordKeys"),
    OnlyWithKeys = Table.SelectRows(ExpandedKeys, each [recordKeys] is text),
    WithRecord   = Table.AddColumn(OnlyWithKeys, "Record",
                       each GetRecord([key], [recordKeys]), type record),

    Result = Table.ExpandRecordColumn(WithRecord, "Record",
        {"index","status","sourceName","sourceId","openTime","createTime",
         "receiveTime","statusTime","formName","formVersion","data"},
        {"index","status","sourceName","sourceId","openTime","createTime",
         "receiveTime","statusTime","recFormName","formVersion","data"})
    // NEXT: click the expand icon on `data` to surface each question's
    // answer. Nested repeat/table columns arrive as lists of records —
    // expand each into its own query keyed by the submission index/id
    // to build the star schema.
in
    Result
