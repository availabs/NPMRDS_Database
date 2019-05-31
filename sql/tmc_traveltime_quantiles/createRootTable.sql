CREATE TABLE IF NOT EXISTS tmc_travetime_quantiles (
  tmc        VARCHAR(9),
  state      CHAR(2),
  weekday    BOOLEAN,
  qtr_hr     SMALLINT,
  quantiles  INTEGER[3]
);
