CREATE TABLE public.avgtt (
  tmc       CHARACTER VARYING(9),
  year      SMALLINT,
  avg_day   JSONB,
  state     CHARACTER VARYING(2),
  PRIMARY KEY (tmc, year)
) ;
