BEGIN;

CREATE MATERIALIZED VIEW public.geography_level_to_states AS

  SELECT DISTINCT
      'STATE'::geography_level_type AS geography_level,
      state::VARCHAR AS geography_level_name,
      ARRAY[state]::VARCHAR(2)[] AS states
    FROM tmc_attributes

  UNION ALL -- Region Level

  SELECT DISTINCT
       'REGION'::geography_level_type AS geography_level,
       region_name::VARCHAR AS geography_level_name,
       ARRAY[state]::VARCHAR(2)[] AS states
    FROM tmc_attributes
    WHERE region_name IS NOT NULL

  UNION ALL -- County Level

  SELECT DISTINCT
      'COUNTY'::geography_level_type AS geography_level,
      county::VARCHAR AS geography_level_name,
      ARRAY[state]::VARCHAR(2)[] AS states
    FROM tmc_attributes
    WHERE county IS NOT NULL

  UNION ALL -- MPO Level

  SELECT DISTINCT
       'MPO'::geography_level_type AS geography_level,
       mpo_acrony::VARCHAR AS geography_level_name,
       ARRAY[state]::VARCHAR(2)[] AS states
    FROM tmc_attributes
    WHERE mpo_acrony IS NOT NULL

  UNION ALL -- UA Level

  SELECT DISTINCT
      'UA'::geography_level_type AS geography_level,
      ua_name::VARCHAR AS geography_level_name,
      array_agg(state order by state)::VARCHAR(2)[] as states
    FROM (
      SELECT DISTINCT
          ua_name,
          UNNEST(
            string_to_array(
              split_part(
                LOWER(ua_name),
                ', ',
                2),
              '--'
            )
          ) AS state
        FROM tmc_attributes
    ) t
    GROUP BY ua_name
;

COMMIT;
