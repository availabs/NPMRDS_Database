CREATE TABLE public.tmc_average_day (
  tmc       CHARACTER VARYING(9),
  year      SMALLINT,
  avg_day   INTEGER[],
  state     CHARACTER VARYING(2),
  PRIMARY KEY (tmc, year)
) ;
