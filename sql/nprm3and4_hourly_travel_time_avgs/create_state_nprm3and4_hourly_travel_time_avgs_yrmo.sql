/*

OUTLIER PROCESSING
All travel times that are less than 2 mph or greater than 100 mph shall not be
used (as proposed in section 490.511(c)(2)) in the calculation of the PHTTR. This
can be achieved by either creating a subset of the full dataset or, if the software
allows, excluding these observations from the analysis with a “WHERE” or
similar clause.

MEASURE CALCULATION: EQUATIONS
  The peak hour travel time measures are based on first computing the Peak Hour
  Travel Time Ratio (PHTTR) for each reporting segment. Then, a three-stage
  process is used to develop the peak hour travel time measures. First, an annual
  average travel time for each of six hours of the day for non-Federal holiday
  weekdays are computed; an entire year of data is used in this calculation. The six
  hours for which average travel times are computed individually are:
    * 6:00 – 7:00 a.m.;
    * 7:00 – 8:00 a.m.;
    * 8:00 – 9:00 a.m.,
    * 4:00 – 5:00 p.m.;
    * 5:00 – 6:00 p.m.; and
    * 6:00 – 7:00 p.m

NOTE: For defining the bins, the left values are exclusive.
*/

BEGIN;

CREATE TABLE "__STATE__".nprm3and4_hourly_travel_time_avgs_y__YEAR__m__MONTH__ (
  LIKE "__STATE__".nprm3and4_hourly_travel_time_avgs INCLUDING ALL
) WITH (fillfactor = 100);


INSERT INTO "__STATE__".nprm3and4_hourly_travel_time_avgs_y__YEAR__m__MONTH__
    (tmc, year, month, travel_time_avgs_by_time_period, state) (
  SELECT tmc, 
         __YEAR__ AS year,
         __MONTH__ AS month,
         json_object_agg(time_period, avg_travel_time) AS travel_time_avgs_by_time_period,
        '__STATE__'::char(2) AS state
  FROM (
    SELECT tmc,
				 AVG(travel_time_all_vehicles) AS avg_travel_time,
				 nprm3and4TimeBinFunc(epoch::integer) AS time_period
      FROM "__STATE__".npmrds
        JOIN inrix_shapefile
        USING(tmc)
      WHERE ((epoch BETWEEN 72 AND 108) OR (epoch BETWEEN 192 AND 227))
        AND (EXTRACT(DOW FROM date) BETWEEN 1 AND 5) -- Weekdays
        AND (date NOT IN (SELECT date from federal_holidays))
        AND (((miles / NULLIF(travel_time_all_vehicles, 0)::float) * 3600) BETWEEN 2 and 100)
        AND ((date >= DATE '__START_DATE__') AND (date < '__END_DATE__'))
      GROUP BY tmc, time_period
  ) AS avgs
  GROUP BY tmc);


ALTER TABLE "__STATE__".nprm3and4_hourly_travel_time_avgs_y__YEAR__m__MONTH__
  ADD CONSTRAINT date_range 
    CHECK ((year = __YEAR__) AND (month = __MONTH__)),
  ALTER COLUMN travel_time_avgs_by_time_period SET STATISTICS 0,
  INHERIT "__STATE__".nprm3and4_hourly_travel_time_avgs;


CREATE UNIQUE INDEX nprm3and4_hourly_travel_time_avgs_y__YEAR__m__MONTH___idx
  ON "__STATE__".nprm3and4_hourly_travel_time_avgs_y__YEAR__m__MONTH__ (tmc)
  WITH (fillfactor = 100);

ALTER TABLE "__STATE__".nprm3and4_hourly_travel_time_avgs_y__YEAR__m__MONTH__
  ADD CONSTRAINT nprm3and4_hourly_travel_time_avgs_y__YEAR__m__MONTH___pkey
    PRIMARY KEY USING INDEX nprm3and4_hourly_travel_time_avgs_y__YEAR__m__MONTH___idx;


CLUSTER VERBOSE "__STATE__".nprm3and4_hourly_travel_time_avgs_y__YEAR__m__MONTH__
  USING nprm3and4_hourly_travel_time_avgs_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".nprm3and4_hourly_travel_time_avgs_y__YEAR__m__MONTH__;
