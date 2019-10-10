BEGIN;

CREATE TABLE highway_data_services.short_count_speed (
    rc_station                     VARCHAR,
    count_id                       VARCHAR,
    rg                             SMALLINT,
    region_code                    SMALLINT,
    county_code                    SMALLINT,
    stat                           VARCHAR(4),
    rcsta                          VARCHAR(6),
    functional_class               SMALLINT REFERENCES highway_data_services.nysdot_functional_classification_code_descriptions(code),
    factor_group                   SMALLINT REFERENCES highway_data_services.nysdot_seasonal_adjustment_factor_group_descriptions(factor_group),
    latitude                       DOUBLE PRECISION,
    longitude                      DOUBLE PRECISION,
    specific_recorder_placement    VARCHAR,
    channel_notes                  VARCHAR,
    data_type                      VARCHAR,
    speed_limit                    SMALLINT,
    year                           SMALLINT,
    month                          SMALLINT REFERENCES highway_data_services.calendar_month_names(calendar_month),
    day                            SMALLINT REFERENCES highway_data_services.day_of_month_ordinals(day_of_month),
    day_of_week                    VARCHAR REFERENCES highway_data_services.days_of_week(day_of_week),
    federal_direction              SMALLINT REFERENCES highway_data_services.fhwa_direction_of_travel_code_descriptions(code),
	  lane_code                      SMALLINT, 
	  lanes_in_direction             SMALLINT, 
	  collection_interval            SMALLINT,
	  data_interval                  REAL REFERENCES highway_data_services.nysdot_data_interval_descriptions(data_interval),
    bin_1                          INTEGER, 
    bin_2                          INTEGER, 
    bin_3                          INTEGER, 
    bin_4                          INTEGER, 
    bin_5                          INTEGER, 
    bin_6                          INTEGER, 
    bin_7                          INTEGER, 
    bin_8                          INTEGER, 
    bin_9                          INTEGER, 
    bin_10                         INTEGER, 
    bin_11                         INTEGER, 
    bin_12                         INTEGER, 
    bin_13                         INTEGER, 
    bin_14                         INTEGER, 
    bin_15                         INTEGER, 
	  unclassified                   INTEGER, 
	  total                          INTEGER,
    flag_field                     VARCHAR, 
    batch_id                       VARCHAR
);


-- https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb/repository/Field_Definitions_SC%20Formats.pdf

COMMENT ON TABLE highway_data_services.short_count_speed IS
'Fifteen Minute short count speed data by direction for a given Region and Year.';

COMMENT ON COLUMN highway_data_services.short_count_speed.rc_station IS
'Region‐County‐Station number, a seven character code uniquely identifying a traffic segment in NYS. Can be used to join data to shapefiles published by NYSDOT.'; 

COMMENT ON COLUMN highway_data_services.short_count_speed.count_id IS
'A unique ID for each count session loaded, each count has one Count_ID for all data types.';

COMMENT ON COLUMN highway_data_services.short_count_speed.rg IS
'Region Number, a number 1‐11 representing the NYSDOT Region in which the count station is located.';

COMMENT ON COLUMN highway_data_services.short_count_speed.region_code IS
'A single digit code for each NYSDOT Region. Can be concatenated with County_Code and Station number to create a unique ID.';

COMMENT ON COLUMN highway_data_services.short_count_speed.county_code IS
'A single digit code for each County within a NYSDOT Region. Can be concatenated with Region_Code and Station number to create a unique ID.';

COMMENT ON COLUMN highway_data_services.short_count_speed.stat IS
'Station Number, a four digit number unique within a county representing a specific segment of road for traffic counting purposes. Can be concatenated with Region_Code and County_Code to create a unique ID. Typically formatted as text to retain leading zeroes.';

COMMENT ON COLUMN highway_data_services.short_count_speed.rcsta IS
'Region_Code, County_Code, and Station Number concatenated into a 6 digit unique ID. Typically formatted as text to retain leading zeroes.';

COMMENT ON COLUMN highway_data_services.short_count_speed.functional_class IS
'Functional Classification of the roadway segment to which the station applies.';

COMMENT ON COLUMN highway_data_services.short_count_speed.factor_group IS
'Factor Group determines the set of seasonal factors to apply. Factor Groups are 30, 40, or 60 only.';

COMMENT ON COLUMN highway_data_services.short_count_speed.latitude IS
'Latitude, in decimal degrees, of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.short_count_speed.longitude IS
'Longitude, in decimal degrees, of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.short_count_speed.specific_recorder_placement IS
'Verbal description of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.short_count_speed.channel_notes IS
'Any notes from the count collector, or processor, related to the count. The four digit Continuous Counter ID (CCID) is entered when the record is based on Continuous Data.';

COMMENT ON COLUMN highway_data_services.short_count_speed.data_type IS
'A description of the data type contained in the file.';

COMMENT ON COLUMN highway_data_services.short_count_speed.speed_limit IS
'Speed_Limit for the count location in speed data files.';

COMMENT ON COLUMN highway_data_services.short_count_speed.year IS
'The year in which the data was collected.';

COMMENT ON COLUMN highway_data_services.short_count_speed.month IS
'The month in which the data was collected.';

COMMENT ON COLUMN highway_data_services.short_count_speed.day IS
'Where applicable, the day of the month on which the data was collected.';

COMMENT ON COLUMN highway_data_services.short_count_speed.day_of_week IS
'The day of week the data was collected.';

COMMENT ON COLUMN highway_data_services.short_count_speed.federal_direction IS
'The federal direction code for the data record. 1 – North, 3 – East, 5 – South, 7 – West, 9 – North/South Combined, 0 – East/West combined.   NOTED ERROR: Many North/South records are incorrectly labeled with a 0 code. Data remains correct.';

COMMENT ON COLUMN highway_data_services.short_count_speed.lane_code IS
'The lane code by direction, starting with 1 as the rightmost lane.';

COMMENT ON COLUMN highway_data_services.short_count_speed.lanes_in_direction IS
'The total number of lanes expected in this direction.';

COMMENT ON COLUMN highway_data_services.short_count_speed.collection_interval IS
'The interval, in minutes, in which the data was collected, typically 15 or 60.';

COMMENT ON COLUMN highway_data_services.short_count_speed.data_interval IS
'Speed and Classification data only. The interval which the record applies. 1.1 indicates the first 15 minutes of the first hour of the day, or 00:00 through 00:15. 1.2 represents 00:15‐00:30, 12.3 represents 11:30‐11:45, 23.4 represents 22:45‐23:00 and so on.';

COMMENT ON COLUMN highway_data_services.short_count_speed.bin_1 IS
'The number of vehicles in speed bin 1 (00-20.0 mph) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_speed.bin_2 IS
'The number of vehicles in speed bin 2 (20.1-25.0 mph) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_speed.bin_3 IS
'The number of vehicles in speed bin 3 (25.1-30.0 mph) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_speed.bin_4 IS
'The number of vehicles in speed bin 4 (30.1-35.0 mph) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_speed.bin_5 IS
'The number of vehicles in speed bin 5 (35.1-40.0 mph) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_speed.bin_6 IS
'The number of vehicles in speed bin 6 (40.1-45.0 mph) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_speed.bin_7 IS
'The number of vehicles in speed bin 7 (45.1-50.0 mph) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_speed.bin_8 IS
'The number of vehicles in speed bin 8 (50.1-55.0 mph) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_speed.bin_9 IS
'The number of vehicles in speed bin 9 (55.1-60.0 mph) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_speed.bin_10 IS
'The number of vehicles in speed bin (60.1-65.0 mph) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_speed.bin_11 IS
'The number of vehicles in speed bin 11 (65.1-70.0 mph) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_speed.bin_12 IS
'The number of vehicles in speed bin 12 (70.1-75.0 mph) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_speed.bin_13 IS
'The number of vehicles in speed bin 13 (75.1-80.0 mph) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_speed.bin_14 IS
'The number of vehicles in speed bin 14 (80.1-85.0 mph) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_speed.bin_15 IS
'The number of vehicles in speed bin 15 (>85.0 mph ) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_speed.unclassified IS
'Speed and Classification only. Number of vehicles a counter was unable to correctly place in a bin. Currently blank, as not part of NYSDOT format at this time.';

COMMENT ON COLUMN highway_data_services.short_count_speed.total IS
'The sum of all bins or intervals for the record.';

COMMENT ON COLUMN highway_data_services.short_count_speed.flag_field IS
'A field designated to give additional information about a count.';

COMMENT ON COLUMN highway_data_services.short_count_speed.batch_id IS
'A system code related to data importing.';

COMMIT;
