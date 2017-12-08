BEGIN;

CREATE TABLE us.mpo_populations (
    mpo_name          VARCHAR,
    mpo_acrony        VARCHAR,
    state             VARCHAR(2),
    major_city        VARCHAR,
    area              DOUBLE PRECISION,
    population        BIGINT,
    designation_year  SMALLINT,
    CONSTRAINT county_populations_pkey PRIMARY KEY(mpo_name, state)
  ) WITH (fillfactor=100, autovacuum_enabled=false)
;

COMMIT;
