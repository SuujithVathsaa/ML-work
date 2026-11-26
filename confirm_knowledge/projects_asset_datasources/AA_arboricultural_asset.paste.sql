SELECT
    site.site_code,
    site.site_class_code,
    central_site.site_name,
    central_site.site_address,
    feature.feature_location,
    feature.feature_type_code,
    feature_type.feature_type_name,
    feature_type.feature_group_code,
    feature.plot_number,
    feature.feature_id,
    feature.area_code,
    area.area_name,
    feature.ward_code,
    ward.ward_name,
    feature.central_asset_id,
    feature.feat_cent_east                 AS easting,
    feature.feat_cent_north                AS northing,
    meas.m_no_number_of,
    attr.a_talo_likely_owner,
    attr.a_talo_likely_owner_text,
    attr.a_tat_tree_asset_type,
    attr.a_tat_tree_asset_type_text,
    obs.o_wc_work_completed,
    obs.o_wc_work_completed_val,
    obs.o_tah_height,
    obs.o_tah_height_val,
    obs.o_tag_girth,
    obs.o_tag_girth_val,
    obs.o_tacs_crown_spread,
    obs.o_tacs_crown_spread_val,
    obs.o_taoc_overall_condition,
    obs.o_taoc_overall_condition_val,
    obs.o_tam_maturity,
    obs.o_tam_maturity_val
FROM feature
    JOIN feature_type          ON feature_type.feature_type_code = feature.feature_type_code
    LEFT JOIN site             ON site.site_code = feature.site_code
    LEFT JOIN central_site     ON central_site.site_code = feature.site_code
    LEFT JOIN area             ON area.area_code = feature.area_code
    LEFT JOIN ward             ON ward.ward_code = feature.ward_code
    LEFT JOIN (
        SELECT m.site_code, m.plot_number,
               MAX(m.feature_quantity) AS m_no_number_of
        FROM feat_measurement m
        WHERE m.measurement_code = 'NO'
        GROUP BY m.site_code, m.plot_number
    ) meas ON meas.site_code = feature.site_code AND meas.plot_number = feature.plot_number
    LEFT JOIN (
        SELECT a.site_code, a.plot_number,
               MAX(CASE WHEN a.attrib_type_code = 'TALO' THEN av.attrib_value_name END) AS a_talo_likely_owner,
               MAX(CASE WHEN a.attrib_type_code = 'TALO' THEN a.feat_attrib_notes END)  AS a_talo_likely_owner_text,
               MAX(CASE WHEN a.attrib_type_code = 'TAT'  THEN av.attrib_value_name END) AS a_tat_tree_asset_type,
               MAX(CASE WHEN a.attrib_type_code = 'TAT'  THEN a.feat_attrib_notes END)  AS a_tat_tree_asset_type_text
        FROM feat_attrib_type a
            LEFT JOIN attribute_value av ON av.attrib_type_code = a.attrib_type_code AND av.attrib_value_code = a.attrib_value_code
        WHERE a.attrib_type_code IN ('TALO', 'TAT')
        GROUP BY a.site_code, a.plot_number
    ) attr ON attr.site_code = feature.site_code AND attr.plot_number = feature.plot_number
    LEFT JOIN (
        SELECT c.site_code, c.plot_number,
               MAX(CASE WHEN ot.observe_type_code = 'WC'   THEN op.obs_parm_opt_name END) AS o_wc_work_completed,
               MAX(CASE WHEN ot.observe_type_code = 'WC'   THEN c.survey_obs_value END)   AS o_wc_work_completed_val,
               MAX(CASE WHEN ot.observe_type_code = 'TAH'  THEN op.obs_parm_opt_name END) AS o_tah_height,
               MAX(CASE WHEN ot.observe_type_code = 'TAH'  THEN c.survey_obs_value END)   AS o_tah_height_val,
               MAX(CASE WHEN ot.observe_type_code = 'TAG'  THEN op.obs_parm_opt_name END) AS o_tag_girth,
               MAX(CASE WHEN ot.observe_type_code = 'TAG'  THEN c.survey_obs_value END)   AS o_tag_girth_val,
               MAX(CASE WHEN ot.observe_type_code = 'TACS' THEN op.obs_parm_opt_name END) AS o_tacs_crown_spread,
               MAX(CASE WHEN ot.observe_type_code = 'TACS' THEN c.survey_obs_value END)   AS o_tacs_crown_spread_val,
               MAX(CASE WHEN ot.observe_type_code = 'TAOC' THEN op.obs_parm_opt_name END) AS o_taoc_overall_condition,
               MAX(CASE WHEN ot.observe_type_code = 'TAOC' THEN c.survey_obs_value END)   AS o_taoc_overall_condition_val,
               MAX(CASE WHEN ot.observe_type_code = 'TAM'  THEN op.obs_parm_opt_name END) AS o_tam_maturity,
               MAX(CASE WHEN ot.observe_type_code = 'TAM'  THEN c.survey_obs_value END)   AS o_tam_maturity_val
        FROM feat_cond_grade c
            JOIN observe_type ot         ON ot.observe_type_key = c.observe_type_key
            LEFT JOIN observe_parm_opt op ON op.obs_parm_code = ot.obs_parm_code AND op.obs_parm_opt_code = c.grade_code
        WHERE ot.observe_type_code IN ('WC', 'TAH', 'TAG', 'TACS', 'TAOC', 'TAM')
        GROUP BY c.site_code, c.plot_number
    ) obs ON obs.site_code = feature.site_code AND obs.plot_number = feature.plot_number
WHERE feature_type.feature_group_code = 'AA'
  AND feature.feature_deadflag = 'N'
