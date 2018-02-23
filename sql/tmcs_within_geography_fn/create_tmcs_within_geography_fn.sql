CREATE OR REPLACE FUNCTION tmcs_within_geography_fn (
    states          VARCHAR(2)[],
    geo_level_type  geography_level_type,
    geo_name        TEXT
  ) 
  RETURNS TABLE (tmc VARCHAR)
  AS $body$

    SELECT
        tmc
      FROM tmc_attributes
      WHERE (
        (state ILIKE ANY(states))
        AND
        (
          (geo_level_type = 'STATE')
          OR
          (
            (geo_level_type = 'COUNTY')
            AND
            (UPPER(county) = UPPER(geo_name))
          )
          OR
          (
            (geo_level_type = 'MPO')
            AND
            (UPPER(mpo_acrony) = UPPER(geo_name))
          )
          OR
          (
            (geo_level_type = 'UA')
            AND
            (UPPER(ua_name) = UPPER(geo_name))
          )
        )
      )

  $body$
  LANGUAGE SQL
;

