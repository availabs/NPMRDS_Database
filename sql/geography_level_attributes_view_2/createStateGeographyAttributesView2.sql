BEGIN;

CREATE MATERIALIZED VIEW geography_level_attributes_view_2 AS
  WITH mpo_to_ua AS (
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
  ), cte_urban_area_state_subsets AS (
      SELECT
          geography_level_name AS ua_name,
          states,
          ARRAY_AGG(distinct fips_codes.state_code) AS state_codes
        FROM geography_level_to_states
          INNER JOIN fips_codes
            ON (fips_codes.state = ANY(geography_level_to_states.states))
        WHERE (geography_level = 'UA')
        GROUP BY (ua_name, states)
      UNION
      SELECT
          geography_level_name AS ua_name,
          ARRAY[state]::VARCHAR(2)[] AS states,
          ARRAY[state_code]::VARCHAR(2)[] AS state_codes
        FROM (
          SELECT
              geography_level_name,
              UNNEST(states) AS state
            FROM geography_level_to_states
            WHERE (geography_level = 'UA')
        ) AS sub0 INNER JOIN (
          SELECT DISTINCT
              state,
              state_code
            FROM fips_codes
        ) AS sub1 USING (state)
  )

    /* MPOs */
    SELECT
        CAST('MPO' AS geography_level_type) geography_level,
        geography_level_code, 
        geography_level_name, 
        interstate_miles, 
        interstate_tmcs_ct, 
        noninterstate_miles,
        noninterstate_tmcs_ct,
        bounding_box,
        population_info,
        ARRAY[state]::VARCHAR(2)[] AS states,
        ARRAY[state_code]::VARCHAR(2)[] AS state_codes
      FROM (
          SELECT 
              mpo_code AS geography_level_code, -- for join with mpo_to_ua
              COALESCE(mpo_acrony, mpo_name) AS geography_level_name,
              SUM(miles) AS interstate_miles,
              COUNT(tmc) AS interstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE (is_interstate = true)
              AND (mpo_code IS NOT NULL)
            GROUP BY geography_level_code, geography_level_name, state
        ) AS t1 NATURAL FULL OUTER JOIN (
          SELECT
              mpo_code AS geography_level_code, -- for join with mpo_to_ua
              COALESCE(mpo_acrony, mpo_name) AS geography_level_name,
              SUM(miles) AS noninterstate_miles,
              COUNT(tmc) AS noninterstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE ((is_interstate = false) OR (is_interstate IS NULL))
              AND (mpo_code IS NOT NULL)
            GROUP BY geography_level_code, geography_level_name, state
        ) AS t2 NATURAL LEFT OUTER JOIN (
          SELECT
              mpo_code AS geography_level_code, -- for join with mpo_to_ua
              ST_Extent(wkb_geometry) AS bounding_box,
              tmc_attributes.state AS state
            FROM inrix_shapefile
              INNER JOIN tmc_attributes USING (tmc)
            WHERE (mpo_code IS NOT NULL)
            GROUP BY geography_level_code, tmc_attributes.state
        ) AS t3 NATURAL LEFT OUTER JOIN (
          SELECT
              mpo_id AS geography_level_code,
            -- select i, max(x) from (select i, jsonb_object_keys(d) as x from foo ) AS t group by i;
              jsonb_object_agg(
                year,
                jsonb_build_array(
                  jsonb_build_object(
                    'geography_level',
                    'UA',

                    'geography_name',
                    ua_name,

                    'total',
                    population
                  )
                ) 
              ) AS population_info
            FROM mpo_to_ua
              INNER JOIN mpo_boundaries USING (mpo_id)
              INNER JOIN urban_area_populations ON (
                (mpo_to_ua.ua_id = urban_area_populations.ua_code)
                AND
                (ARRAY[LOWER(mpo_boundaries.state)]::VARCHAR(2)[] = urban_area_populations.states) -- The MPO state's part of the UA
              )
            GROUP BY mpo_id, ua_name
        ) AS t4 LEFT OUTER JOIN (
          SELECT DISTINCT 
              state,
              state_code
            FROM fips_codes
        ) AS t5 USING (state)

  UNION ALL
    /* Counties */
    SELECT
        CAST('COUNTY' AS geography_level_type) AS geography_level,
        geography_level_code, 
        geography_level_name, 
        interstate_miles, 
        interstate_tmcs_ct, 
        noninterstate_miles,
        noninterstate_tmcs_ct,
        bounding_box,
        population_info,
        ARRAY[state]::VARCHAR(2)[],
        ARRAY[state_code]::VARCHAR(2)[]
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
        ) AS t4 NATURAL LEFT OUTER JOIN (
          SELECT
              state,
              state_code,
              county AS geography_level_name,
              (state_code || county_code) AS geography_level_code
            FROM fips_codes
        ) AS t5


  UNION ALL
    /* Urban Areas */
    SELECT
        CAST('UA' AS geography_level_type) AS geography_level,
        geography_level_code, 
        geography_level_name, 
        interstate_miles, 
        interstate_tmcs_ct, 
        noninterstate_miles,
        noninterstate_tmcs_ct,
        bounding_box,
        population_info,
        states::VARCHAR(2)[] AS states,
        state_codes::VARCHAR(2)[] AS state_codes
      FROM (
          SELECT 
              ua_code AS geography_level_code,
              ua_name AS geography_level_name,
              SUM(miles) AS interstate_miles,
              COUNT(tmc) AS interstate_tmcs_ct,
              states,
              state_codes
            FROM tmc_attributes
              INNER JOIN cte_urban_area_state_subsets USING (ua_name)
            WHERE (
              (is_interstate = true)
              AND (ua_code IS NOT NULL)
              AND (tmc_attributes.state = ANY(cte_urban_area_state_subsets.states))
            )
            GROUP BY geography_level_code, geography_level_name, states, state_codes
        ) AS t1 NATURAL FULL OUTER JOIN (
          SELECT
              ua_code AS geography_level_code,
              ua_name AS geography_level_name,
              SUM(miles) AS noninterstate_miles,
              COUNT(tmc) AS noninterstate_tmcs_ct,
              states,
              state_codes
            FROM tmc_attributes
              INNER JOIN cte_urban_area_state_subsets USING (ua_name)
            WHERE (
              ((is_interstate = false) OR (is_interstate IS NULL))
              AND (ua_code IS NOT NULL)
              AND (tmc_attributes.state = ANY(cte_urban_area_state_subsets.states))
            )
            GROUP BY geography_level_code, geography_level_name, states, state_codes
        ) AS t2 NATURAL LEFT OUTER JOIN (
          SELECT
              ua_code AS geography_level_code,
              ST_Extent(wkb_geometry) AS bounding_box,
              states,
              state_codes
            FROM inrix_shapefile
              INNER JOIN tmc_attributes USING (tmc)
              INNER JOIN cte_urban_area_state_subsets USING (ua_name)
            WHERE (
              (ua_code IS NOT NULL)
              AND (tmc_attributes.state = ANY(cte_urban_area_state_subsets.states))
            )
            GROUP BY ua_code, states, state_codes
        ) AS t3 NATURAL LEFT OUTER JOIN (
          SELECT
              ua_code AS geography_level_code,
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
-- ??? What is the purpose of this JOIN ???
            FROM urban_area_populations
            GROUP BY geography_level_code, states
        ) AS t4
  UNION ALL 
    /* States */
    SELECT
        CAST('STATE' AS geography_level_type) AS geography_level,
        geography_level_code, 
        geography_level_name, 
        interstate_miles, 
        interstate_tmcs_ct, 
        noninterstate_miles,
        noninterstate_tmcs_ct,
        bounding_box,
        population_info,
        ARRAY[state]::VARCHAR(2)[] AS states,
        ARRAY[state_code]::VARCHAR(2)[] AS state_codes
      FROM (
          SELECT 
              state AS geography_level_name,
              SUM(miles) AS interstate_miles,
              COUNT(tmc) AS interstate_tmcs_ct,
              state,
              state_code
            FROM tmc_attributes
            WHERE (is_interstate = true)
              AND (state IS NOT NULL)
            GROUP BY state, state_code
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
              state_code AS geography_level_code,
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
            GROUP BY state, state_code
        ) AS t4 ;

COMMIT;

