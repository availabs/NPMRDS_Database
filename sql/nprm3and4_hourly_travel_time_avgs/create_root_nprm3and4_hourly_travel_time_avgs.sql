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

NOTE: For defining the bins, the last values are not inclusive until the last bin
      for the day type. For example, bin 1 is 6am to 6:55,
      whereas bin 6 is 6pm to 7pm, inclusive.


*/

CREATE TABLE nprm3and4_hourly_travel_time_avgs (
  tmc                              VARCHAR(9), 
  year                             INT, 
  month                            INT, 
  travel_time_avgs_by_time_period  json,
  state                            CHAR(2)
);
