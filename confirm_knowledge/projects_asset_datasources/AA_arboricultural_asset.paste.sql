SELECT
    site.site_code,
    site.site_class_code,
    central_site.site_name,
    central_site.display_address,
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
    m_no.feature_quantity                  AS m_no_number_of,
    av_talo.attrib_value_name              AS a_talo_likely_owner,
    a_talo.feat_attrib_notes               AS a_talo_likely_owner_text,
    av_tat.attrib_value_name               AS a_tat_tree_asset_type,
    a_tat.feat_attrib_notes                AS a_tat_tree_asset_type_text,
    op_wc.obs_parm_opt_name                AS o_wc_work_completed,
    c_wc.survey_obs_value                  AS o_wc_work_completed_val,
    op_tah.obs_parm_opt_name               AS o_tah_height,
    c_tah.survey_obs_value                 AS o_tah_height_val,
    op_tag.obs_parm_opt_name               AS o_tag_girth,
    c_tag.survey_obs_value                 AS o_tag_girth_val,
    op_tacs.obs_parm_opt_name              AS o_tacs_crown_spread,
    c_tacs.survey_obs_value                AS o_tacs_crown_spread_val,
    op_taoc.obs_parm_opt_name              AS o_taoc_overall_condition,
    c_taoc.survey_obs_value                AS o_taoc_overall_condition_val,
    op_tam.obs_parm_opt_name               AS o_tam_maturity,
    c_tam.survey_obs_value                 AS o_tam_maturity_val
FROM feature
    JOIN feature_type          ON feature_type.feature_type_code = feature.feature_type_code
    LEFT JOIN site             ON site.site_code = feature.site_code
    LEFT JOIN central_site     ON central_site.site_code = feature.site_code
    LEFT JOIN area             ON area.area_code = feature.area_code
    LEFT JOIN ward             ON ward.ward_code = feature.ward_code
    LEFT JOIN feat_measurement m_no ON m_no.site_code = feature.site_code AND m_no.plot_number = feature.plot_number AND m_no.measurement_code = 'NO'
    LEFT JOIN feat_attrib_type a_talo ON a_talo.site_code = feature.site_code AND a_talo.plot_number = feature.plot_number AND a_talo.attrib_type_code = 'TALO'
    LEFT JOIN attribute_value av_talo ON av_talo.attrib_type_code = a_talo.attrib_type_code AND av_talo.attrib_value_code = a_talo.attrib_value_code
    LEFT JOIN feat_attrib_type a_tat ON a_tat.site_code = feature.site_code AND a_tat.plot_number = feature.plot_number AND a_tat.attrib_type_code = 'TAT'
    LEFT JOIN attribute_value av_tat ON av_tat.attrib_type_code = a_tat.attrib_type_code AND av_tat.attrib_value_code = a_tat.attrib_value_code
    LEFT JOIN observe_type ot_wc ON ot_wc.observe_type_code = 'WC'
    LEFT JOIN feat_cond_grade c_wc ON c_wc.site_code = feature.site_code AND c_wc.plot_number = feature.plot_number AND c_wc.observe_type_key = ot_wc.observe_type_key
    LEFT JOIN observe_parm_opt op_wc ON op_wc.obs_parm_code = ot_wc.obs_parm_code AND op_wc.obs_parm_opt_code = c_wc.grade_code
    LEFT JOIN observe_type ot_tah ON ot_tah.observe_type_code = 'TAH'
    LEFT JOIN feat_cond_grade c_tah ON c_tah.site_code = feature.site_code AND c_tah.plot_number = feature.plot_number AND c_tah.observe_type_key = ot_tah.observe_type_key
    LEFT JOIN observe_parm_opt op_tah ON op_tah.obs_parm_code = ot_tah.obs_parm_code AND op_tah.obs_parm_opt_code = c_tah.grade_code
    LEFT JOIN observe_type ot_tag ON ot_tag.observe_type_code = 'TAG'
    LEFT JOIN feat_cond_grade c_tag ON c_tag.site_code = feature.site_code AND c_tag.plot_number = feature.plot_number AND c_tag.observe_type_key = ot_tag.observe_type_key
    LEFT JOIN observe_parm_opt op_tag ON op_tag.obs_parm_code = ot_tag.obs_parm_code AND op_tag.obs_parm_opt_code = c_tag.grade_code
    LEFT JOIN observe_type ot_tacs ON ot_tacs.observe_type_code = 'TACS'
    LEFT JOIN feat_cond_grade c_tacs ON c_tacs.site_code = feature.site_code AND c_tacs.plot_number = feature.plot_number AND c_tacs.observe_type_key = ot_tacs.observe_type_key
    LEFT JOIN observe_parm_opt op_tacs ON op_tacs.obs_parm_code = ot_tacs.obs_parm_code AND op_tacs.obs_parm_opt_code = c_tacs.grade_code
    LEFT JOIN observe_type ot_taoc ON ot_taoc.observe_type_code = 'TAOC'
    LEFT JOIN feat_cond_grade c_taoc ON c_taoc.site_code = feature.site_code AND c_taoc.plot_number = feature.plot_number AND c_taoc.observe_type_key = ot_taoc.observe_type_key
    LEFT JOIN observe_parm_opt op_taoc ON op_taoc.obs_parm_code = ot_taoc.obs_parm_code AND op_taoc.obs_parm_opt_code = c_taoc.grade_code
    LEFT JOIN observe_type ot_tam ON ot_tam.observe_type_code = 'TAM'
    LEFT JOIN feat_cond_grade c_tam ON c_tam.site_code = feature.site_code AND c_tam.plot_number = feature.plot_number AND c_tam.observe_type_key = ot_tam.observe_type_key
    LEFT JOIN observe_parm_opt op_tam ON op_tam.obs_parm_code = ot_tam.obs_parm_code AND op_tam.obs_parm_opt_code = c_tam.grade_code
WHERE feature_type.feature_group_code = 'AA'
  AND feature.feature_deadflag = 'N'
