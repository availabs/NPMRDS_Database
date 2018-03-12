BEGIN;

ALTER TABLE tmc_attributes
  ADD COLUMN IF NOT EXISTS state_code CHAR(2),
  ADD COLUMN IF NOT EXISTS county_code CHAR(5)
;

UPDATE tmc_attributes SET state_code = (
    SELECT DISTINCT
        state_code
      FROM fips_codes
      WHERE tmc_attributes.state = fips_codes.state
  )
; 

UPDATE tmc_attributes SET county_code = (
    SELECT DISTINCT
        (state_code || county_code)
      FROM fips_codes
      WHERE (
        (tmc_attributes.state = fips_codes.state)
        AND
        (tmc_attributes.county = fips_codes.county)
      )
  )
; 

COMMIT;
