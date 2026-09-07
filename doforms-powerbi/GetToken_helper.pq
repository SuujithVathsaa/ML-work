// =====================================================================
// GetToken helper  —  run ONCE, copy the token, paste it into the main
// query's ManualToken. Avoids repeatedly hitting the rate-limited
// /tokens/user endpoint during development.
//
// USE: Home > Get Data > Blank Query > Advanced Editor > paste this >
//      set Password > Done. Pick Anonymous when prompted.
//   - If it returns a long string  -> that's your token. Copy it.
//   - If it returns a 429 message  -> WAIT ~60s (don't click Connect
//                                     repeatedly, each click resets the
//                                     timer), then Refresh once.
// =====================================================================
let
    Region   = "eu",   // "" for USA
    Username = "Suujith.ramesh@staffordshire.gov.uk",
    Password = "PUT-PASSWORD-HERE",
    Account  = "",

    BaseUrl = if Region = "" then "https://api.mydoforms.com"
              else "https://api." & Region & ".mydoforms.com",
    bodyRec = [ username = Username, password = Password ]
              & (if Account <> "" then [account = Account] else []),
    resp = Web.Contents(BaseUrl, [
        RelativePath = "api/v2/tokens/user",
        Headers = [ #"Content-Type" = "application/json", Accept = "application/json" ],
        Content = Json.FromValue(bodyRec),
        ManualStatusHandling = {400, 401, 403, 404, 429, 500}
    ]),
    status = Value.Metadata(resp)[Response.Status],
    json   = try Json.Document(resp) otherwise null,
    result =
        if status = 200 and json <> null then json[token]
        else "HTTP " & Text.From(status) & " — " & Text.FromBinary(resp)
in
    result
