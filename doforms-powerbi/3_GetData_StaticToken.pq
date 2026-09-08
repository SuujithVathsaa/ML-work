// =====================================================================
// doForms -> Power BI  using a STATIC WEB SERVICE TOKEN
// Verified against doForms REST API OpenAPI v2.5.2
// ---------------------------------------------------------------------
// NO LOGIN CALL. NO TOKEN EXPIRY. NO RATE-LIMIT PROBLEM.
//
// The spec's WebserviceTokenAuthentication scheme says:
//   "Alternative: Build a static token by combining a web service ID and
//    web service password separated by a colon."
//   e.g. ID  acmeinc$$1234$$Published$$5678
//        pwd mypassword
//        ->  Authorization: Bearer acmeinc$$1234$$Published$$5678:mypassword
//
// Because we never POST to /tokens/user:
//   * every request is a GET, which Power BI authorises normally
//     (choose Anonymous once) -- no more credential-dialog loop;
//   * the throttled login endpoint is never touched -- no more HTTP 429;
//   * the token never expires -- nothing to re-paste each day.
//
// SCOPE: a web service token is tied to ONE project + form, so create one
// web service per form and list them all in the WebServices table below.
//
// ---------------------------------------------------------------------
// SETUP IN THE doFORMS PORTAL (once)
//   Manage > Integrations > Web Services
//   For each of the 6 forms: enable a web service and note its
//   Web Service ID and Password.
//
// SETUP IN POWER BI
//   1. Blank Query > Advanced Editor > paste this > fill WebServices > Done
//   2. When prompted for api.eu.mydoforms.com choose ANONYMOUS, and set the
//      level to the ROOT https://api.eu.mydoforms.com/ > Connect.
//   3. Select the last step `Result` > Refresh Preview.
//
// CALLS (all GET, all 600 requests/minute):
//   GET api/v2/forms                                  -> the authorised form
//   GET api/v2/submissions?receiveTimeBegin&End&limit&skip
//        (projectKey/formKey NOT needed: web service auth already
//         identifies the project and form)             -> [{key,id}]
//   GET api/v2/forms/{formKey}/data/{recordKey}        -> full record
// =====================================================================
let
    // ================= SETTINGS =================
    Region     = "eu",     // "eu" = UK/Europe.  "" = USA.  also "ca","au","sa"
    MonthsBack = 6,        // rolling window, recomputed at every refresh

    // One row per form. Paste the Web Service ID and Password from
    // Manage > Integrations > Web Services. Label is yours, for the report.
    WebServices = #table(
        type table [Label = text, WsId = text, WsPassword = text],
        {
            { "H&S Inspection",                    "<<WSID>>", "<<PASSWORD>>" },
            { "Quality inspection",                "<<WSID>>", "<<PASSWORD>>" },
            { "Quality inspection - Preventative", "<<WSID>>", "<<PASSWORD>>" },
            { "Construction Inspection",           "<<WSID>>", "<<PASSWORD>>" },
            { "Winter Conformance Check",          "<<WSID>>", "<<PASSWORD>>" },
            { "Depot Inspection",                  "<<WSID>>", "<<PASSWORD>>" }
        }
    ),

    // ================= CONSTANTS =================
    BaseUrl = if Region = "" then "https://api.mydoforms.com"
              else "https://api." & Region & ".mydoforms.com",

    // THE STATIC TOKEN: "<web service id>:<web service password>"
    MakeAuth = (wsId as text, wsPassword as text) as record =>
        [ Authorization = "Bearer " & wsId & ":" & wsPassword,
          Accept        = "application/json" ],

    // Rolling UTC window, ISO-8601 built by concatenation.
    NowUtc   = DateTimeZone.RemoveZone(DateTimeZone.UtcNow()),
    StartUtc = NowUtc - #duration(30 * MonthsBack, 0, 0, 0),
    FmtDate  = (dt) => Date.ToText(Date.From(dt), [Format="yyyy-MM-dd", Culture="en-US"]),
    FmtTime  = (dt) => Time.ToText(Time.From(dt), [Format="HH:mm:ss", Culture="en-US"]),
    FromDate = FmtDate(StartUtc) & "T00:00:00.000Z",                 // inclusive
    ToDate   = FmtDate(NowUtc) & "T" & FmtTime(NowUtc) & ".000Z",    // exclusive

    // ================= HTTP HELPER =================
    // ManualStatusHandling takes 4xx/5xx only (Power Query rejects 3xx).
    // @Attempt is required: a let binding cannot call itself without @.
    GetJson = (auth as record, relPath as text, optional qry as nullable record) =>
        let
            Attempt = (n as number) =>
                let
                    resp = Web.Contents(BaseUrl, [
                        RelativePath         = relPath,
                        Query                = if qry = null then [] else qry,
                        Headers              = auth,
                        ManualStatusHandling = {400, 401, 403, 404, 429, 500, 502, 503}
                    ]),
                    st  = Value.Metadata(resp)[Response.Status],
                    out =
                        if st = 200 then
                            Json.Document(resp)
                        else if (st = 429 or st >= 500) and n < 4 then
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

    // ================= 1. THE FORM THIS TOKEN CAN SEE =================
    GetFormKey = (auth as record) as nullable text =>
        let forms = GetJson(auth, "api/v2/forms")
        in  if List.Count(forms) > 0 then forms{0}[key] else null,

    // ================= 2. SUBMISSION KEYS IN WINDOW (paged) =================
    PageSize = 1000,   // API maximum
    GetSubmissionKeys = (auth as record) as list =>
        let
            FetchPage = (skip as number) as list =>
                GetJson(auth, "api/v2/submissions", [
                    receiveTimeBegin = FromDate,
                    receiveTimeEnd   = ToDate,
                    limit            = Text.From(PageSize),
                    skip             = Text.From(skip)
                ]),
            pages = List.Generate(
                () => [items = FetchPage(0), skip = 0],
                each List.Count([items]) > 0,
                each [ skip = [skip] + PageSize, items = FetchPage([skip] + PageSize) ],
                each [items]
            )
        in
            List.Transform(List.Combine(pages), each _[key]),

    // ================= 3. FULL RECORD =================
    GetRecord = (auth as record, formKey as text, recordKey as text) as record =>
        GetJson(auth, "api/v2/forms/" & formKey & "/data/" & recordKey),

    // ================= ORCHESTRATE =================
    WithAuth    = Table.AddColumn(WebServices, "auth",
                      each MakeAuth([WsId], [WsPassword]), type record),
    WithFormKey = Table.AddColumn(WithAuth, "formKey", each GetFormKey([auth]), type text),
    OnlyForms   = Table.SelectRows(WithFormKey, each [formKey] <> null),
    WithKeys    = Table.AddColumn(OnlyForms, "recordKeys",
                      each GetSubmissionKeys([auth]), type list),
    Expanded    = Table.ExpandListColumn(WithKeys, "recordKeys"),
    OnlyKeys    = Table.SelectRows(Expanded, each [recordKeys] <> null),
    WithRecord  = Table.AddColumn(OnlyKeys, "Record",
                      each GetRecord([auth], [formKey], [recordKeys]), type record),

    // drop the secrets before they reach the model
    Trimmed = Table.RemoveColumns(WithRecord, {"WsId", "WsPassword", "auth"}),

    Result = Table.ExpandRecordColumn(Trimmed, "Record",
        {"index","status","sourceName","sourceId","openTime","createTime",
         "receiveTime","statusTime","formName","formVersion","data"},
        {"index","status","sourceName","sourceId","openTime","createTime",
         "receiveTime","statusTime","recFormName","formVersion","data"})
    // NEXT: expand `data` to surface each question's answer. Nested
    // repeat/table columns arrive as lists of records -- expand each into
    // its own query keyed by the submission index/id for the star schema.
in
    Result
