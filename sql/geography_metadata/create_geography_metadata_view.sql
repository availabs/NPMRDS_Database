-- https://stackoverflow.com/a/9981540

CREATE FUNCTION pg_temp.tmp_create_geography_metadata_view ()
  RETURNS VOID AS
$func$
BEGIN

DROP MATERIALIZED VIEW IF EXISTS geography_metadata ;

EXECUTE 'CREATE MATERIALIZED VIEW geography_metadata AS
  WITH cte_tmc_metadata AS (' || (
    SELECT
        string_agg('
          SELECT
              state,
              state_code,
              county_name,
              county_code,
              mpo_acrony,
              mpo_name,
              mpo_code,
              ua_name,
              ua_code,
              bounding_box
            FROM public.' || table_name || ' AS m
          ',
          ' UNION ALL '
        )
      FROM information_schema.tables
      WHERE (
        (table_schema = 'public')
        AND
        (table_name LIKE 'tmc_metadata_%')
      )
  ) || ')
  SELECT
      CAST(''STATE'' AS geography_level_type) geography_level,
      state_code AS geography_level_code,
      state AS geography_level_name, -- Using abbreviation rather than full name
      ARRAY[state]::TEXT[] AS states,
      ARRAY[state_code]::TEXT[] AS state_codes,
      ST_Extent(bounding_box) AS bounding_box
    FROM cte_tmc_metadata
    WHERE state IS NOT NULL
    GROUP BY state_code, state

  UNION ALL

  SELECT
      CAST(''COUNTY'' AS geography_level_type) geography_level,
      county_code AS geography_level_code,
      REPLACE(
        county_name,
        ''.'',
        ''''
      ) AS geography_level_name,
      ARRAY[state]::TEXT[] AS states,
      ARRAY[state_code]::TEXT[] AS state_codes,
      ST_Extent(bounding_box) AS bounding_box
    FROM cte_tmc_metadata
    WHERE county_name IS NOT NULL
    GROUP BY 2, 3, 4, 5

  UNION ALL

  SELECT
      CAST(''MPO'' AS geography_level_type) geography_level,
      mpo_code AS geography_level_code,
      COALESCE(mpo_acrony, mpo_name) AS geography_level_name,
      array_agg(DISTINCT state ORDER BY state)::TEXT[] AS states,
      array_agg(DISTINCT state_code ORDER BY state_code)::TEXT[] AS state_codes,
      ST_Extent(bounding_box) AS bounding_box
    FROM cte_tmc_metadata
    WHERE mpo_code IS NOT NULL
    GROUP BY mpo_code, mpo_acrony, mpo_name

  UNION ALL

  SELECT
      CAST(''UA'' AS geography_level_type) geography_level,
      ua_code AS geography_level_code,
      ua_name AS geography_level_name,
      array_agg(DISTINCT state ORDER BY state)::TEXT[] AS states,
      array_agg(DISTINCT state_code ORDER BY state_code)::TEXT[] AS state_codes,
      ST_Extent(bounding_box) AS bounding_box
    FROM cte_tmc_metadata
    WHERE (
      (ua_code IS NOT NULL)
      AND
      (ua_code <> ''99998'')
      AND
      (ua_code <> ''99999'')
    )
    GROUP BY ua_code, ua_name

  UNION ALL

  SELECT
      CAST(''UA'' AS geography_level_type) geography_level,
      ua_code AS geography_level_code,
      CASE WHEN ua_code = ''99998''
        THEN ''Small Urban Sections''
        ELSE ''Rural Area Sections''
      END AS geography_level_name,
      ARRAY[state]::TEXT[] AS states,
      ARRAY[state_code]::TEXT[] AS state_codes,
      ST_Extent(bounding_box) AS bounding_box
    FROM cte_tmc_metadata
    WHERE (
      (ua_code IS NOT NULL)
      AND
      (
        (ua_code = ''99998'')
        OR
        (ua_code = ''99999'')
      )
    )
    GROUP BY ua_code, ua_name, state, state_code
  ;
';


END;
$func$ LANGUAGE plpgsql;

SELECT pg_temp.tmp_create_geography_metadata_view();
