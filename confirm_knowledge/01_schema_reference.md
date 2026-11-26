# Confirm schema reference

PK = primary key. "→" = join. The tags are explained in `README.md`.

## Sites (manual p.93 – Site Register)

| Table | PK | Useful columns |
|---|---|---|
| `central_site` | `site_code` | `site_name`, `area_code`, `ward_code`, `site_address`, `site_cent_east`, `site_cent_north`, `site_ext_1_easting`/`_north`, `site_ext_2_easting`/`_north`, `site_start_date`, `site_end_date`, `site_deadflag`, `street_type_code`, `locality_id` |
| `site` | `site_code` | `site_class_code`, `plan_number`, `contract_area_code`, `customer_code`, `cost_code`, `site_notes` |
| `site_class` | `site_class_code` | `site_class_name` |
| `area` | `area_code` | `area_name` **[manual p.93, live]** |
| `ward` | `ward_code` | `ward_name` **[manual p.93, live]** |
| `locality`, `town`, `county` | `locality_id`, `town_id`, `county_id` | names |

- `central_site.display_address` **does not exist [live]**: it raises ORA-00904. Use `central_site.site_address`.

## Features / assets (manual p.94 – Asset Register, p.107)

| Table | PK | Useful columns |
|---|---|---|
| `feature` | `site_code, plot_number` | `feature_id`, `central_asset_id`, `feature_key`, `feature_location`, `feature_type_code`, `site_class_code`, `area_code`, `ward_code`, `feature_deadflag` ('N' = live **[live]**), `feature_start_date`, `feature_end_date`, `feature_notes`, `survey_date`, `feat_cent_east`, `feat_cent_north`, `feat_cent_alt`, `feat_ext_1_easting`, `feat_ext_1_north`, `feat_ext_2_easting`, `feat_ext_2_north`, `sp_geography`, `asset_cat_code`, `hierarchy_code`, `cost_code`, `contract_area_code`, `customer_code`, `active_from_date`, `active_to_date`, valuation columns |
| `feature_type` | `feature_type_code` | `feature_type_name`, **`feature_group_code`**, `asset_cat_code`, `hierarchy_code` |
| `feature_group` | `feature_group_code` | `feature_group_name`, `measurement_code` (primary measurement), `map_layer_key` |
| `feature_cross_ref` | `cross_ref_key` | links between features |
| `feature_document` | `site_code, plot_number, document_number` | `document_path`, `blob_data_key` |

## Measurements, attributes and dates (manual p.94)

| Table | PK | Columns | Meaning |
|---|---|---|---|
| `feat_measurement` | `site_code, plot_number, measurement_code` | `feature_quantity`, `estimated_flag` | A feature's measurement value. At most one row per code. |
| `measurement_type` | `measurement_code` | `measurement_name`, `unit_code`, `measurement_order` | Lookup |
| `group_measure_type` | `feature_group_code, measurement_code` | `show_on_order` | Which measurements a feature group uses. This is the workbook's "Group Measure Types". |
| `feat_attrib_type` | `site_code, plot_number, attrib_type_code` | `attrib_value_code` (pick list), `feat_attrib_notes` (free text) | A feature's attribute value. At most one row per code. |
| `attribute_type` | `attrib_type_code` | `attrib_type_name`, `attrib_type_flag` (pick/text/number **[assumed]**), `unit_code`, `attrib_num_dps`, `attrib_type_desc` | Lookup |
| `attribute_value` | `attrib_type_code, attrib_value_code` | `attrib_value_name`, `attrib_value_order`, `attrib_value_dead` | Pick-list values |
| `group_attribute` | `feature_group_code, attrib_type_code` | `group_attrib_mand` (the workbook's "required"), `show_on_order` | This is the workbook's "Group Attributes". |
| `feature_date` | `site_code, plot_number, date_type_code` | `feature_date`, notes | Date attributes |
| `date_type` / `group_date` | | | Lookups |
| `feat_smart_attrib` | `site_code, plot_number, smart_type_code` | `smart_value_code` | Smart attributes |

## Observations / condition (manual p.100, p.107)

| Table | PK | Columns | Meaning |
|---|---|---|---|
| `observe_type` | `observe_type_key` | **`observe_type_code`** (e.g. GACC), `observe_type_name`, `observe_type_desc`, `observe_type_dead`, `obs_parm_code`, `observe_type_flag` | Observation type. The workbook uses codes; inspections store keys. |
| `observe_type_feat` | `observe_type_key, feature_group_code` | `import_defect_code` … | The workbook's "Observation Type Feature Groups". |
| `observe_parameter` | `obs_parm_code` | `obs_parm_name`, `unit_code`, min/max, `measurement_code` | The value scale |
| `observe_parm_opt` | `obs_parm_code, obs_parm_opt_code` | `obs_parm_opt_name`, `obs_parm_opt_desc`, min/max | Grade names |
| **`feat_cond_grade`** | `site_code, plot_number, observe_type_key` | `grade_code`, `survey_obs_value`, `condition_notes` | The feature's **current** condition per observation type. The Web API's `featureConditions` writes here. |
| `insp_condition` | `insp_batch_no, site_code, plot_number, observe_type_key` | `grade_code`, `survey_obs_value`, `condition_notes` | Observation recorded in one inspection (history) |
| `inspection_feature` | `insp_batch_no, site_code, plot_number` | `officer_code`, `feature_insp_date`, `feature_expy_date`, `insp_due_date` | One feature in one inspection batch |
| `inspection_batch` | `insp_batch_no` | `insp_batch_name`, `insp_route_code`, `officer_code`, `insp_create_date`, `insp_comp_date` | One batch can hold **many** features |
| `inspection_route`, `insp_route_feat`, `inspection_type`, `inspect_type_cond` | | | Routes and inspection types |
| `survey`, `survey_feature`, `survey_observation`, `survey_type` | | | Network Manager condition surveys (p.100) |

## People, jobs and defects (manual p.104, p.107)

- `action_officer`: PK `officer_code`. Columns `officer_name`, `login_name`, `inactive_flag`.
- `job`: PK `job_number`. Columns `site_code`, `plot_number`, `job_entry_date`, `job_status_flag`, `priority_code`, `job_type_key`, `job_easting`, `job_northing`.
- Related job tables: `job_status_log`, `job_item`, `job_type`, `job_status`.
- `defect`: PK `defect_number`. Columns `insp_batch_no`, `site_code`, `plot_number`, `defect_date`, `defect_type`, `defect_easting`, `defect_northing`, `observe_type_key`, `job_number`.
- Related defect tables: `defect_type`, `defect_attribute`.

## Core joins

```
feature.feature_type_code      → feature_type.feature_type_code
feature_type.feature_group_code→ feature_group.feature_group_code
feature.site_code              → central_site.site_code   [live]
feature.site_code              → site.site_code
feature.area_code / ward_code  → area.area_code / ward.ward_code
central_site.area_code/ward_code → area / ward             [live]
feat_* (site_code, plot_number)→ feature (site_code, plot_number)
insp_condition (insp_batch_no, site_code, plot_number) → inspection_feature (same 3 columns)
inspection_feature.insp_batch_no → inspection_batch.insp_batch_no
*.observe_type_key → observe_type;  observe_type.obs_parm_code → observe_parameter
observe_parm_opt (obs_parm_code, obs_parm_opt_code) ← (observe_type.obs_parm_code, <table>.grade_code)
```

## Coordinates

- **Point:** `feature.feat_cent_east` and `feature.feat_cent_north` (the centroid).
- **Line extents:** `feat_ext_1_*` and `feat_ext_2_*`.
- **Full shape:** `feature.sp_geography`.
- The Web API says easting and northing follow the coordinate system in Map System Settings, and that the
  geometry is WGS84 WKT **[api]**.
- The manual says a Data Source with Easting and Northing columns can be shown on the Confirm map, and that those
  columns override the feature's geometry **[manual p.68]**.
