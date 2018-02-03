CREATE OR REPLACE FUNCTION tmcs_within_geography_fn (
    states          VARCHAR(2)[],
    geo_level_type  geography_level_type,
    geo_name        VARCHAR
  ) 
  RETURNS TABLE (tmc VARCHAR)
  AS $body$

    SELECT
        tmc
      FROM tmc_attributes
      WHERE (
        (state = ANY(states))
        AND
        (
          (geo_level_type = 'STATE')
          OR
          (
            (geo_level_type = 'COUNTY')
            AND
            (county = geo_name)
          )
          OR
          (
            (geo_level_type = 'MPO')
            AND
            (mpo_acrony = geo_name)
          )
          OR
          (
            (geo_level_type = 'UA')
            AND
            (ua_name = geo_name)
          )
        )
      )

  $body$
  LANGUAGE SQL
;

