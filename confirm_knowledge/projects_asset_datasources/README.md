# Confirm asset data sources – Information Team

There is one Confirm data source for each asset type in `Confirm_Asset_Features_with_attributes.xlsx`, named
`Information Team – Asset [Asset Name]`.

> **Update:** the Reporting manual has since resolved most placeholders below. See `../01_schema_reference.md` (feat_measurement, feat_attrib_type, feat_cond_grade, feature centroid columns) and `../03_query_patterns.md`. The first asset query is `AA_arboricultural_asset.sql`; paste `AA_arboricultural_asset.paste.sql` into Confirm. D3 is answered by the manual: one batch holds many features, so join insp_condition on all three keys.

**Status: checkpoint.** The asset inventory and the proposed join structure are ready for review. The per-asset SQL
will be written once the schema questions below are answered. The reporting manual and the area-code workbook
mentioned in the brief were not attached.

| File | Contents |
|---|---|
| `asset_inventory.md` / `.csv` | The 12 asset types and all 274 measurement / attribute / observation entries, with asset codes carried down through merged cells |
| `00_schema_discovery.sql` | Read-only queries that resolve every placeholder below from the live database |

## Evidence levels

* **Confirmed (working report):** the tables, columns and joins in the existing gully report, which runs in this
  Confirm database.
* **Given (workbook sheet 2):** these column names: `site.site_code`, `site.site_class_code`,
  `central_site.site_name`, `central_site.display_address`, `feature.feature_location`, `feature.feature_type_code`,
  `feature_type.feature_type_name`, `feature.plot_number`, `feature.feature_id`, `feature.area_code`,
  `feature.ward_code`, `feature.central_asset_id`.
* **Assumed:** the join keys between those tables. The discovery script verifies them.
* **Unresolved:** placeholders `[LIKE_THIS]`.

## Platform constraints

* **Oracle.** The working report uses `SYSDATE`, `TRUNC` and `(+)` outer joins.
* **Statements must start with `SELECT`.** The Confirm data-source editor rejects `WITH` ("The entered SQL is not a
  SELECT statement"), so the shared base is written as an inline view, not a CTE.
* **Column aliases are `UPPER_SNAKE`, at most 30 characters.** This is the Oracle limit before 12.2, and it is safe
  in the data-source column grid. Each alias is prefixed by kind (`M_`, `A_`, `O_`), because the workbook reuses
  codes across kinds. For example, `S009` is both measurement *Construction Length* and attribute *Planning
  Conservation Area*.

## Join map

```
feature f                          one row per asset; driving table, filtered by f.feature_type_code
 ├─ feature_type ft   ON ft.feature_type_code = f.feature_type_code         (assumed key)
 ├─ central_site cs   ON cs.site_code = f.site_code                         (confirmed: working report)
 ├─ site s            ON s.site_code  = f.site_code                         (assumed key) – LEFT JOIN
 ├─ area a            ON a.area_code  = f.area_code                         (area/area_name confirmed; key on feature assumed) – LEFT JOIN
 ├─ ward w            ON w.ward_code  = f.ward_code                         (ward/ward_name confirmed; key on feature assumed) – LEFT JOIN
 ├─ measurements      [MEASUREMENT_TABLE]  pivoted to one row per feature   – LEFT JOIN
 ├─ attributes        [ATTRIBUTE_TABLE]    pivoted to one row per feature   – LEFT JOIN
 └─ observations      latest value per observation type, pivoted            – LEFT JOIN
       inspection_feature inf  ON inf.site_code = f.site_code AND inf.plot_number = f.plot_number   (confirmed)
       insp_condition ic       ON ic.insp_batch_no = inf.insp_batch_no                              (confirmed; see D3)
       observe_type ot         ON ot.observe_type_key = ic.observe_type_key                         (confirmed)
       observe_parameter op    ON op.obs_parm_code = ot.obs_parm_code                               (confirmed)
       observe_parm_opt opo    ON opo.obs_parm_code = op.obs_parm_code
                              AND opo.obs_parm_opt_code = ic.grade_code                             (confirmed)
       code filter: ot.[OBSERVE_TYPE_CODE_FIELD] = 'GACC' …  (the workbook gives codes; the report uses keys 130/133/134)
```

Live features only: `f.feature_deadflag = 'N'` (confirmed: working report).

## Output shape and rules

* **One row per feature.** Each child source is reduced to one row per `(site_code, plot_number)` before it is
  joined, using `MAX(CASE WHEN code = 'X' THEN value END)` over a ranked inline view. `DISTINCT` is not used.
* **Observations take the latest value.** For each feature and observation type, the value from the most recent
  inspection is used: `ROW_NUMBER() OVER (PARTITION BY site_code, plot_number, observe_type ORDER BY
  feature_insp_date DESC, insp_batch_no DESC) = 1`. Each observation also gets a `_DATE` column, so you can see
  how old the value is.
* **Attributes and measurements take the current record.** The current-record rule depends on whatever
  effective-date or status columns D1 reveals. Until then it is a placeholder: `[CURRENT_RECORD_RULE]`.

## Unresolved placeholders

| Placeholder | Needed for | Resolved by |
|---|---|---|
| `[MEASUREMENT_TABLE]`, `[MEASUREMENT_CODE_FIELD]`, `[MEASUREMENT_VALUE_FIELD]` | 43 measurement columns | D1 |
| `[ATTRIBUTE_TABLE]`, `[ATTRIBUTE_TYPE_CODE_FIELD]`, `[ATTRIBUTE_VALUE_FIELD]` (+ pick-list lookup if values are codes) | 100 attribute columns | D1, D2 |
| `[CURRENT_RECORD_RULE]` (effective dates, dead flags, history rows) | attributes and measurements | D1, D5 |
| `[OBSERVE_TYPE_CODE_FIELD]` (column holding GACC, ACT …) | 131 observation columns | D4 |
| `[OBSERVATION_FREE_VALUE_FIELD]` (numeric/text observations, e.g. Tree Asset Height, Engineer Comments, BCI Average) | non-pick-list observations | D1 on `insp_condition` |
| Whether `insp_condition` needs a feature key besides `insp_batch_no` | correct observation per feature | D3 |
| `[COORDINATE_EXPRESSION]` (easting/northing columns or a geometry table) | Coordinates column | D1 |
| `site` ↔ `feature` key | `site.site_class_code` | D1, D2 |
