/*
MEASURE DEFINITION
  This measure is meant to capture the annual reliability of travel separately for
  Interstates and Non-Interstate NHS highways, for four different time periods:
    1. Weekdays between of 6:00 a.m. and 10:00 a.m.;
    2. Weekdays between 10:00 a.m. and 4:00 p.m.;
    3. Weekdays between 4:00 p.m. and 8:00 p.m.; and
    4. Weekend days between 6:00 a.m. and 8:00 p.m.


NOTE: For defining the bins, the left values are exclusive
*/

BEGIN;

CREATE TABLE "__STATE__".nprm1and2_time_dist_y__YEAR__m__MONTH__ (
  LIKE "__STATE__".nprm1and2_time_dist INCLUDING ALL
);


/* 
  In this temporary table, we get the
    number of occurrences for each distinct travel_time within a time_period.
*/
CREATE TEMPORARY TABLE tmp_monthly_counts AS
  SELECT tmc, 
         nprm1and2TimeBinFunc(date::date, epoch::integer) AS time_period,
         travel_time_all_vehicles,
         COUNT(*) AS ct
  FROM "__STATE__".npmrds
  WHERE (epoch BETWEEN (6*12) AND (20*12-1))
    AND ((date >= DATE '__START_DATE__') AND (date < '__END_DATE__'))
  GROUP BY tmc, 
           time_period,
           --  nprm1and2TimeBinFunc(date::date, epoch::integer),
           travel_time_all_vehicles;

CREATE INDEX tmp_monthly_counts_idx
	ON tmp_monthly_counts (tmc, time_period);

/*
  The subquery makes a JSON object where
    the keys are travel_time, and
    the values are the number of occurrences within the time period.
  The outer query makes a JSON object where
    the keys are the time period, and
    the values are the JSON objects created in the subquery.
*/
INSERT INTO  "__STATE__".nprm1and2_time_dist_y__YEAR__m__MONTH__
    (tmc, year, month, travel_time_dist_by_time_period, state) (
  SELECT  tmc,
          __YEAR__ AS year, 
          __MONTH__ AS month,
          json_object_agg(time_period, travel_time_dist) AS travel_time_dist_by_time_period,
         '__STATE__'::char(2) AS state
  FROM (
    SELECT tmc, 
           time_period,
           json_object_agg(travel_time_all_vehicles, ct) AS travel_time_dist
      FROM tmp_monthly_counts
      GROUP BY tmc, 
               time_period
    ) AS occurrances
  GROUP BY tmc);


ALTER TABLE "__STATE__".nprm1and2_time_dist_y__YEAR__m__MONTH__
  ADD CONSTRAINT date_range 
    CHECK ((year = __YEAR__) AND (month = __MONTH__)),
  ALTER COLUMN travel_time_dist_by_time_period SET STATISTICS 0,
  INHERIT "__STATE__".nprm1and2_time_dist,
  SET (fillfactor = 100);


CREATE UNIQUE INDEX nprm1and2_time_dist_y__YEAR__m__MONTH___idx
  ON "__STATE__".nprm1and2_time_dist_y__YEAR__m__MONTH__ (tmc)
  WITH (fillfactor = 100);

ALTER TABLE "__STATE__".nprm1and2_time_dist_y__YEAR__m__MONTH__
  ADD CONSTRAINT nprm1and2_time_dist_y__YEAR__m__MONTH___pkey
    PRIMARY KEY USING INDEX nprm1and2_time_dist_y__YEAR__m__MONTH___idx;


CLUSTER VERBOSE "__STATE__".nprm1and2_time_dist_y__YEAR__m__MONTH__
  USING nprm1and2_time_dist_y__YEAR__m__MONTH___pkey;

COMMIT;


ANALYZE VERBOSE "__STATE__".nprm1and2_time_dist_y__YEAR__m__MONTH__;
