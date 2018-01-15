BEGIN;

CREATE MATERIALIZED VIEW geography_level_attributes_view AS
  WITH cte_mpo_2_ua AS (
    SELECT
        mpo_id,
        ua_id,
        ua_name,
        state
      FROM (
        SELECT
            ROW_NUMBER() OVER (
              PARTITION BY mpo_id ORDER BY intersection_area DESC, ua_id
            ) AS row_num,
            sub_mpo_to_ua_intersection_areas.*
          FROM (
            SELECT
                m.mpo_id AS mpo_id,
                LOWER(m.state) AS state,
                u.geoid10 AS ua_id,
                u.name10 AS ua_name,
                ST_Area(
                  ST_Intersection(
                    m.wkb_geometry,
                    u.wkb_geometry
                  )
                ) AS intersection_area
            FROM mpo_boundaries AS m
              INNER JOIN urban_area_boundaries AS u
              ON (ST_INTERSECTS(m.wkb_geometry, u.wkb_geometry))
          ) as sub_mpo_to_ua_intersection_areas
      ) AS sub_ranked_mpo_to_ua
      WHERE row_num = 1
  ), cte_county_populations AS (
    SELECT
        state,
        county,
        population,
        year
      FROM county_populations
        NATURAL JOIN fips_codes
  )

    /* MPOs */
    SELECT
        CAST('MPO' AS geography_level_type) geography_level,
        geography_level_name, 
        interstate_miles, 
        interstate_tmcs_ct, 
        noninterstate_miles,
        noninterstate_tmcs_ct,
        bounding_box,
        population_info,
        ARRAY[state] AS states
      FROM (
          SELECT 
              mpo_acrony AS geography_level_name,
              SUM(miles) AS interstate_miles,
              COUNT(tmc) AS interstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE (is_interstate = true)
              AND (mpo_acrony IS NOT NULL)
            GROUP BY mpo_acrony, state
        ) AS t1 NATURAL FULL OUTER JOIN (
          SELECT
              mpo_acrony AS geography_level_name,
              SUM(miles) AS noninterstate_miles,
              COUNT(tmc) AS noninterstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE ((is_interstate = false) OR (is_interstate IS NULL))
              AND (mpo_acrony IS NOT NULL)
            GROUP BY mpo_acrony, state
        ) AS t2 NATURAL LEFT OUTER JOIN (
          SELECT
              mpo_code, -- for join with cte_mpo_2_ua
              mpo_acrony AS geography_level_name,
              ST_Extent(wkb_geometry) AS bounding_box,
              tmc_attributes.state AS state
            FROM inrix_shapefile
              INNER JOIN tmc_attributes USING (tmc)
            GROUP BY mpo_code, geography_level_name, tmc_attributes.state
        ) AS t3 NATURAL LEFT OUTER JOIN (
          SELECT
              mpo_id AS mpo_code,
            -- select i, max(x) from (select i, jsonb_object_keys(d) as x from foo ) AS t group by i;
              jsonb_object_agg(
                year,
                jsonb_build_array(
                  jsonb_build_object(
                    'geography_level',
                    'URBAN_AREA',

                    'geography_name',
                    ua_name,

                    'total',
                    population
                  )
                ) 
              ) AS population_info
            FROM cte_mpo_2_ua
              INNER JOIN urban_area_populations
              ON (
                (cte_mpo_2_ua.ua_id = urban_area_populations.ua_code)
                AND
                (cte_mpo_2_ua.state = ANY(urban_area_populations.states))
              )
            GROUP BY mpo_id, ua_name
        ) AS t4

  UNION ALL
    /* Counties */
    SELECT
        CAST('COUNTY' AS geography_level_type) AS geography_level,
        geography_level_name, 
        interstate_miles, 
        interstate_tmcs_ct, 
        noninterstate_miles,
        noninterstate_tmcs_ct,
        bounding_box,
        population_info,
        ARRAY[state]
      FROM (
          SELECT 
              county AS geography_level_name,
              SUM(miles) AS interstate_miles,
              COUNT(tmc) AS interstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE (is_interstate = true)
              AND (county IS NOT NULL)
            GROUP BY county, state
        ) AS t1 NATURAL FULL OUTER JOIN (
          SELECT
              county AS geography_level_name,
              SUM(miles) AS noninterstate_miles,
              COUNT(tmc) AS noninterstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE ((is_interstate = false) OR (is_interstate IS NULL))
              AND (county IS NOT NULL)
            GROUP BY county, state
        ) AS t2 NATURAL FULL OUTER JOIN (
          SELECT
              tmc_attributes.county AS geography_level_name,
              ST_Extent(wkb_geometry) AS bounding_box,
              tmc_attributes.state AS state
            FROM inrix_shapefile
              INNER JOIN tmc_attributes USING (tmc)
            GROUP BY geography_level_name, tmc_attributes.state
        ) AS t3 NATURAL LEFT OUTER JOIN (
          SELECT
              county AS geography_level_name,
              state,
              jsonb_object_agg(
                year,
                jsonb_build_array(
                  jsonb_build_object(
                    'total',
                    population
                  )
                ) 
              ) AS population_info
            FROM cte_county_populations
            GROUP BY county, state
        ) AS t4

  UNION ALL
    /* Urban Areas */
    SELECT
        CAST('UA' AS geography_level_type) AS geography_level,
        geography_level_name, 
        interstate_miles, 
        interstate_tmcs_ct, 
        noninterstate_miles,
        noninterstate_tmcs_ct,
        bounding_box,
        population_info,
        states
      FROM (
          SELECT 
              ua_name AS geography_level_name,
              SUM(miles) AS interstate_miles,
              COUNT(tmc) AS interstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE (is_interstate = true)
              AND (ua_name IS NOT NULL)
            GROUP BY ua_name, state
        ) AS t1 NATURAL FULL OUTER JOIN (
          SELECT
              ua_name AS geography_level_name,
              SUM(miles) AS noninterstate_miles,
              COUNT(tmc) AS noninterstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE ((is_interstate = false) OR (is_interstate IS NULL))
              AND (ua_name IS NOT NULL)
            GROUP BY ua_name, state
        ) AS t2 NATURAL LEFT OUTER JOIN (
          SELECT
              ua_code,
              ua_name AS geography_level_name,
              ST_Extent(wkb_geometry) AS bounding_box,
              tmc_attributes.state AS state
            FROM inrix_shapefile
              INNER JOIN tmc_attributes USING (tmc)
            WHERE (ua_name IS NOT NULL)
            GROUP BY ua_code, geography_level_name, tmc_attributes.state
        ) AS t3 LEFT OUTER JOIN (
          SELECT
              ua_code,
              states,
              jsonb_object_agg(
                year,
                jsonb_build_array(
                  jsonb_build_object(
                    'total',
                    population
                  )
                ) 
              ) AS population_info
            FROM urban_area_populations
            GROUP BY ua_code, states
        ) AS t4 ON (
          (t3.ua_code = t4.ua_code)
          AND
          (t3.state = ANY(t4.states)) --state subsets for UAs
        )

  UNION ALL
    /* Regions */
    SELECT
        CAST('REGION' AS geography_level_type) AS geography_level,
        geography_level_name, 
        interstate_miles, 
        interstate_tmcs_ct, 
        noninterstate_miles,
        noninterstate_tmcs_ct,
        bounding_box,
        population_info,
        ARRAY[state]
      FROM (
          SELECT 
              region_code::VARCHAR AS geography_level_name,
              SUM(miles) AS interstate_miles,
              COUNT(tmc) AS interstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE (is_interstate = true)
              AND (region_code IS NOT NULL)
            GROUP BY region_code, state
        ) AS t1 NATURAL FULL OUTER JOIN (
          SELECT
              region_code::VARCHAR AS geography_level_name,
              SUM(miles) AS noninterstate_miles,
              COUNT(tmc) AS noninterstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE ((is_interstate = false) OR (is_interstate IS NULL))
              AND (region_code IS NOT NULL)
            GROUP BY region_code, state
        ) AS t2 NATURAL FULL OUTER JOIN (
          SELECT
              region_code::VARCHAR AS geography_level_name,
              ST_Extent(wkb_geometry) AS bounding_box,
              tmc_attributes.state AS state
            FROM inrix_shapefile
              INNER JOIN tmc_attributes USING (tmc)
            GROUP BY geography_level_name, tmc_attributes.state
        ) AS t3 LEFT OUTER JOIN (
          SELECT
              region_id::VARCHAR AS geography_level_name,
              state,
              jsonb_object_agg(
                year,
                jsonb_build_array(
                  jsonb_build_object(
                    'total',
                    population
                  )
                ) 
              ) AS population_info
            FROM (
              SELECT
                  region_id,
                  state,
                  year,
                  SUM(population) AS population
                FROM region_to_county
                  INNER JOIN cte_county_populations
                  USING (state, county)
                GROUP BY (region_id, state, year)
            ) AS sub_region_populations
            GROUP BY geography_level_name, state
        ) AS t4 USING (geography_level_name, state)

  UNION ALL 
    /* States */
    SELECT
        CAST('STATE' AS geography_level_type) AS geography_level,
        geography_level_name, 
        interstate_miles, 
        interstate_tmcs_ct, 
        noninterstate_miles,
        noninterstate_tmcs_ct,
        bounding_box,
        population_info,
        ARRAY[state]
      FROM (
          SELECT 
              state AS geography_level_name,
              SUM(miles) AS interstate_miles,
              COUNT(tmc) AS interstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE (is_interstate = true)
              AND (state IS NOT NULL)
            GROUP BY state
        ) AS t1 NATURAL FULL OUTER JOIN (
          SELECT
              state AS geography_level_name,
              SUM(miles) AS noninterstate_miles,
              COUNT(tmc) AS noninterstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE ((is_interstate = false) OR (is_interstate IS NULL))
              AND (state IS NOT NULL)
            GROUP BY state
        ) AS t2 NATURAL FULL OUTER JOIN (
          SELECT
              tmc_attributes.state AS geography_level_name,
              ST_Extent(wkb_geometry) AS bounding_box,
              tmc_attributes.state AS state
            FROM inrix_shapefile
              INNER JOIN tmc_attributes USING (tmc)
            GROUP BY geography_level_name, tmc_attributes.state
        ) AS t3 NATURAL LEFT OUTER JOIN (
          SELECT
              state AS geography_level_name,
              jsonb_object_agg(
                year,
                jsonb_build_array(
                  jsonb_build_object(
                    'total',
                    population
                  )
                ) 
              ) AS population_info
            FROM state_populations
              NATURAL INNER JOIN state_codes
            GROUP BY state
        ) AS t4
;

COMMIT;

