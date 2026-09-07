// =====================================================================
// DOC 1 of 2 — GET A TOKEN   (run this ONCE, then copy the token)
// Verified against doForms REST API OpenAPI v2.5.2
// ---------------------------------------------------------------------
// ENDPOINT   POST {BaseUrl}/api/v2/tokens/user
// BODY       { "username": ..., "password": ..., "account": optional }
// RETURNS    { code, token, message, customerCode, customerKey, userKey,
//              accounts[], refreshToken }
// TOKEN LIFE 24 hours
//
// *** CRITICAL — READ BEFORE RUNNING ***
// This endpoint is HEAVILY rate limited and the penalty ESCALATES
// (observed: 33s -> 958s). Every failed attempt RESTARTS the timer.
//   - Run this query ONCE, then STOP.
//   - Do NOT click Connect repeatedly. Do NOT hit Refresh in a loop.
//   - If you get 429, read the "try again after N seconds" value,
//     wait that long, and run ONCE more.
// The data queries (DOC 2) allow 600 requests/minute, so only THIS
// login step needs care.
//
// PREREQUISITE (only needed once, if the credential dialog loops):
//   Power BI authorises a data source by probing it with a GET, but this
//   endpoint is POST-only, so the probe fails and the dialog re-prompts.
//   Fix: first run Step1_RegisterAnonymous.pq (a GET) and choose
//   Anonymous at the ROOT level https://api.eu.mydoforms.com/ .
//   After that this POST reuses the stored credential silently.
//
// USE: Home > Get Data > Blank Query > Advanced Editor > paste this >
//      set Password > Done.
//   SUCCESS -> a long string starting "eyJ..."  = your token. COPY IT.
//   429      -> wait the stated seconds, run once more.
//   401      -> wrong password/region, or you need `Account`.
//   Returns a list of account names -> your login is in several accounts:
//            put one of them in Account below and run again.
// =====================================================================
let
    // ---------------- SETTINGS ----------------
    Region   = "eu",          // "eu" = UK/Europe.  "" = USA.  also "ca","au","sa"
    Username = "Suujith.ramesh@staffordshire.gov.uk",
    Password = "PUT-YOUR-PASSWORD-HERE",
    Account  = "",            // leave "" unless the response lists accounts

    // ---------------- CALL ----------------
    BaseUrl = if Region = "" then "https://api.mydoforms.com"
              else "https://api." & Region & ".mydoforms.com",

    bodyRec = [ username = Username, password = Password ]
              & (if Account <> "" then [ account = Account ] else []),

    resp = Web.Contents(BaseUrl, [
        RelativePath         = "api/v2/tokens/user",
        Headers              = [ #"Content-Type" = "application/json",
                                 Accept          = "application/json" ],
        Content              = Json.FromValue(bodyRec),
        ManualStatusHandling = {400, 401, 403, 404, 429, 500}
    ]),

    status = Value.Metadata(resp)[Response.Status],
    json   = try Json.Document(resp) otherwise null,

    // ---------------- RESULT ----------------
    result =
        if status = 200 and json <> null then
            // if the login spans several accounts, show them instead
            if Record.HasFields(json, "accounts")
               and json[accounts] <> null
               and List.Count(json[accounts]) > 1
            then "MULTIPLE ACCOUNTS - set Account to one of: "
                 & Text.Combine(List.Transform(json[accounts], Text.From), ", ")
            else json[token]
        else
            "HTTP " & Text.From(status) & " - " & Text.FromBinary(resp)
in
    result
