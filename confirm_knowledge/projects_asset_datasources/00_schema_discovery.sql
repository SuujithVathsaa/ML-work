/* =====================================================================
   Confirm schema discovery - run BEFORE the asset data sources are built
   ---------------------------------------------------------------------
   Platform: Oracle (inferred from the working gully report, which uses
   SYSDATE, TRUNC and (+) outer joins).

   Run each statement separately in SQL Developer / Toad (or as a throw-
   away Confirm data source - each one starts with SELECT). Export the
   results and send them back: they replace every [PLACEHOLDER] in the
   asset queries with documented column names instead of guesses.
   ===================================================================== */


/* D1. Columns of the tables we already know about, plus any table/view
       whose name suggests measurements, attributes, geometry or areas.  */
SELECT owner,
       table_name,
       column_id,
       column_name,
       data_type,
       data_length,
       nullable
FROM   all_tab_columns
WHERE  table_name IN ('SITE', 'CENTRAL_SITE', 'FEATURE', 'FEATURE_TYPE',
                      'AREA', 'WARD',
                      'INSPECTION_FEATURE', 'INSPECTION_BATCH', 'INSP_CONDITION',
                      'OBSERVE_TYPE', 'OBSERVE_PARAMETER', 'OBSERVE_PARM_OPT')
   OR  table_name LIKE '%ATTRIB%'
   OR  table_name LIKE '%MEAS%'
   OR  table_name LIKE '%GEOM%'
   OR  table_name LIKE '%SPATIAL%'
   OR  table_name LIKE 'FEATURE%'
   OR  table_name LIKE 'AREA%'
ORDER  BY owner, table_name, column_id;


/* D2. Primary keys and foreign keys on the same tables
       (Confirm may not declare every FK - an empty result is still useful). */
SELECT c.table_name,
       c.constraint_name,
       c.constraint_type,
       cc.position,
       cc.column_name,
       r.table_name AS references_table
FROM   all_constraints c,
       all_cons_columns cc,
       all_constraints r
WHERE  cc.owner = c.owner
  AND  cc.constraint_name = c.constraint_name
  AND  r.owner (+) = c.r_owner
  AND  r.constraint_name (+) = c.r_constraint_name
  AND  c.constraint_type IN ('P', 'R', 'U')
  AND  (   c.table_name IN ('SITE', 'CENTRAL_SITE', 'FEATURE', 'FEATURE_TYPE',
                            'AREA', 'WARD', 'INSPECTION_FEATURE', 'INSP_CONDITION',
                            'OBSERVE_TYPE', 'OBSERVE_PARAMETER', 'OBSERVE_PARM_OPT')
        OR c.table_name LIKE '%ATTRIB%'
        OR c.table_name LIKE '%MEAS%')
ORDER  BY c.table_name, c.constraint_type, c.constraint_name, cc.position;


/* D3. Does one inspection batch ever cover more than one feature?
       If multi_feature_batches > 0, observations joined on insp_batch_no
       alone can be attached to the wrong gully.                           */
SELECT COUNT(*)                                   AS batches,
       SUM(CASE WHEN n > 1 THEN 1 ELSE 0 END)     AS multi_feature_batches,
       MAX(n)                                     AS max_features_in_a_batch
FROM   (SELECT insp_batch_no, COUNT(*) AS n
        FROM   inspection_feature
        GROUP  BY insp_batch_no);


/* D4. Observation types - shows which column holds the workbook code
       (e.g. GACC / ACT / GSOD) next to the numeric observe_type_key
       (130 / 133 / 134 in the existing gully report).                    */
SELECT ot.*
FROM   observe_type ot
WHERE  ot.observe_type_key IN (130, 133, 134);


/* D5. Can a feature hold more than one row for the same code?
       Replace [ATTRIBUTE_TABLE] / [ATTRIBUTE_TYPE_CODE_FIELD] once D1 shows
       the real names, then repeat for the measurement table.             */
SELECT COUNT(*) AS features_with_repeated_code
FROM   (SELECT site_code, plot_number, [ATTRIBUTE_TYPE_CODE_FIELD]
        FROM   [ATTRIBUTE_TABLE]
        GROUP  BY site_code, plot_number, [ATTRIBUTE_TYPE_CODE_FIELD]
        HAVING COUNT(*) > 1);


/* D6. Feature-type codes in use - confirms the workbook codes
       (AA, DAGA, STBR ...) are feature.feature_type_code values.          */
SELECT f.feature_type_code,
       COUNT(*) AS features
FROM   feature f
WHERE  f.feature_type_code IN ('AA', 'DATS', 'DAGA', 'STBR', 'SRWP', 'STRW',
                               'STDM', 'SPAN', 'WGBC', 'WGPC', 'DAMA', 'DALA')
GROUP  BY f.feature_type_code
ORDER  BY f.feature_type_code;
