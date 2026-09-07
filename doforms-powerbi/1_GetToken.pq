// =====================================================================
// DOC 1 of 2 — GET A TOKEN   (run this ONCE, then copy the token)
// Verified against doForms REST API OpenAPI v2.5.2
// ---------------------------------------------------------------------
// ENDPOINT   POST {BaseUrl}/api/v2/tokens/user
// BODY       { "username": ..., "password": ..., "account": optional }
// RETURNS    { code, token, message, customerCode, customerKey, userKey,
//              accounts[], refreshToken }
// TOKEN LIFE 24 hours
// STATUSES   200 token | 300 Account Required | 400 bad request
//            401 unauthorized OR MFA code required | 403 forbidden/inactive
//            429 rate limited | 500 server error
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
//   401      -> wrong password/region, or an MFA code is required.
//   300      -> your login spans several accounts; set `Account`.
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
        // NOTE: ManualStatusHandling accepts 4xx/5xx ONLY. Power Query
        // rejects 3xx codes ("'300' is not supported"), because it handles
        // redirects itself. The documented 300 "Account Required" response
        // is therefore caught with `try` below instead of listed here.
        ManualStatusHandling = {400, 401, 403, 404, 429, 500, 502, 503}
    ]),

    // Read the response ONCE as text, then parse. Avoids consuming the
    // binary twice and lets us parse the body even on error statuses.
    probe = try [ st = Value.Metadata(resp)[Response.Status],
                  txt = Text.FromBinary(resp) ],

    // ---------------- RESULT ----------------
    result =
        if probe[HasError] then
            // A 300 "Account Required" lands here, because Power Query will
            // not let us handle 3xx manually.
            "REQUEST ERROR - Power Query could not complete the call." & "#(lf)"
            & "The most likely cause is HTTP 300 'Account Required': your login "
            & "belongs to more than one doForms account, so you must set the "
            & "Account value at the top of this query." & "#(lf)"
            & "Details: " & probe[Error][Message]
        else
            let
                status = probe[Value][st],
                txt    = probe[Value][txt],
                json   = try Json.Document(txt) otherwise null,

                accountList =
                    if json <> null and Record.HasFields(json, "accounts")
                       and json[accounts] <> null
                    then Text.Combine(List.Transform(json[accounts], Text.From), ", ")
                    else "(none returned)"
            in
                // ---- success ----
                if status = 200 and json <> null and Record.HasFields(json, "token") then
                    json[token]

                // ---- 200 but no token: account selection needed ----
                else if status = 200 then
                    "NO TOKEN RETURNED - set Account to one of: " & accountList
                    & " | body: " & txt

                // ---- 401: bad credentials, or MFA needed ----
                else if status = 401 then
                    "HTTP 401 - wrong username/password, wrong Region, or an MFA "
                    & "code is required (add  code = ""123456""  to bodyRec). "
                    & "Server said: " & txt

                // ---- 429: throttled; the message states how long to wait ----
                else if status = 429 then
                    "HTTP 429 RATE LIMITED - wait the number of seconds stated "
                    & "below, then run this query ONCE. Every retry restarts the "
                    & "timer. " & txt

                else
                    "HTTP " & Text.From(status) & " - " & txt
in
    result
