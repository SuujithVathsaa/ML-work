# Proven query patterns

## P1 – One row per feature with measurements, attributes and observations

`feat_measurement`, `feat_attrib_type` and `feat_cond_grade` are each keyed on **feature + code**. A `LEFT JOIN`
that also fixes the code therefore returns 0 or 1 rows: no pivot, no `GROUP BY` and no `DISTINCT` are needed, and
missing values come back as NULL.

```sql
LEFT JOIN feat_measurement m_xx ON m_xx.site_code = feature.site_code AND m_xx.plot_number = feature.plot_number AND m_xx.measurement_code = 'XX'
LEFT JOIN feat_attrib_type a_xx ON a_xx.site_code = feature.site_code AND a_xx.plot_number = feature.plot_number AND a_xx.attrib_type_code = 'XX'
LEFT JOIN attribute_value av_xx ON av_xx.attrib_type_code = a_xx.attrib_type_code AND av_xx.attrib_value_code = a_xx.attrib_value_code
LEFT JOIN observe_type ot_xx    ON ot_xx.observe_type_code = 'XX'
LEFT JOIN feat_cond_grade c_xx  ON c_xx.site_code = feature.site_code AND c_xx.plot_number = feature.plot_number AND c_xx.observe_type_key = ot_xx.observe_type_key
LEFT JOIN observe_parm_opt op_xx ON op_xx.obs_parm_code = ot_xx.obs_parm_code AND op_xx.obs_parm_opt_code = c_xx.grade_code
```

- **Output per item:**
  - attribute: `av_xx.attrib_value_name` (pick list) and `a_xx.feat_attrib_notes` (text)
  - observation: `op_xx.obs_parm_opt_name` (grade) and `c_xx.survey_obs_value` (number)
  - measurement: `m_xx.feature_quantity`
- **Filter by asset type:** use `feature_type.feature_group_code = '<group>'`, plus `feature.feature_deadflag = 'N'`.
- **Worked example:** `projects_asset_datasources/AA_arboricultural_asset.sql`.

## P2 – Observations from inspections: always join on all three keys

`inspection_feature` and `insp_condition` are keyed on `insp_batch_no, site_code, plot_number`, and one batch holds
many features. **Joining on `insp_batch_no` alone assigns observations to the wrong features.** The council's
original gully report had this bug; this is the corrected join:

```sql
FROM inspection_feature inf
JOIN insp_condition ic ON ic.insp_batch_no = inf.insp_batch_no
                      AND ic.site_code     = inf.site_code
                      AND ic.plot_number   = inf.plot_number
JOIN observe_type ot      ON ot.observe_type_key = ic.observe_type_key
LEFT JOIN observe_parm_opt opo ON opo.obs_parm_code = ot.obs_parm_code AND opo.obs_parm_opt_code = ic.grade_code
```

## P3 – Gully exceptions in the last 7 days (corrected version of the live report)

The three observations are pivoted with one join per observation, so a missing observation no longer drops the
inspection.

```sql
SELECT
    'Current' AS inspection,
    inf.insp_batch_no, action_officer.officer_name, central_site.site_name, central_site.site_code,
    inf.plot_number, ward.ward_name, area.area_name, inf.feature_insp_date,
    o130.obs_parm_opt_name AS gully_accessibility,
    o133.obs_parm_opt_name AS action_taken,
    o134.obs_parm_opt_name AS gully_state_on_departure
FROM inspection_feature inf
    JOIN inspection_batch ib  ON ib.insp_batch_no = inf.insp_batch_no
    JOIN feature              ON feature.site_code = inf.site_code AND feature.plot_number = inf.plot_number
    JOIN central_site         ON central_site.site_code = inf.site_code
    JOIN action_officer       ON action_officer.officer_code = inf.officer_code
    LEFT JOIN ward            ON ward.ward_code = central_site.ward_code
    LEFT JOIN area            ON area.area_code = central_site.area_code
    LEFT JOIN insp_condition c130 ON c130.insp_batch_no = inf.insp_batch_no AND c130.site_code = inf.site_code AND c130.plot_number = inf.plot_number AND c130.observe_type_key = 130
    LEFT JOIN observe_type t130   ON t130.observe_type_key = 130
    LEFT JOIN observe_parm_opt o130 ON o130.obs_parm_code = t130.obs_parm_code AND o130.obs_parm_opt_code = c130.grade_code
    LEFT JOIN insp_condition c133 ON c133.insp_batch_no = inf.insp_batch_no AND c133.site_code = inf.site_code AND c133.plot_number = inf.plot_number AND c133.observe_type_key = 133
    LEFT JOIN observe_type t133   ON t133.observe_type_key = 133
    LEFT JOIN observe_parm_opt o133 ON o133.obs_parm_code = t133.obs_parm_code AND o133.obs_parm_opt_code = c133.grade_code
    LEFT JOIN insp_condition c134 ON c134.insp_batch_no = inf.insp_batch_no AND c134.site_code = inf.site_code AND c134.plot_number = inf.plot_number AND c134.observe_type_key = 134
    LEFT JOIN observe_type t134   ON t134.observe_type_key = 134
    LEFT JOIN observe_parm_opt o134 ON o134.obs_parm_code = t134.obs_parm_code AND o134.obs_parm_opt_code = c134.grade_code
WHERE inf.feature_insp_date > TRUNC(SYSDATE - 7)
  AND feature.feature_deadflag = 'N'
  AND inf.officer_code IN ('SGC1','SGC2','SGC3','SGC4','SGC5','SGC6','SGC7','SGC8','SGC9','SGC0','SGCA')
  AND (   o130.obs_parm_opt_name LIKE '%Inaccessible%'
       OR o133.obs_parm_opt_name LIKE '%No Action%'
       OR o134.obs_parm_opt_name LIKE '%Slow%'
       OR o134.obs_parm_opt_name LIKE '%Non%')
```

Untested. Replace `TRUNC(SYSDATE - 7)` with `EffectiveDate() - 7` if the report will be scheduled.

## P4 – Current inspection plus the previous 3 for each flagged asset

Number each asset's inspections with
`ROW_NUMBER() OVER (PARTITION BY inf.site_code, inf.plot_number ORDER BY inf.feature_insp_date DESC, inf.insp_batch_no DESC)`
inside an inline view, flag the asset when row 1 meets the exception rule (`MAX(CASE …) OVER (PARTITION BY asset)`),
then keep rows 1–4. Build the observation joins inside it as in P3, using all three keys. The structure is the
SELECT-only version shared in the original conversation; that version still needs P2's three-key join applied.

## P5 – Current condition versus inspection history

| Question | Source |
|---|---|
| "What is this asset's condition now?" | `feat_cond_grade`: one row per feature and observation type |
| "What did the inspector record on date X?" or "the last N visits" | `insp_condition` + `inspection_feature`, ranked by `feature_insp_date` |
