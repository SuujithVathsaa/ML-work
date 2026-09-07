// =====================================================================
// doForms REST API  ->  Power BI  |  Power Query (M)
// Spec: doForms REST API v2.5.2
// Scope: all forms in the account, rolling last-6-months window,
//        submissions fetched and appended into one table.
//
// HOW TO USE IN POWER BI DESKTOP
//   1. Home > Manage Parameters > New  ->  create the parameters in
//      section (0) below (Region, Username, Password, MonthsBack,
//      FormNameFilter). You can also hardcode them, but parameters are
//      cleaner and let scheduled refresh prompt for the password.
//   2. Home > Get Data > Blank Query > Advanced Editor.
//   3. Create the queries below. The simplest path: make ONE query named
//      "doForms" holding the whole script (functions defined inline in
//      the `let`). Splitting GetToken / GetForms / GetFormData into their
//      own queries also works and is easier to debug.
//   4. When prompted for credentials for api.<region>.mydoforms.com,
//      choose "Anonymous" (auth is carried by the bearer token we fetch;
//      do NOT put the password in the credential dialog).
//   5. Run. First run reveals the real field names -> expand `data`.
//
// SECURITY: the password lives only in a Power BI Parameter / the
//   credential store on your machine and in the service. It is never
//   written into this file or committed to git.
// =====================================================================


// =====================================================================
// (0) PARAMETERS  — create these via Manage Parameters (Text unless noted)
// ---------------------------------------------------------------------
//   Region          e.g. "eu"   (UK/EU). Others: "" (USA), "ca","au","sa"
//                   USA server has no region prefix -> leave Region = "".
//   Username        your doForms web-user email
//   Password        your doForms web-user password  (mark as sensitive)
//   Account         optional; only if your login exists in >1 account
//   MonthsBack      whole number, e.g. 6
//   FormNameFilter  optional; "" = all forms. Otherwise a comma list of
//                   exact published form names to include.
// =====================================================================

// ---- If NOT using real Parameters, set literals here for testing: ----
// (delete these once real Parameters exist, or they will shadow them)
let
Region         = "eu",
Username       = "REPLACE_OR_USE_PARAMETER",
Password       = "REPLACE_OR_USE_PARAMETER",
Account        = "",              // usually blank
// DEV SHORTCUT: paste a token here (from the GetToken helper) to SKIP the
// /tokens/user login call entirely. The token endpoint is heavily rate
// limited (HTTP 429), so during development fetch a token ONCE and paste it
// here. Tokens last 24h. Leave "" to have the query fetch one automatically.
ManualToken    = "",
MonthsBack     = 6,
FormNameFilter = "",              // "" = every form in the account


// =====================================================================
// (1) DERIVED CONSTANTS
// =====================================================================

// Base URL: api.mydoforms.com (USA) or api.<region>.mydoforms.com
BaseUrl =
    if Region = "" or Region = null
    then "https://api.mydoforms.com"
    else "https://api." & Region & ".mydoforms.com",

// Rolling window in UTC ISO-8601 (use Z so no "+" URL-encoding needed).
// receiveTimeBegin is inclusive, receiveTimeEnd is exclusive.
NowUtc   = DateTimeZone.RemoveZone(DateTimeZone.UtcNow()),
StartUtc = NowUtc - #duration(30*MonthsBack, 0, 0, 0),
// Build ISO-8601 by concatenation so no stray format letters (T/Z) are needed.
FmtDate  = (dt) => Date.ToText(Date.From(dt), [Format="yyyy-MM-dd", Culture="en-US"]),
FmtTime  = (dt) => Time.ToText(Time.From(dt), [Format="HH:mm:ss", Culture="en-US"]),
FromDate = FmtDate(StartUtc) & "T00:00:00.000Z",                       // inclusive
ToDate   = FmtDate(NowUtc) & "T" & FmtTime(NowUtc) & ".000Z",          // exclusive


// =====================================================================
// (2) AUTH — POST /api/v2/tokens/user  -> bearer token (24h)
// =====================================================================

// IMPORTANT: the token is fetched ONCE and memoized with List.Buffer.
// A plain `let` value in M is re-evaluated on every reference, which would
// POST to /tokens/user dozens of times per refresh and trip the endpoint's
// rate limit (HTTP 429 RateLimitException). List.Buffer forces a single
// evaluation whose result is reused everywhere.
TokenOnce = List.Buffer({
    let
        bodyRec =
            [ username = Username, password = Password ]
            & (if Account <> "" and Account <> null then [account = Account] else []),
        resp = Web.Contents(BaseUrl, [
            RelativePath = "api/v2/tokens/user",
            Headers      = [ #"Content-Type" = "application/json", Accept = "application/json" ],
            Content      = Json.FromValue(bodyRec)
        ]),
        json = Json.Document(resp)
    in
        json[token]
}),
// Use the pasted ManualToken if given (skips the login call, avoiding 429);
// otherwise fetch one. TokenOnce is lazy, so it is NOT evaluated when a
// ManualToken is supplied.
Token = if ManualToken <> "" and ManualToken <> null then ManualToken else TokenOnce{0},

AuthHeader = [ Authorization = "Bearer " & Token, Accept = "application/json" ],


// =====================================================================
// (3) FORM LIST — GET /api/v2/forms   (+ projectKey per form)
// =====================================================================

FormsRaw = Json.Document(Web.Contents(BaseUrl, [
    RelativePath = "api/v2/forms",
    Headers      = AuthHeader
])),
FormsTable0 = Table.FromRecords(FormsRaw),
// keep active forms and the columns we need
FormsTable1 = Table.SelectColumns(FormsTable0, {"key","name","displayName"}, MissingField.UseNull),
// optional name filter
WantedNames = if FormNameFilter = "" or FormNameFilter = null
              then null
              else List.Transform(Text.Split(FormNameFilter, ","), each Text.Trim(_)),
FormsTable  = if WantedNames = null
              then FormsTable1
              else Table.SelectRows(FormsTable1, each List.Contains(WantedNames, [name])),

// projectKey lookup: GET /api/v2/forms/{formKey}/projects  -> take first
GetProjectKey = (formKey as text) as nullable text =>
    let
        projs = Json.Document(Web.Contents(BaseUrl, [
            RelativePath = "api/v2/forms/" & formKey & "/projects",
            Headers      = AuthHeader
        ])),
        first = if List.Count(projs) > 0 then projs{0}[key] else null
    in
        try first otherwise null,


// =====================================================================
// (4) SUBMISSION IDS in window — GET /api/v2/submissions  (paged)
//     Returns [{key,id}, ...]. Page with skip until < pageSize returned.
// =====================================================================

PageSize = 1000,
GetSubmissionKeys = (projectKey as text, formKey as text) as list =>
    let
        FetchPage = (skip as number) as list =>
            let
                r = Web.Contents(BaseUrl, [
                    RelativePath = "api/v2/submissions",
                    Query = [
                        projectKey       = projectKey,
                        formKey          = formKey,
                        receiveTimeBegin = FromDate,
                        receiveTimeEnd   = ToDate,
                        limit            = Text.From(PageSize),
                        skip             = Text.From(skip)
                    ],
                    Headers = AuthHeader
                ])
            in
                Json.Document(r),
        pages = List.Generate(
            () => [items = FetchPage(0), skip = 0],
            each List.Count([items]) > 0,
            each [ skip = [skip] + PageSize, items = FetchPage([skip] + PageSize) ],
            each [items]
        ),
        all = List.Combine(pages)
    in
        List.Transform(all, each [key]),


// =====================================================================
// (5) FULL RECORD — GET /api/v2/forms/{formKey}/data/{recordKey}
// =====================================================================

GetRecord = (formKey as text, recordKey as text) as record =>
    Json.Document(Web.Contents(BaseUrl, [
        RelativePath = "api/v2/forms/" & formKey & "/data/" & recordKey,
        Headers      = AuthHeader
    ])),


// =====================================================================
// (6) ORCHESTRATE — for each form: keys -> records -> one table
// =====================================================================

WithProject = Table.AddColumn(FormsTable, "projectKey", each GetProjectKey([key]), type text),

WithKeys = Table.AddColumn(WithProject, "recordKeys",
    each GetSubmissionKeys([projectKey], [key]), type list),

// one row per submission
ExpandedKeys = Table.ExpandListColumn(WithKeys, "recordKeys"),
OnlyWithKeys = Table.SelectRows(ExpandedKeys, each [recordKeys] <> null),

WithRecord = Table.AddColumn(OnlyWithKeys, "Record",
    each GetRecord([key], [recordKeys]), type record),

// pull common submission-level fields up (metadata + the data object)
Result = Table.ExpandRecordColumn(WithRecord, "Record",
    {"index","status","sourceName","sourceId","openTime","createTime",
     "receiveTime","statusTime","formName","formVersion","data"},
    {"index","status","sourceName","sourceId","openTime","createTime",
     "receiveTime","statusTime","recFormName","formVersion","data"})
// NEXT STEP (do interactively in Power BI once you see real columns):
//   - Click the expand icon on `data` to surface each question's answer.
//   - Nested table/repeat fields (arrays) become nested tables: expand
//     each into its own related query keyed by the submission `index`/id
//     to build the star schema.
//   - Set data types on the time columns (they are UTC ISO strings).
in
    Result
