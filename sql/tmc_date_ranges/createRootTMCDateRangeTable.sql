DROP TABLE IF EXISTS tmc_date_ranges CASCADE;

CREATE TABLE IF NOT EXISTS tmc_date_ranges (
  tmc         VARCHAR(9),
  first_date  DATE,
  last_date   DATE,
  state       CHAR(2)
);
