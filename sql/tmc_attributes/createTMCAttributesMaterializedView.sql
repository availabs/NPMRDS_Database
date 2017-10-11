/* This view will be used to partition the attribute tables by state. */
BEGIN;

CREATE MATERIALIZED VIEW tmc_attributes
  WITH (fillfactor = 100) AS 
    WITH cte_tmc_cbsa_intersections AS (
      SELECT
          tmc,
          geoid AS cbsa_code,
          name AS cbsa_name,
          ST_Length(
            ST_Intersection(
              tmc_shp.wkb_geometry,
              cbsa_shp.wkb_geometry
            )
          ) AS intersection_len
        FROM inrix_shapefile AS tmc_shp
          INNER JOIN core_based_statistical_area_boundaries AS cbsa_shp
          ON (
            ST_Intersects(
              tmc_shp.wkb_geometry,
              cbsa_shp.wkb_geometry
            )
          )
    ), cte_tmc_to_cbsa AS (
      SELECT
          tmc,
          cbsa_code,
          cbsa_name
        FROM cte_tmc_cbsa_intersections
        WHERE (tmc, intersection_len) IN (
          SELECT
              tmc,
              MAX(intersection_len)
            FROM cte_tmc_cbsa_intersections
            GROUP BY tmc
        )
    ), cte_tmc_mpo_intersections AS (
      SELECT
          tmc,
          mpo_id AS mpo_code,
          mpo_name,
          ST_Length(
            ST_Intersection(
              tmc_shp.wkb_geometry,
              mpo_shp.wkb_geometry
            )
          ) AS intersection_len
        FROM inrix_shapefile AS tmc_shp
          INNER JOIN mpo_boundaries AS mpo_shp
          ON (
            ST_Intersects(
              tmc_shp.wkb_geometry,
              mpo_shp.wkb_geometry
            )
          )
    ), cte_tmc_to_mpo AS (
      SELECT
          tmc,
          mpo_code,
          mpo_name
        FROM cte_tmc_mpo_intersections
        WHERE (tmc, intersection_len) IN (
          SELECT
              tmc,
              MAX(intersection_len)
            FROM cte_tmc_mpo_intersections
            GROUP BY tmc
        )
    ) 
    SELECT
        inrix_shapefile.tmc,
        inrix_shapefile.tmctype,
        inrix_shapefile.roadnumber,
        inrix_shapefile.roadname,
        inrix_shapefile.firstname,
        inrix_shapefile.tmclinear,
        inrix_shapefile.country,
        inrix_shapefile.state AS statename, -- Because of name collision with the abbreviation
        inrix_shapefile.county,
        inrix_shapefile.zip,
        inrix_shapefile.direction,
        inrix_shapefile.startlat,
        inrix_shapefile.startlong,
        inrix_shapefile.endlat,
        inrix_shapefile.endlong,
        inrix_shapefile.miles,
        inrix_shapefile.frc,
        inrix_shapefile.border_set,
        inrix_shapefile.f_system,
        inrix_shapefile.urban_code,
        inrix_shapefile.faciltype,
        inrix_shapefile.structype,
        inrix_shapefile.thrulanes,
        inrix_shapefile.route_numb,
        inrix_shapefile.route_sign,
        inrix_shapefile.route_qual,
        inrix_shapefile.altrtename,
        inrix_shapefile.aadt,
        inrix_shapefile.aadt_singl,
        inrix_shapefile.aadt_combi,
        inrix_shapefile.nhs,
        inrix_shapefile.nhs_pct,
        inrix_shapefile.strhnt_typ,
        inrix_shapefile.strhnt_pct,
        inrix_shapefile.truck,

        -- HERE backwards compatibility
        'USA'::VARCHAR AS admin_level_1,
        inrix_shapefile.state AS admin_level_2,
        inrix_shapefile.county AS admin_level_3,

        inrix_shapefile.miles AS distance,
        inrix_shapefile.miles AS length,

        inrix_shapefile.roadnumber AS road_number,
        inrix_shapefile.roadname AS road_name,

        inrix_shapefile.startlat AS latitude,
        inrix_shapefile.startlong AS longitude,

        CASE inrix_shapefile.direction
          WHEN 'N' THEN 'Northbound'
          WHEN 'E' THEN 'Eastbound'
          WHEN 'S' THEN 'Southbound'
          WHEN 'W' THEN 'Westbound'
          ELSE NULL
        END AS road_direction,

        -- Make it easy to get the occupancy_factor
        occupancy_factor.occupancy_factor,

        state_abbreviations.abbreviation AS state,

        (f_system = 1) AS is_interstate,
        ((f_system = 1) OR (f_system = 2)) AS is_controlled_access,

        avg_speedlimit,

        cte_tmc_to_cbsa.cbsa_code,
        cte_tmc_to_cbsa.cbsa_name,

        cte_tmc_to_mpo.mpo_code,
        cte_tmc_to_mpo.mpo_name,

        inrix_shapefile.urban_code AS ua_code,
        ua.name10 AS ua_name,

        regions.id AS region_code,
        regions.name AS region_name

    FROM inrix_shapefile
      LEFT OUTER JOIN state_abbreviations
        ON (inrix_shapefile.state = state_abbreviations.state_name)
      LEFT OUTER JOIN occupancy_factor
        ON (
          (state_abbreviations.abbreviation = occupancy_factor.state)
          AND (inrix_shapefile.county = occupancy_factor.geography_level_name)
          AND (occupancy_factor.geography_level = 'COUNTY')
        )
      LEFT OUTER JOIN avg_speedlimits
        USING (tmc)
      LEFT OUTER JOIN cte_tmc_to_cbsa
        USING (tmc)
      LEFT OUTER JOIN cte_tmc_to_mpo
        USING (tmc)
      LEFT OUTER JOIN urban_area_boundaries AS ua
        ON (LPAD(inrix_shapefile.urban_code::text, 5) = ua.geoid10)
      LEFT OUTER JOIN region_to_county AS r_to_c
        ON (
          (inrix_shapefile.county = r_to_c.county)
          AND
          (state_abbreviations.abbreviation = r_to_c.state)
        )
      LEFT OUTER JOIN regions
        ON (r_to_c.region_id = regions.id)

    WITH NO DATA
;

REFRESH MATERIALIZED VIEW tmc_attributes;

CREATE INDEX IF NOT EXISTS static_file_data_idx ON tmc_attributes (tmc);

CLUSTER VERBOSE tmc_attributes USING static_file_data_idx;

COMMIT;

ANALYZE tmc_attributes;


COMMIT;
