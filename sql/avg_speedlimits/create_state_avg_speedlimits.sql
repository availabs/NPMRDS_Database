CREATE TABLE IF NOT EXISTS :"STATE".avg_speedlimits (
  state          CHAR(2)  DEFAULT :'STATE' CHECK(state = :'STATE'),
  tmc            VARCHAR  PRIMARY KEY,
  avg_speedlimit REAL
) INHERITS( public.avg_speedlimits ) ;

CLUSTER :"STATE".avg_speedlimits 
  USING avg_speedlimits_pkey ;
