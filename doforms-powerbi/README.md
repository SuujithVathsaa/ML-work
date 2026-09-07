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
record's data → append**. See `doForms_PowerQuery_Template.pq`.

## Extraction window

Rolling **last 6 months**, recomputed on every refresh (`MonthsBack = 6`).

## Setup steps (Power BI Desktop)

1. Create Parameters: `Region` (`eu`), `Username`, `Password` (sensitive),
   `Account` (blank unless multi-account), `MonthsBack` (6), `FormNameFilter`
   (blank = all forms).
2. Get Data → Blank Query → Advanced Editor → paste the template.
3. Credential prompt for `api.eu.mydoforms.com` → **Anonymous** (the bearer
   token carries auth; don't type the password into the credential dialog).
4. Run → expand the `data` column once real field names appear; break nested
   repeat/table arrays into related child queries keyed by submission id.
5. Model as a star schema (fact = submissions; dims = Form, Date, User).
6. Build report pages → **Publish** to a Power BI workspace → configure
   **scheduled refresh** (web API typically refreshes without a gateway).

## Security notes

- No credentials are stored in this repo. The password lives only in the
  Power BI parameter / credential store on the machine and in the service.
- The token expires after 24h; Power Query re-fetches it on each refresh.
- Watch the account's **daily API quota**; the 6-month × 6-form pull is
  incremental-friendly (filter by `receiveTime`).
