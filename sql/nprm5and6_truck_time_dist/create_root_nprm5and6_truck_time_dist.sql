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


CREATE TABLE nprm5and6_truck_time_dist (
  tmc               VARCHAR(9), 
  year              INT, 
  month             INT, 
  travel_time_dist  json,
  state             CHAR(2)
);
