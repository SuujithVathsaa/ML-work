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
    meas.m_s009_construction_length,
    meas.m_s012_width,
    meas.m_s013_span_area,
    meas.m_s014_no_construction_forms,
    attr.a_rwc1_structural_form,
    attr.a_rwc1_structural_form_text,
    attr.a_rwc2_material_type,
    attr.a_rwc2_material_type_text
FROM feature
    JOIN feature_type          ON feature_type.feature_type_code = feature.feature_type_code
    LEFT JOIN site             ON site.site_code = feature.site_code
    LEFT JOIN central_site     ON central_site.site_code = feature.site_code
    LEFT JOIN area             ON area.area_code = feature.area_code
    LEFT JOIN ward             ON ward.ward_code = feature.ward_code
    LEFT JOIN (
        SELECT m.site_code, m.plot_number,
               MAX(CASE WHEN m.measurement_code = 'S009' THEN m.feature_quantity END) AS m_s009_construction_length,
               MAX(CASE WHEN m.measurement_code = 'S012' THEN m.feature_quantity END) AS m_s012_width,
               MAX(CASE WHEN m.measurement_code = 'S013' THEN m.feature_quantity END) AS m_s013_span_area,
               MAX(CASE WHEN m.measurement_code = 'S014' THEN m.feature_quantity END) AS m_s014_no_construction_forms
        FROM feat_measurement m
        WHERE m.measurement_code IN ('S009', 'S012', 'S013', 'S014')
        GROUP BY m.site_code, m.plot_number
    ) meas ON meas.site_code = feature.site_code AND meas.plot_number = feature.plot_number
    LEFT JOIN (
        SELECT a.site_code, a.plot_number,
               MAX(CASE WHEN a.attrib_type_code = 'RWC1' THEN av.attrib_value_name END) AS a_rwc1_structural_form,
               MAX(CASE WHEN a.attrib_type_code = 'RWC1' THEN a.feat_attrib_notes END)  AS a_rwc1_structural_form_text,
               MAX(CASE WHEN a.attrib_type_code = 'RWC2' THEN av.attrib_value_name END) AS a_rwc2_material_type,
               MAX(CASE WHEN a.attrib_type_code = 'RWC2' THEN a.feat_attrib_notes END)  AS a_rwc2_material_type_text
        FROM feat_attrib_type a
            LEFT JOIN attribute_value av ON av.attrib_type_code = a.attrib_type_code AND av.attrib_value_code = a.attrib_value_code
        WHERE a.attrib_type_code IN ('RWC1', 'RWC2')
        GROUP BY a.site_code, a.plot_number
    ) attr ON attr.site_code = feature.site_code AND attr.plot_number = feature.plot_number
WHERE feature_type.feature_group_code = 'SRWP'
  AND feature.feature_deadflag = 'N'
