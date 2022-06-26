CREATE TABLE IF NOT EXISTS :"STATE".tmc_date_ranges (
  tmc         VARCHAR(9) PRIMARY KEY,
  first_date  DATE NOT NULL,
  last_date   DATE NOT NULL,
  state       CHAR(2) NOT NULL DEFAULT :'STATE',
  
  CHECK ( state = :'STATE' )
)
  INHERITS ( public.tmc_date_ranges )
  WITH (fillfactor=100)
;
