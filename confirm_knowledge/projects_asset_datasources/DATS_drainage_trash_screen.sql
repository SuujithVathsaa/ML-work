/* =====================================================================
   Information Team – Drainage Asset - Trash Screen   (feature group DATS)
   ---------------------------------------------------------------------
   Platform : Oracle (Confirm data source - paste from SELECT onwards;
              the editor rejects anything that does not start with SELECT,
              so remove this comment block before pasting).
   Grain    : one row per live feature (feature PK = site_code, plot_number).

   Why no duplicate rows:
     Measurements, attributes and observations are each pre-aggregated in an
     inline view GROUPed BY site_code, plot_number, so each view returns at
     most one row per feature whatever the child tables hold. The remaining
     joins (feature_type, site, central_site, area, ward) are on primary keys.
     The earlier version joined observe_type ON observe_type_code = 'XX'; if a
     code exists on more than one observe_type row, that join repeated every
     feature, so observe_type is now joined on its key inside the view.
     If a feature really has two values for one code, MAX keeps one of them.
     Missing values come back NULL; the feature is never dropped.

   Assumptions to check on the first run:
     A1 'DATS' is a feature GROUP code (feature_type.feature_group_code).
        If the query returns 0 rows, change the last-but-one line to
        feature.feature_type_code = 'DATS'.
     A2 Resolved: central_site.display_address does not exist (ORA-00904),
        so the query uses central_site.site_address.
     A4 Observations = the feature's CURRENT condition (feat_cond_grade).
        For the value from the latest inspection use insp_condition instead.
   ===================================================================== */
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
    attr.a_dafd_direction_of_flow,
    attr.a_dafd_direction_of_flow_text,
    attr.a_down_likely_ownership,
    attr.a_down_likely_ownership_text,
    attr.a_tmr_traffic_management,
    attr.a_tmr_traffic_management_text,
    obs.o_sh02_confined_space,
    obs.o_sh04_deep_water,
    obs.o_sh05_difficult_access,
    obs.o_gci_asset_condition_info,
    obs.o_sloa_silt_level_on_arrival,
    obs.o_gcon_gully_containments
FROM feature
    JOIN feature_type          ON feature_type.feature_type_code = feature.feature_type_code
    LEFT JOIN site             ON site.site_code = feature.site_code
    LEFT JOIN central_site     ON central_site.site_code = feature.site_code
    LEFT JOIN area             ON area.area_code = feature.area_code
    LEFT JOIN ward             ON ward.ward_code = feature.ward_code
    LEFT JOIN (
        SELECT a.site_code, a.plot_number,
               MAX(CASE WHEN a.attrib_type_code = 'DAFD' THEN av.attrib_value_name END) AS a_dafd_direction_of_flow,
               MAX(CASE WHEN a.attrib_type_code = 'DAFD' THEN a.feat_attrib_notes END)  AS a_dafd_direction_of_flow_text,
               MAX(CASE WHEN a.attrib_type_code = 'DOWN' THEN av.attrib_value_name END) AS a_down_likely_ownership,
               MAX(CASE WHEN a.attrib_type_code = 'DOWN' THEN a.feat_attrib_notes END)  AS a_down_likely_ownership_text,
               MAX(CASE WHEN a.attrib_type_code = 'TMR'  THEN av.attrib_value_name END) AS a_tmr_traffic_management,
               MAX(CASE WHEN a.attrib_type_code = 'TMR'  THEN a.feat_attrib_notes END)  AS a_tmr_traffic_management_text
        FROM feat_attrib_type a
            LEFT JOIN attribute_value av ON av.attrib_type_code = a.attrib_type_code AND av.attrib_value_code = a.attrib_value_code
        WHERE a.attrib_type_code IN ('DAFD', 'DOWN', 'TMR')
        GROUP BY a.site_code, a.plot_number
    ) attr ON attr.site_code = feature.site_code AND attr.plot_number = feature.plot_number
    LEFT JOIN (
        SELECT c.site_code, c.plot_number,
               MAX(CASE WHEN ot.observe_type_code = 'SH02' THEN op.obs_parm_opt_name END) AS o_sh02_confined_space,
               MAX(CASE WHEN ot.observe_type_code = 'SH04' THEN op.obs_parm_opt_name END) AS o_sh04_deep_water,
               MAX(CASE WHEN ot.observe_type_code = 'SH05' THEN op.obs_parm_opt_name END) AS o_sh05_difficult_access,
               MAX(CASE WHEN ot.observe_type_code = 'GCI'  THEN op.obs_parm_opt_name END) AS o_gci_asset_condition_info,
               MAX(CASE WHEN ot.observe_type_code = 'SLOA' THEN op.obs_parm_opt_name END) AS o_sloa_silt_level_on_arrival,
               MAX(CASE WHEN ot.observe_type_code = 'GCON' THEN op.obs_parm_opt_name END) AS o_gcon_gully_containments
        FROM feat_cond_grade c
            JOIN observe_type ot         ON ot.observe_type_key = c.observe_type_key
            LEFT JOIN observe_parm_opt op ON op.obs_parm_code = ot.obs_parm_code AND op.obs_parm_opt_code = c.grade_code
        WHERE ot.observe_type_code IN ('SH02', 'SH04', 'SH05', 'GCI', 'SLOA', 'GCON')
        GROUP BY c.site_code, c.plot_number
    ) obs ON obs.site_code = feature.site_code AND obs.plot_number = feature.plot_number
WHERE feature_type.feature_group_code = 'DATS'
  AND feature.feature_deadflag = 'N'
