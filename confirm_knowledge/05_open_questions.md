# Open questions

These are unverified facts and how to check each one. Update this file as each one is resolved.

| # | Question | Why it matters | How to check |
|---|---|---|---|
| Q1 | Are the workbook asset codes (AA, DAGA …) **feature group** codes rather than feature type codes? | Decides the filter in every asset data source | `SELECT feature_group_code, COUNT(*) FROM feature_type WHERE feature_group_code IN ('AA','DAGA') GROUP BY feature_group_code`. Compare with the same query on `feature.feature_type_code`. |
| Q2 | ~~Does `central_site.display_address` exist?~~ **Resolved [live]: no.** Confirm returns ORA-00904, so use `central_site.site_address`. | Core column | Done |
| Q3 | Is `observe_type.observe_type_code` unique? | The per-code join would duplicate rows if not | `SELECT observe_type_code, COUNT(*) FROM observe_type GROUP BY observe_type_code HAVING COUNT(*) > 1` |
| Q4 | Is `feat_cond_grade` kept up to date by inspections? | Decides between "current condition" and "latest inspection" for observations | Compare `feat_cond_grade` with the latest `insp_condition` for a few gullies |
| Q5 | Which `attribute_type.attrib_type_flag` values mean pick list, text and number, and where are numeric attribute values stored? | Picking the right attribute value column | `SELECT attrib_type_code, attrib_type_flag FROM attribute_type WHERE attrib_type_code IN ('TALO','TAT','PWA')`, then inspect `feat_attrib_notes` |
| Q6 | What coordinate system is set in Map System Settings? Presumably British National Grid. | Labelling the Easting and Northing columns | The Confirm Map System Settings screen |
| Q7 | Does the Data Source editor accept `--` comments inside the SQL? | Whether paste-ready SQL can keep its comments | Try it once |
| Q8 | Does `site.site_class_code` differ from `feature.site_class_code`? | Which one the "site class" column should use | Compare the two values for the same features |
