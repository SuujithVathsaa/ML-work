# Confirm knowledge base

This folder is a working knowledge base for a future Confirm reporting agent. It holds the Confirm (Brightly/Pitney
Bowes infrastructure asset management) source documents, everything established about the schema so far, the rules
for writing Confirm Data Sources, proven query patterns, and live projects.

**Evidence rule used throughout:** every table and column is tagged with where it comes from:
- **[manual p.N]**: the v22 Reporting manual (schema diagrams and Data Sources chapter)
- **[api]**: the v24 Web API spec
- **[live]**: proven by a query that already runs in this council's Confirm
- **[assumed]**: not yet verified; treat with caution

## Contents

| Path | What it is |
|---|---|
| `01_schema_reference.md` | Tables, primary keys, columns and joins, with evidence tags |
| `02_data_source_rules.md` | How a Confirm Data Source must be written (SELECT-only, Oracle, column order, functions, map) |
| `03_query_patterns.md` | Reusable patterns: one row per feature, current condition, latest N inspections, the batch-join bug |
| `04_web_api.md` | What the Web API covers (writes, not reporting) and the terms it confirms |
| `05_open_questions.md` | Unverified facts and how to check each one |
| `sources/` | Original documents: the PDFs, the API YAML, the asset workbook, extracted text, and all 28 schema diagram pages as PNG |
| `projects_asset_datasources/` | Information Team asset data sources (inventory, discovery SQL, per-asset queries) |

## Environment facts (this council)

- **[live]** The database is Oracle. The working reports use `SYSDATE`, `TRUNC` and `(+)`.
- **[live]** The Data Source editor rejects SQL that doesn't start with `SELECT`, with the error "The entered SQL is
  not a SELECT statement", so `WITH` / CTEs are out.
- **[live]** Highways inspection officer codes `SGC0`–`SGC9` and `SGCA` are used for gully cleansing.
- **[live]** In gully inspections, observation keys 130, 133 and 134 are Gully Accessibility, Action Taken and Gully
  State On Departure.

## Source documents

- `sources/confirm-v22-00-reporting-user-manual.pdf`: the Reporting chapter. Pages 51–70 cover Data Sources;
  pages 93–120 are the schema diagrams.
- `sources/confirm-v24-00-web-api-specification.pdf` and `sources/ConfirmWebApi.yaml`: the Web API, which handles
  enquiries, defects, features, jobs and payments.
- `sources/Confirm_Asset_Features_with_attributes.xlsx`: the asset feature groups with their measurement, attribute
  and observation codes. The second sheet lists the core output columns.
- `sources/text/`: text extracted from the PDFs, ready for search or retrieval.
- `sources/schema_diagrams/pNNN_<area>.png`: the schema diagrams at 200 dpi. Zoom into crops to read column names.

The manual is v22; the live system may be newer. One known gap is `central_site.display_address`: it's in the
council's column list but not in the v22 diagram.
