// =====================================================================
// TEST ONE WEB SERVICE  — run this before filling in all six
// ---------------------------------------------------------------------
// 3_GetData_StaticToken.pq deliberately swallows failures
// (`try ... otherwise null`) so one bad web service cannot break the whole
// refresh. That is right for production, but it hides WHY a row failed.
//
// This query does the opposite: it shows the raw HTTP status and body for
// a single web service, so you can confirm the ID/password work.
//
// USE: Blank Query > Advanced Editor > paste > fill WsId + WsPassword >
//      Done. Anonymous > root level > Connect.
//
// RESULT
//   HttpStatus 200  -> works. FormCount/FormName show what it can see.
//                      Copy this ID/password pair into the WebServices
//                      table in 3_GetData_StaticToken.pq.
//   401 / 403       -> ID or password wrong, or the web service is not
//                      enabled for that form in the portal.
//   Body text tells you the rest.
// =====================================================================
let
    Region     = "eu",     // "eu" = UK/Europe.  "" = USA.
    WsId       = "PUT-WEB-SERVICE-ID-HERE",        // e.g. acme$$1234$$Published$$5678
    WsPassword = "PUT-WEB-SERVICE-PASSWORD-HERE",

    BaseUrl = if Region = "" then "https://api.mydoforms.com"
              else "https://api." & Region & ".mydoforms.com",

    // The static token: "<web service id>:<web service password>"
    resp = Web.Contents(BaseUrl, [
        RelativePath         = "api/v2/forms",
        Headers              = [ Authorization = "Bearer " & WsId & ":" & WsPassword,
                                 Accept        = "application/json" ],
        ManualStatusHandling = {400, 401, 403, 404, 429, 500, 502, 503}
    ]),

    probe  = try [ st = Value.Metadata(resp)[Response.Status],
                   txt = Text.FromBinary(resp) ],

    output =
        if probe[HasError] then
            [ HttpStatus = null,
              FormCount  = null,
              FormName   = null,
              Body       = "REQUEST ERROR - " & probe[Error][Message] ]
        else
            let
                st   = probe[Value][st],
                txt  = probe[Value][txt],
                json = try Json.Document(txt) otherwise null
            in
                [ HttpStatus = st,
                  FormCount  = if st = 200 and json <> null then List.Count(json) else null,
                  FormName   = if st = 200 and json <> null and List.Count(json) > 0
                               then Record.FieldOrDefault(json{0}, "name", "(no name)")
                               else null,
                  Body       = txt ]
in
    output
