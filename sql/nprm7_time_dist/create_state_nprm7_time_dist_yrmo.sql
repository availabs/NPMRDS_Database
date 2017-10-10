/*
MEASURE DEFINITION
  This measure is meant to capture the annual reliability of travel separately for
  Interstates and Non-Interstate NHS highways, for four different time periods:
    1. Weekdays between of 6:00 a.m. and 10:00 a.m.;
    2. Weekdays between 10:00 a.m. and 4:00 p.m.;
    3. Weekdays between 4:00 p.m. and 8:00 p.m.; and
    4. Weekend days between 6:00 a.m. and 8:00 p.m.


NOTE: For defining the bins, the last values are not inclusive until the last bin
      for the day type. For example, bin 1 is 6am to 9:55am, inclusive.
      Bin 3 is 4pm to 8pm, inclusive.
*/


BEGIN;

CREATE TABLE "__STATE__".nprm7_time_dist_y__YEAR__m__MONTH__ (
  LIKE "__STATE__".nprm7_time_dist INCLUDING ALL
);


INSERT INTO "__STATE__".nprm7_time_dist_y__YEAR__m__MONTH__ 
    (tmc, state, year, month, travel_time_dist_by_hour) (
  SELECT tmc, 
         '__STATE__'::char(2) AS state,
         __YEAR__ AS year,
         __MONTH__ AS month,
         json_object_agg(hour, travel_time_dist) AS travel_time_dist_by_hour
    FROM (
      -- Get the time distributions for each hour
      SELECT tmc, 
             hour,
             json_object_agg(travel_time_all_vehicles, ct) AS travel_time_dist,
            '__STATE__'::char(2) AS state
      FROM  (
        SELECT tmc, 
               (epoch / 12) AS hour,
               travel_time_all_vehicles,
               COUNT(*) AS ct
        FROM "__STATE__".npmrds
        WHERE ((date >= DATE '__START_DATE__') AND (date < '__END_DATE__'))
        GROUP BY tmc, hour, travel_time_all_vehicles -- for occurrances
      ) AS occurrances
      GROUP BY tmc, hour
    ) AS dist_by_hour
    GROUP BY tmc);



ALTER TABLE "__STATE__".nprm7_time_dist_y__YEAR__m__MONTH__
  ADD CONSTRAINT date_range 
    CHECK ((year = __YEAR__) AND (month = __MONTH__)),
  ALTER COLUMN travel_time_dist_by_hour SET STATISTICS 0,
  INHERIT "__STATE__".nprm7_time_dist,
  SET (fillfactor = 100);


CREATE UNIQUE INDEX nprm7_time_dist_y__YEAR__m__MONTH___idx
  ON "__STATE__".nprm7_time_dist_y__YEAR__m__MONTH__ (tmc)
  WITH (fillfactor = 100);

ALTER TABLE "__STATE__".nprm7_time_dist_y__YEAR__m__MONTH__
  ADD CONSTRAINT nprm7_time_dist_y__YEAR__m__MONTH___pkey
    PRIMARY KEY USING INDEX nprm7_time_dist_y__YEAR__m__MONTH___idx;


CLUSTER VERBOSE "__STATE__".nprm7_time_dist_y__YEAR__m__MONTH__
  USING nprm7_time_dist_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".nprm7_time_dist_y__YEAR__m__MONTH__;

