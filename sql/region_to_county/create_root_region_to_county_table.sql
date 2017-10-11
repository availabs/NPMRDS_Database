-- https://www.dot.ny.gov/divisions/engineering/technical-services/hds-respository/Traffic%20Data%20Report%202011%20Appendix%20D%20-%20NYSDOT%20Regions%20and%20County%20Codes.pdf

BEGIN;

CREATE TABLE region_to_county (
  region_id SMALLINT,
  county_name VARCHAR,
  state VARCHAR(2)
) WITH (fillfactor=100, autovacuum_enabled=false);
COMMIT;

VACUUM ANALYZE region_to_county;
