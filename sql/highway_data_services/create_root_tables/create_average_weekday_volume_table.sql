BEGIN;

CREATE TABLE highway_data_services.average_weekday_volume (
    rc_station                     VARCHAR,
    count_id                       VARCHAR,
    rg                             VARCHAR(2),
    region_code                    VARCHAR,
    county_code                    VARCHAR,
    stat                           VARCHAR(4),
    rcsta                          VARCHAR(6),
    functional_class               SMALLINT REFERENCES highway_data_services.nysdot_functional_classification_code_descriptions(code),
    factor_group                   SMALLINT REFERENCES highway_data_services.nysdot_seasonal_adjustment_factor_group_descriptions(factor_group),
    latitude                       DOUBLE PRECISION,
    longitude                      DOUBLE PRECISION,
    specific_recorder_placement    VARCHAR,
    channel_notes                  VARCHAR,
    data_type                      VARCHAR,
    vehicle_axle_code              SMALLINT REFERENCES highway_data_services.nysdot_vehicle_axle_code_descriptions(code),
    year                           SMALLINT,
    month                          SMALLINT REFERENCES highway_data_services.calendar_month_names(calendar_month),
    day_of_first_data              SMALLINT REFERENCES highway_data_services.day_of_month_ordinals(day_of_month),
    federal_direction              SMALLINT REFERENCES highway_data_services.fhwa_direction_of_travel_code_descriptions(code),
    full_count                     CHAR(1),
	  avg_wkday_interval_1           INTEGER, 
	  avg_wkday_interval_2           INTEGER, 
	  avg_wkday_interval_3           INTEGER, 
	  avg_wkday_interval_4           INTEGER, 
	  avg_wkday_interval_5           INTEGER, 
	  avg_wkday_interval_6           INTEGER, 
	  avg_wkday_interval_7           INTEGER, 
	  avg_wkday_interval_8           INTEGER, 
	  avg_wkday_interval_9           INTEGER, 
	  avg_wkday_interval_10          INTEGER, 
	  avg_wkday_interval_11          INTEGER, 
	  avg_wkday_interval_12          INTEGER, 
	  avg_wkday_interval_13          INTEGER, 
	  avg_wkday_interval_14          INTEGER, 
	  avg_wkday_interval_15          INTEGER, 
	  avg_wkday_interval_16          INTEGER, 
	  avg_wkday_interval_17          INTEGER, 
	  avg_wkday_interval_18          INTEGER, 
	  avg_wkday_interval_19          INTEGER, 
	  avg_wkday_interval_20          INTEGER, 
	  avg_wkday_interval_21          INTEGER, 
	  avg_wkday_interval_22          INTEGER, 
	  avg_wkday_interval_23          INTEGER, 
	  avg_wkday_interval_24          INTEGER, 
	  avg_wkday_daily_traffic        INTEGER, 
	  seasonal_factor                DOUBLE PRECISION, 
	  axle_factor                    DOUBLE PRECISION, 
	  aadt                           INTEGER, 
	  high_hour_value                INTEGER, 
	  high_hour_interval             INTEGER, 
	  k_factor                       DOUBLE PRECISION, 
	  d_factor                       DOUBLE PRECISION, 
	  flag_field                     VARCHAR,
	  batch_id                       VARCHAR
);


-- https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb/repository/Field_Definitions_SC%20Formats.pdf
COMMENT ON TABLE highway_data_services.average_weekday_volume IS
'Short count average weekday volume by direction for a given Region and Year.  Weekday data is defined as Monday 6am through Friday Noon.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.rc_station IS
'Region‐County‐Station number, a seven character code uniquely identifying a traffic segment in NYS. Can be used to join data to shapefiles published by NYSDOT.'; 

COMMENT ON COLUMN highway_data_services.average_weekday_volume.count_id IS
'A unique ID for each count session loaded, each count has one Count_ID for all data types.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.rg IS
'Region Number, a number 1‐11 representing the NYSDOT Region in which the count station is located.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.region_code IS
'A single digit code for each NYSDOT Region. Can be concatenated with County_Code and Station number to create a unique ID.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.county_code IS
'A single digit code for each County within a NYSDOT Region. Can be concatenated with Region_Code and Station number to create a unique ID.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.stat IS
'Station Number, a four digit number unique within a county representing a specific segment of road for traffic counting purposes. Can be concatenated with Region_Code and County_Code to create a unique ID. Typically formatted as text to retain leading zeroes.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.rcsta IS
'Region_Code, County_Code, and Station Number concatenated into a 6 digit unique ID. Typically formatted as text to retain leading zeroes.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.functional_class IS
'Functional Classification of the roadway segment to which the station applies.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.factor_group IS
'Factor Group determines the set of seasonal factors to apply. Factor Groups are 30, 40, or 60 only.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.latitude IS
'Latitude, in decimal degrees, of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.longitude IS
'Longitude, in decimal degrees, of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.specific_recorder_placement IS
'Verbal description of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.channel_notes IS
'Any notes from the count collector, or processor, related to the count. The four digit Continuous Counter ID (CCID) is entered when the record is based on Continuous Data.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.data_type IS
'A description of the data type contained in the file.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.vehicle_axle_code IS
'Vehicle/Axle code in Volume files: 1=Vehicle count 2=Axles/2 count.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.year IS
'The year in which the data was collected.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.month IS
'The month in which the data was collected.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.day_of_first_data IS
'The first day of data collection for the count.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.federal_direction IS
'The federal direction code for the data record. 1 – North, 3 – East, 5 – South, 7 – West, 9 – North/South Combined, 0 – East/West combined.   NOTED ERROR: Many North/South records are incorrectly labeled with a 0 code. Data remains correct.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.full_count IS
'Indicates if the record represents the total roadway, or just a single direction. ‘blank’ indicates data applies to direction in Federal Direction field. ‘Y’ indicates data applies to the entire roadway.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_1 IS
'The number of vehicles in interval 1 (00:00-01:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_2 IS
'The number of vehicles in interval 2 (01:00-02:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_3 IS
'The number of vehicles in interval 3 (02:00-03:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_4 IS
'The number of vehicles in interval 4 (03:00-04:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_5 IS
'The number of vehicles in interval 5 (04:00-05:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_6 IS
'The number of vehicles in interval 6 (05:00-06:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_7 IS
'The number of vehicles in interval 7 (06:00-07:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_8 IS
'The number of vehicles in interval 8 (07:00-08:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_9 IS
'The number of vehicles in interval 9 (08:00-09:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_10 IS
'The number of vehicles in interval 10 (09:00-10:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_11 IS
'The number of vehicles in interval 11 (10:00-11:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_12 IS
'The number of vehicles in interval 12 (11:00-12:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_13 IS
'The number of vehicles in interval 13 (12:00-13:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_14 IS
'The number of vehicles in interval 14 (13:00-14:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_15 IS
'The number of vehicles in interval 15 (14:00-15:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_16 IS
'The number of vehicles in interval 16 (15:00-16:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_17 IS
'The number of vehicles in interval 17 (16:00-17:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_18 IS
'The number of vehicles in interval 18 (17:00-18:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_19 IS
'The number of vehicles in interval 19 (18:00-19:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_20 IS
'The number of vehicles in interval 20 (19:00-20:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_21 IS
'The number of vehicles in interval 21 (20:00-21:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_22 IS
'The number of vehicles in interval 22 (21:00-22:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_23 IS
'The number of vehicles in interval 23 (22:00-23:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_interval_24 IS
'The number of vehicles in interval 24 (23:00-24:00) for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.avg_wkday_daily_traffic IS
'The total number of vehicles for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.seasonal_factor IS
'The seasonal factor applied to calculate the AADT.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.axle_factor IS
'The axle factor applied to calculate the AADT.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.aadt IS
'The seasonally adjusted Annual Average of Daily Traffic, representing an Average Day for the location.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.high_hour_value IS
'The number of vehicles in the hour with the highest traffic of the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.high_hour_interval IS
'The interval that contains the highest traffic of the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.k_factor IS
'The highest hour of the Average Weekday expressed as a percentages of the Average Weekday total. This value is populated for total roadway records only.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.d_factor IS
'The higher direction of the highest hour of the Average Weekday expressed as a percentages of the highest hour total. This value is populated for total roadway records only.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.flag_field IS
'A field designated to give additional information about a count.';

COMMENT ON COLUMN highway_data_services.average_weekday_volume.batch_id IS
'A system code related to data importing.';


COMMIT;
