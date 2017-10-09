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

CREATE TABLE nprm7_time_dist (
  tmc                       VARCHAR(9), 
  year                      INT, 
  month                     INT, 
  travel_time_dist_by_hour  json,
  state                     CHAR(2)
);
