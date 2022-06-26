BEGIN;

UPDATE ny.tmc_metadata_2021_v20210919084731 AS a
  SET region_code = b.region
  FROM ny.nysdot_regions AS b
  WHERE ( a.county_code = b.fips_code )
;

--  SELECT
    --  region_code,
    --  count(1) AS ct
  --  FROM ny.tmc_metadata_2021_v20210919084731
  --  GROUP BY 1
  --  ORDER BY 1
--  ;

COMMIT;
