CREATE OR REPLACE VIEW geography_metadata_:YEAR AS
  SELECT DISTINCT
      CAST('STATE' AS geography_level_type) geography_level,
      state_code AS geography_level_code,
      state AS geography_level_name, -- Using abbreviation rather than full name
      ARRAY[state]::TEXT[] AS states,
      ARRAY[state_code]::TEXT[] AS state_codes
    FROM tmc_metadata_:YEAR
    WHERE state IS NOT NULL

  UNION ALL

  SELECT DISTINCT
      CAST('COUNTY' AS geography_level_type) geography_level,
      county_code AS geography_level_code,
      county_name AS geography_level_name,
      ARRAY[state]::TEXT[] AS states,
      ARRAY[state_code]::TEXT[] AS state_codes
    FROM tmc_metadata_:YEAR
    WHERE county_name IS NOT NULL

  UNION ALL

  SELECT
      CAST('MPO' AS geography_level_type) geography_level,
      mpo_code AS geography_level_code,
      COALESCE(mpo_acrony, mpo_name) AS geography_level_name,
      array_agg(DISTINCT state ORDER BY state)::TEXT[] AS states,
      array_agg(DISTINCT state_code ORDER BY state_code)::TEXT[] AS state_codes
    FROM tmc_metadata_:YEAR
    WHERE mpo_code IS NOT NULL
    GROUP BY mpo_code, mpo_acrony, mpo_name

  UNION ALL

  SELECT
      CAST('UA' AS geography_level_type) geography_level,
      ua_code AS geography_level_code,
      ua_name AS geography_level_name,
      array_agg(DISTINCT state ORDER BY state)::TEXT[] AS states,
      array_agg(DISTINCT state_code ORDER BY state_code)::TEXT[] AS state_codes
    FROM tmc_metadata_:YEAR
    WHERE (
      (ua_code IS NOT NULL)
      AND
      (ua_code <> '99998')
      AND
      (ua_code <> '99999')
    )
    GROUP BY ua_code, ua_name

  UNION ALL

  SELECT DISTINCT
      CAST('UA' AS geography_level_type) geography_level,
      ua_code AS geography_level_code,
      ua_name AS geography_level_name,
      ARRAY[state]::TEXT[] AS states,
      ARRAY[state_code]::TEXT[] AS state_codes
    FROM tmc_metadata_:YEAR
    WHERE (
      (ua_code = '99998')
      OR
      (ua_code = '99999')
    )
;
