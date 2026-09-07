// =====================================================================
// doForms -> Power BI  |  Power Query (M) extraction template
// Scope: 6 forms, rolling last-6-months window, appended into one table
// Paste this into Power BI Desktop:  Home > Transform data >
//   Advanced Editor  (create one blank query per section, or use as guide)
// ---------------------------------------------------------------------
// TWO API STYLES ARE PROVIDED.  Use REST if your account shows it
// (Manage > Integrations > Web Services). SOAP block is the fallback.
// Everything you must fill in is marked  <<FILL>> .
// =====================================================================


// =====================================================================
// 0)  PARAMETERS  (create these as real "Parameters" in Power BI:
//     Home > Manage Parameters, or leave as queries below)
// =====================================================================

// Rolling 6-month window, recomputed at every refresh:
FromDate = Date.ToText(Date.AddMonths(Date.From(DateTime.LocalNow()), -6), "yyyy-MM-dd"),
ToDate   = Date.ToText(Date.From(DateTime.LocalNow()), "yyyy-MM-dd"),

// Your 6 forms. Fill Namespace + FormName from the Web Services page.
// (Label is just for readability in the report.)
Forms = #table(
    type table [Label = text, Namespace = text, FormName = text],
    {
        { "H&S Inspection",                     "<<FILL>>", "<<FILL>>" },
        { "Quality inspection",                 "<<FILL>>", "<<FILL>>" },
        { "Quality inspection - Preventative",  "<<FILL>>", "<<FILL>>" },
        { "Construction Inspection",            "<<FILL>>", "<<FILL>>" },
        { "Winter Conformance Check",           "<<FILL>>", "<<FILL>>" },
        { "Depot Inspection",                   "<<FILL>>", "<<FILL>>" }
    }
),


// =====================================================================
// 1A)  REST STYLE  (recommended if available)
// ---------------------------------------------------------------------
// Base host + paths come from the doForms REST API / OpenAPI shown on
// your Web Services page. Confirm the exact paths and fill below.
// =====================================================================

RestBase = "https://<<FILL: e.g. www.mydoforms.com/api/v3>>",

// -- Auth: exchange web-user credentials for a bearer token ----------
// NOTE: put the real username/password in Power BI's credential prompt
// where possible; shown inline only to make the shape clear.
GetToken = () =>
    let
        resp = Web.Contents(RestBase, [
            RelativePath = "tokens/user",              // <<CONFIRM path>>
            Headers      = [ #"Content-Type" = "application/json" ],
            Content      = Json.FromValue([
                username = "<<FILL>>",
                password = "<<FILL>>"
                // some tenants also require: company = "<<FILL>>"
            ])
        ]),
        token = Json.Document(resp)[token]             // <<CONFIRM field name>>
    in
        token,

// -- Pull one form's records for the date window, with paging --------
GetFormDataREST = (namespace as text, formName as text) =>
    let
        token = GetToken(),
        // paginate until a page returns fewer than PageSize rows
        PageSize = 500,
        Fetch = (skip as number) =>
            let
                r = Web.Contents(RestBase, [
                    RelativePath = "data/" & namespace & "/" & formName,  // <<CONFIRM>>
                    Query = [
                        startDate = FromDate,          // <<CONFIRM param names>>
                        endDate   = ToDate,
                        skip      = Text.From(skip),
                        limit     = Text.From(PageSize)
                    ],
                    Headers = [ Authorization = "Bearer " & token ]
                ]),
                rows = Json.Document(r)[data]          // <<CONFIRM field name>>
            in
                rows,
        // gather pages
        AllPages = List.Generate(
            () => [page = Fetch(0), skip = 0],
            each List.Count([page]) > 0,
            each [ skip = [skip] + PageSize, page = Fetch([skip] + PageSize) ],
            each [page]
        ),
        combined = List.Combine(AllPages),
        asTable  = Table.FromList(combined, Splitter.SplitByNothing(), {"Record"})
    in
        asTable,


// =====================================================================
// 1B)  SOAP STYLE  (fallback — WSID + password per form)
// ---------------------------------------------------------------------
// doForms SOAP endpoint. WSDL: http://www.mydoForms.com/wss?wsdl
// getData returns an XML payload of submissions for the window.
// =====================================================================

SoapUrl = "https://www.mydoForms.com/wss",           // <<CONFIRM>>

GetFormDataSOAP = (wsid as text, password as text) =>
    let
        envelope =
            "<?xml version=""1.0"" encoding=""utf-8""?>" &
            "<soap:Envelope xmlns:soap=""http://schemas.xmlsoap.org/soap/envelope/"">" &
              "<soap:Body>" &
                "<getData xmlns=""http://doforms.com/"">" &      // <<CONFIRM namespace/op>>
                  "<wsId>"      & wsid     & "</wsId>" &
                  "<password>"  & password & "</password>" &
                  "<dateFrom>"  & FromDate & "</dateFrom>" &
                  "<dateTo>"    & ToDate   & "</dateTo>" &
                  "<responseFormat>xml</responseFormat>" &
                "</getData>" &
              "</soap:Body>" &
            "</soap:Envelope>",
        resp = Web.Contents(SoapUrl, [
            Headers = [
                #"Content-Type" = "text/xml; charset=utf-8",
                #"SOAPAction"   = "http://doforms.com/getData"   // <<CONFIRM>>
            ],
            Content = Text.ToBinary(envelope)
        ]),
        xml = Xml.Document(resp)
        // Then navigate xml down to the repeating <record> nodes and
        // Table.FromRecords(...). We'll finish this once we see one
        // real response shape.
    in
        xml,


// =====================================================================
// 2)  LOOP OVER ALL 6 FORMS AND APPEND
// ---------------------------------------------------------------------
// Switch GetFormDataREST <-> GetFormDataSOAP depending on your account.
// =====================================================================

WithData = Table.AddColumn(Forms, "Data", each
    GetFormDataREST([Namespace], [FormName])          // or GetFormDataSOAP(...)
),

Expanded = Table.ExpandTableColumn(WithData, "Data", {"Record"}, {"Record"}),

// Expand the JSON/record object into real columns. Field list is filled
// in Power BI once we see the first response (click the expand icon).
Result = Expanded
in
    Result
