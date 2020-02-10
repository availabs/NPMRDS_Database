\set tmc_id 'tmc':NPMRDS_SHP_YR'id'
\set ris_id 'ris':YR'id'
\set mview_name 'conflation.conflation_map_v':CONFLATION_MAP_VERSION'_ris_based_aadt_20':YR
\set mview_idx_name 'conflation_map_v':CONFLATION_MAP_VERSION'_ris_based_aadt_20':YR'_pkey'

BEGIN;

DROP MATERIALIZED VIEW IF EXISTS :mview_name;

CREATE MATERIALIZED VIEW :mview_name
AS
  SELECT
      tmc,
      ROUND(
        (
          SUM( aadt_ris * conflmap_len_ft )
          /
          SUM( conflmap_len_ft * NULLIF(aadt_ris::BOOLEAN::INT, 0) )
        )::NUMERIC
      ) AS aadt_ris,
      ROUND(
        (
          SUM( aadt_singl_ris * conflmap_len_ft )
          /
          SUM( conflmap_len_ft * NULLIF(aadt_singl_ris::BOOLEAN::INT, 0) )
        )::NUMERIC
      ) AS aadt_singl_ris,
      ROUND(
        (
          SUM( aadt_combi_ris * conflmap_len_ft )
          /
          SUM( conflmap_len_ft * NULLIF(aadt_combi_ris::BOOLEAN::INT, 0) )
        )::NUMERIC
      ) AS aadt_combi_ris,
      json_build_object(
       'npmrds_len_ft',
       MAX(npmrds_len_ft),
       'ris_metadata',
       json_object_agg(
         COALESCE(ris_id, -1)::TEXT,
         json_build_object(
           'aadt_ris',
           aadt_ris,
           'conflmap_len_ft',
           conflmap_len_ft
         )
         ORDER BY ris_id
       )
      ) AS qa_metadata
    FROM (
      SELECT
          t.tmc,                                 -- 1
          t.miles * 5280 AS npmrds_len_ft,       -- 2
          c.:ris_id AS ris_id,                   -- 3
          r.aadt_current_yr_est AS aadt_ris,     -- 4
          r.aadt_single_unit AS aadt_singl_ris,  -- 5
          r.aadt_combo AS aadt_combi_ris,        -- 6
          SUM (
            ST_LENGTH(
              GEOGRAPHY(c.wkb_geometry)
            ) * 3.28084
          ) AS conflmap_len_ft
        FROM conflation.conflation_map_v:CONFLATION_MAP_VERSION AS c
          INNER JOIN tmc_metadata_20:YR AS t
            ON (:tmc_id = tmc)
          LEFT OUTER JOIN ris.road_inventory_system_20:YR AS r
            ON (:ris_id = ogc_fid)
        GROUP BY 1,2,3,4,5,6
    ) AS t
    GROUP BY tmc
;

CREATE UNIQUE INDEX :mview_idx_name ON :mview_name (tmc);

CLUSTER :mview_name USING :mview_idx_name;

COMMIT;

ANALYZE :mview_name;
