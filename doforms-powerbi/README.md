# doForms → Power BI dashboard

Extract inspection-form submissions from the **doForms REST API** and build a
Power BI dashboard, published to the Power BI service (Pro workspace — no
Fabric capacity required).

## Forms in scope (6)

| Report name | doForms form label |
|---|---|
| health and safety | H&S Inspection |
| quality | Quality inspection |
| quality – preventative | Quality inspection – Preventative |
| construction | Construction Inspection |
| winter non conformance | Winter Conformance Check |
| depot inspection | Depot Inspection |

> The `mydoforms.appspot.com/webclient?...` links are form-*filling* UI links,
> not data endpoints. The API identifies forms by their `key` / `name`, fetched
> from `GET /api/v2/forms`.

## API summary (doForms REST API v2.5.2)

- **Server (EU / UK):** `https://api.eu.mydoforms.com`
  (USA `https://api.mydoforms.com`; also `ca`, `au`, `sa`)
- **Auth:** `POST /api/v2/tokens/user` with `{username, password, account?}`
  → returns `token` (bearer, valid 24h). Send as `Authorization: Bearer <token>`.
- **List forms:** `GET /api/v2/forms` → `[{key, name, displayName, ...}]`
- **Project key for a form:** `GET /api/v2/forms/{formKey}/projects` → `[{key,...}]`
- **Find submissions in a date window:**
  `GET /api/v2/submissions?projectKey=&formKey=&receiveTimeBegin=&receiveTimeEnd=&limit=1000&skip=`
  → `[{key, id}]` (identifiers only). Page with `skip`; `limit` max 1000.
  Dates are ISO-8601 with offset; `Begin` inclusive, `End` exclusive.
- **Full submission data:** `GET /api/v2/forms/{formKey}/data/{recordKey}`
  → flattened record; `data` uses each question's data-name as the property
  name. Nested tables/repeatables are arrays of objects; blobs
  (signatures, photos) are `{key, id, fileName, type}`.

So the pull is two-level: **list submission keys in the window → fetch each
record's data → append**. See `2_GetData.pq`.

## Extraction window

Rolling **last 6 months**, recomputed on every refresh (`MonthsBack = 6`).

## Files (use in this order)

| File | Purpose |
|---|---|
| `3_GetData_StaticToken.pq` | **RECOMMENDED.** Uses a static web service token. No login call, no expiry, no rate limit. |
| `Step1_RegisterAnonymous.pq` | Run **once** if the credential dialog loops. A GET that lets Power BI store the Anonymous credential for the domain. |
| `1_GetToken.pq` | Fallback: user-token login. Rate limited, expires in 24h. |
| `2_GetData.pq` | Fallback: pulls data using a user token from `1_GetToken.pq`. |

## Recommended approach: static web service token

The spec's `WebserviceTokenAuthentication` scheme documents an alternative
to logging in at all:

> Build a static token by combining a web service ID and web service
> password separated by a colon.
> ID `acmeinc$$1234$$Published$$5678` + password `mypassword`
> -> `Authorization: Bearer acmeinc$$1234$$Published$$5678:mypassword`

This avoids every problem with the user-token route:

| Problem with `POST /tokens/user` | Static token |
|---|---|
| POST-only, so Power BI's GET credential probe loops | Only GETs -- Anonymous works |
| Escalating rate limit (33s -> 958s observed) | Login endpoint never called |
| Token expires after 24h | Never expires |

A web service token is scoped to one project + form, so create one web
service per form (Manage > Integrations > Web Services) and list all six in
the `WebServices` table. With web service auth, `/submissions` does not need
`projectKey`/`formKey` -- the token already identifies them.

## Setup steps (Power BI Desktop)

1. **If the credential dialog keeps reappearing**, run `Step1_RegisterAnonymous.pq`
   first. Choose **Anonymous** at the ROOT level `https://api.eu.mydoforms.com/`.
   A result of `401` means success — the credential is now stored.
   *Why:* Power BI authorises a source by probing it with a GET, but
   `/tokens/user` is POST-only, so the probe fails and the dialog loops.
2. Run `1_GetToken.pq` **once**. Copy the `eyJ...` token.
   The token endpoint is heavily rate limited and the penalty **escalates**
   (33s -> 958s observed); every retry restarts the timer. Run it once, wait
   the stated seconds if throttled, then run once more.
3. Paste the token into `Token` in `2_GetData.pq`, set `Region`, run it.
   Select the last step `Result` and Refresh Preview.
4. Expand the `data` column; split nested repeat/table arrays into child
   queries keyed by submission id.
5. Model as a star schema (fact = submissions; dims = Form, Date, User).
6. Build report pages, **Publish** to a Power BI workspace, set **scheduled
   refresh**.

## Rate limits (from the OpenAPI spec)

- Data endpoints: **600 requests/minute per account** — ample; the one
  call per submission in step 4 is fine.
- `POST /tokens/user`: tightly throttled with an escalating penalty. Call it
  once per 24h, never in a refresh loop. `2_GetData.pq` never calls it.

## Security notes

- No credentials are stored in this repo. The password lives only in the
  Power BI parameter / credential store on the machine and in the service.
- The token expires after 24h. `2_GetData.pq` uses a pasted token and never
  calls the login endpoint, so the throttled `/tokens/user` is hit once a day.
- Watch the account's **daily API quota**; the 6-month × 6-form pull is
  incremental-friendly (filter by `receiveTime`).
