/*
  TRAVEL TIME DATA
    Data to compute this measure shall be based (as proposed in section 490.609) on
    actual travel time measurements in seconds reported for epochs that are no
    longer than 5and6-minutes in duration and for the FHWA-approved reporting
    segments. The travel time measurements used in the calculation are for trucks
    only. If the reporting epoch is smaller than 5and6-minutes in duration, the data
    should be aggregated to the 5and6-minute epoch level by computing the arithmetic
    travel time mean.

  MISSING DATA PROCESSING
    Any travel time for reporting segments contained within a reporting segment
    that are “0” or null shall be replaced (as proposed in section 490.611(b)(1)(ii))
    using the following procedure:

      1. If a travel time value for all vehicles combined exists for a 5and6-minute interval
      and it is less than the posted speed limit, the “0” or null for truck travel time
      is replaced with it.

      2. If the conditions of a) are not satisfied, “0” or null truck travel time is
      replaced with the truck travel time at the posted speed limit, based on the
      segment length and posted speed limit rounded to the nearest second.
*/


BEGIN;

CREATE TABLE "__STATE__".nprm5and6_truck_time_dist_y__YEAR__m__MONTH__ (
  LIKE "__STATE__".nprm5and6_truck_time_dist INCLUDING ALL
);


INSERT INTO "__STATE__".nprm5and6_truck_time_dist_y__YEAR__m__MONTH__
    (tmc, year, month, travel_time_dist, state) (
  SELECT tmc, 
         __YEAR__ AS year, 
         __MONTH__ AS month, 
         json_object_agg(travel_time, ct) AS travel_time_dist,
        '__STATE__ '::char(2) AS state
  FROM  (
    SELECT tmc, 
           __YEAR__ AS year, 
           __MONTH__ AS month, 
           -- Fill in the missing 
           COALESCE(
             -- IF truck tt available, use it.
             travel_time_freight_trucks, 
             -- Else if tmc length and speedlimit available,
             -- fill with the max between all vehicle travel times
             -- and travel time at the speedlimit.
             GREATEST(
               ROUND(miles::FLOAT / NULLIF(avg_speedlimit, 0)::FLOAT * 3600.0), 
               travel_time_all_vehicles
             ),
             -- Else, use the all vehicle travel times.
             travel_time_all_vehicles
           ) AS travel_time,
           COUNT(*) AS ct
    FROM "__STATE__".npmrds_y__YEAR__m__MONTH__ 
      LEFT OUTER JOIN tmc_attributes USING (tmc)
    GROUP BY tmc, travel_time
  ) AS occurrances
  GROUP BY tmc);


ALTER TABLE "__STATE__".nprm5and6_truck_time_dist_y__YEAR__m__MONTH__
  ADD CONSTRAINT date_range
    CHECK ((year = __YEAR__) AND (month = __MONTH__)),
  ALTER COLUMN travel_time_dist SET STATISTICS 0,
  INHERIT "__STATE__".nprm5and6_truck_time_dist,
  SET (fillfactor = 100);


CREATE UNIQUE INDEX nprm5and6_truck_time_dist_y__YEAR__m__MONTH___idx
  ON "__STATE__".nprm5and6_truck_time_dist_y__YEAR__m__MONTH__ (tmc)
  WITH (fillfactor = 100);

ALTER TABLE "__STATE__".nprm5and6_truck_time_dist_y__YEAR__m__MONTH__
  ADD CONSTRAINT nprm5and6_truck_time_dist_y__YEAR__m__MONTH___pkey
    PRIMARY KEY USING INDEX nprm5and6_truck_time_dist_y__YEAR__m__MONTH___idx;


CLUSTER VERBOSE "__STATE__".nprm5and6_truck_time_dist_y__YEAR__m__MONTH__
  USING nprm5and6_truck_time_dist_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".nprm5and6_truck_time_dist_y__YEAR__m__MONTH__;
