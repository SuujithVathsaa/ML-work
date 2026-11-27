# Confirm Web API (v24)

Sources: `sources/ConfirmWebApi.yaml` and `sources/confirm-v24-00-web-api-specification.pdf`.

The API is **for writing data into Confirm, not for reporting**. Reports and extracts use Data Sources; see
`02_data_source_rules.md`.

- **Base URL:** `/api/{tenant}`.
- **Authentication:** OAuth2 client credentials (`/oauth/token`) or HTTP basic.
- **Responses:** `BaseResponse { key, alternateKeys, errors[], warnings[] }`.

| Endpoint | Purpose | Key fields |
|---|---|---|
| `POST /features` | Create or update a feature and its conditions, attributes, measurements and dates | Identify the feature by `featureId`, `centralAssetId` or `siteCode`+`plotNumber`. Other fields: `featureTypeCode` (4 characters), `location`, `classificationCode`, `geometry` (WGS84 WKT), `extentOne/TwoEasting/Northing` and `centroidEasting/Northing` (map coordinate system), `dead`, `startDate`. Child records: `featureConditions[{observationType.observeTypeCode, conditionValue or conditionGradeCode, conditionNotes}]`, `attributes[{attributeTypeCode, attributeValueCode, notes}]`, `measurements[{measurementTypeCode, quantity}]`, `dates[{dateTypeCode, value, notes}]` |
| `POST /defects` | Create a defect, optionally with a job | `feature`, `defectTypeCode`, `officerCode`, `loggedDate`, `attributes[{paramTypeCode, valueCode, numericValue, textValue, dateValue}]`, `job` |
| `POST /jobs` | Create, update, commit or change the status of a job | `key`, `siteCode`, `plotNumber`, `jobTypeCode`, `priorityCode`, `items[{code, quantity…}]`, `currentStatusLog{statusCode, allocatedOfficerCode…}` |
| `POST /centralEnquiries` | Attach documents to an enquiry | `enquiryNumber`, `centralDocLinks[{documentName, blobData(base64)…}]` |
| `POST /payments` | Create payments | `ContractCode`, `FinancePeriodCode`, `PaymentJobs[]` |

## How the API's terms map to tables

These mappings are inferred from the field names and the schema diagrams.

| API object | Table |
|---|---|
| `featureConditions` | `feat_cond_grade` (`conditionGradeCode` → `grade_code`, `conditionValue` → `survey_obs_value`) |
| `attributes` (feature) | `feat_attrib_type` (`attributeValueCode` → `attrib_value_code`, `notes` → `feat_attrib_notes`) |
| `measurements` | `feat_measurement` (`quantity` → `feature_quantity`) |
| `dates` | `feature_date` |
| Defect `attributes` | `defect_attribute` (`param_string_value`, `param_num_value`, `param_date_value`, `param_value_code`) |

Code lengths in the API: feature type, attribute, measurement and date type codes are 4 characters; observation
type codes are up to 6.
