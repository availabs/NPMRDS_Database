CREATE VIEW geography_level_road_miles_breakdown_view
  AS
    /* MPOs */
    SELECT
        CAST('MPO' AS VARCHAR)::geography_level_type AS geography_level,
        geography_level_name, 
        interstate_miles, 
        interstate_tmcs_ct, 
        noninterstate_miles,
        noninterstate_tmcs_ct,
        state
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
        ) AS T2

  UNION ALL
    /* Counties */
    SELECT
        CAST('COUNTY' AS VARCHAR)::geography_level_type AS geography_level,
        geography_level_name, 
        interstate_miles, 
        interstate_tmcs_ct, 
        noninterstate_miles,
        noninterstate_tmcs_ct,
        state
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
        ) AS T2

  /* Core Based Statistical Areas */
  UNION ALL
    /* CBSAs */
    SELECT
        CAST('CBSA' AS VARCHAR)::geography_level_type AS geography_level,
        geography_level_name, 
        interstate_miles, 
        interstate_tmcs_ct, 
        noninterstate_miles,
        noninterstate_tmcs_ct,
        state
      FROM (
          SELECT 
              cbsa_name AS geography_level_name,
              SUM(miles) AS interstate_miles,
              COUNT(tmc) AS interstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE (is_interstate = true)
              AND (cbsa_name IS NOT NULL)
            GROUP BY cbsa_name, state
        ) AS t1 NATURAL FULL OUTER JOIN (
          SELECT
              cbsa_name AS geography_level_name,
              SUM(miles) AS noninterstate_miles,
              COUNT(tmc) AS noninterstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE ((is_interstate = false) OR (is_interstate IS NULL))
              AND (cbsa_name IS NOT NULL)
            GROUP BY cbsa_name, state
        ) AS T2

  UNION ALL
    /* Urban Areas */
    SELECT
        CAST('UA' AS VARCHAR)::geography_level_type AS geography_level,
        geography_level_name, 
        interstate_miles, 
        interstate_tmcs_ct, 
        noninterstate_miles,
        noninterstate_tmcs_ct,
        state
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
        ) AS T2

  UNION ALL
    /* Regions */
    SELECT
        CAST('REGION' AS VARCHAR)::geography_level_type AS geography_level,
        geography_level_name, 
        interstate_miles, 
        interstate_tmcs_ct, 
        noninterstate_miles,
        noninterstate_tmcs_ct,
        state
      FROM (
          SELECT 
              region_name AS geography_level_name,
              SUM(miles) AS interstate_miles,
              COUNT(tmc) AS interstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE (is_interstate = true)
              AND (region_name IS NOT NULL)
            GROUP BY region_name, state
        ) AS t1 NATURAL FULL OUTER JOIN (
          SELECT
              region_name AS geography_level_name,
              SUM(miles) AS noninterstate_miles,
              COUNT(tmc) AS noninterstate_tmcs_ct,
              state
            FROM tmc_attributes
            WHERE ((is_interstate = false) OR (is_interstate IS NULL))
              AND (region_name IS NOT NULL)
            GROUP BY region_name, state
        ) AS T2


  UNION ALL 
    /* States */
    SELECT
        CAST('STATE' AS VARCHAR)::geography_level_type AS geography_level,
        geography_level_name, 
        interstate_miles, 
        interstate_tmcs_ct, 
        noninterstate_miles,
        noninterstate_tmcs_ct,
        state
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
        ) AS T2
;

