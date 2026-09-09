// =====================================================================
// STEP 1 of 2 — Register the Anonymous credential (Power BI only)
// ---------------------------------------------------------------------
// WHY: Power BI authorises a data source by probing it with a GET.
// The token endpoint (/api/v2/tokens/user) is POST-only, so the probe
// fails and the credential dialog loops forever.
//
// This query makes a harmless GET to the same domain. ManualStatusHandling
// stops the 401 from throwing, so Power BI can store the credential.
// Once Anonymous is saved at the ROOT level, every other call to
// api.eu.mydoforms.com (including the POST) reuses it silently.
//
// USE: Blank Query > Advanced Editor > paste > Done.
//   When prompted: choose ANONYMOUS, set the level to the ROOT
//   "https://api.eu.mydoforms.com/", then Connect.
//   Expected result: the number 401  (that is SUCCESS for this step —
//   it means the call went through and the credential is now stored).
// =====================================================================
let
    BaseUrl = "https://api.eu.mydoforms.com",   // use "https://api.mydoforms.com" for USA
    resp = Web.Contents(BaseUrl, [
        RelativePath         = "api/v2/forms",
        Headers              = [ Accept = "application/json" ],
        ManualStatusHandling = {400, 401, 403, 404, 429, 500}
    ]),
    status = Value.Metadata(resp)[Response.Status]
in
    status
