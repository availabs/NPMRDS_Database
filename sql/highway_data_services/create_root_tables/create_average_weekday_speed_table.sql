BEGIN;

CREATE TABLE highway_data_services.average_weekday_speed (
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
    speed_limit                    SMALLINT,
    year                           SMALLINT,
    month                          SMALLINT REFERENCES highway_data_services.calendar_month_names(calendar_month),
    day_of_first_data              SMALLINT REFERENCES highway_data_services.day_of_month_ordinals(day_of_month),
    federal_direction              SMALLINT REFERENCES highway_data_services.fhwa_direction_of_travel_code_descriptions(code),
    full_count                     CHAR(1),
    avg_wkday_bin_1                INTEGER,
    avg_wkday_bin_2                INTEGER,
    avg_wkday_bin_3                INTEGER,
    avg_wkday_bin_4                INTEGER,
    avg_wkday_bin_5                INTEGER,
    avg_wkday_bin_6                INTEGER,
    avg_wkday_bin_7                INTEGER,
    avg_wkday_bin_8                INTEGER,
    avg_wkday_bin_9                INTEGER,
    avg_wkday_bin_10               INTEGER,
    avg_wkday_bin_11               INTEGER,
    avg_wkday_bin_12               INTEGER,
    avg_wkday_bin_13               INTEGER,
    avg_wkday_bin_14               INTEGER,
    avg_wkday_bin_15               INTEGER,
    avg_wkday_unclassified         INTEGER,
    avg_wkday_totals               INTEGER,
    avg_speed                      DOUBLE PRECISION,
    fiftyth_percentile_speed       DOUBLE PRECISION,
    eightyfiveth_percentile_speed  DOUBLE PRECISION,
    percentile_exceeding_55        DOUBLE PRECISION,
    percentile_exceeding_65        DOUBLE PRECISION,
    flag_field                     VARCHAR,
    batch_id                       VARCHAR
);


-- https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb/repository/Field_Definitions_SC%20Formats.pdf
COMMENT ON TABLE highway_data_services.average_weekday_speed IS
'Short count average weekday speed distribution by direction for a given Region and Year. Weekday data is defined as Monday 6am through Friday Noon.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.rc_station IS
'Region‐County‐Station number, a seven character code uniquely identifying a traffic segment in NYS. Can be used to join data to shapefiles published by NYSDOT.'; 

COMMENT ON COLUMN highway_data_services.average_weekday_speed.count_id IS
'A unique ID for each count session loaded, each count has one Count_ID for all data types.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.rg IS
'Region Number, a number 1‐11 representing the NYSDOT Region in which the count station is located.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.region_code IS
'A single digit code for each NYSDOT Region. Can be concatenated with County_Code and Station number to create a unique ID.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.county_code IS
'A single digit code for each County within a NYSDOT Region. Can be concatenated with Region_Code and Station number to create a unique ID.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.stat IS
'Station Number, a four digit number unique within a county representing a specific segment of road for traffic counting purposes. Can be concatenated with Region_Code and County_Code to create a unique ID. Typically formatted as text to retain leading zeroes.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.rcsta IS
'Region_Code, County_Code, and Station Number concatenated into a 6 digit unique ID. Typically formatted as text to retain leading zeroes.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.functional_class IS
'Functional Classification of the roadway segment to which the station applies.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.factor_group IS
'Factor Group determines the set of seasonal factors to apply. Factor Groups are 30, 40, or 60 only.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.latitude IS
'Latitude, in decimal degrees, of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.longitude IS
'Longitude, in decimal degrees, of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.specific_recorder_placement IS
'Verbal description of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.channel_notes IS
'Any notes from the count collector, or processor, related to the count. The four digit Continuous Counter ID (CCID) is entered when the record is based on Continuous Data.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.data_type IS
'A description of the data type contained in the file.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.speed_limit IS
'Speed_Limit for the count location in speed data files.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.year IS
'The year in which the data was collected.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.month IS
'The month in which the data was collected.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.day_of_first_data IS
'The first day of data collection for the count.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.federal_direction IS
'The federal direction code for the data record. 1 – North, 3 – East, 5 – South, 7 – West, 9 – North/South Combined, 0 – East/West combined.   NOTED ERROR: Many North/South records are incorrectly labeled with a 0 code. Data remains correct.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.full_count IS
'Indicates if the record represents the total roadway, or just a single direction. ‘blank’ indicates data applies to direction in Federal Direction field. ‘Y’ indicates data applies to the entire roadway.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_bin_1 IS
'The number of vehicles in the NYSDOT Speed Bin 1 (00-20.0 mph) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_bin_2 IS
'The number of vehicles in the NYSDOT Speed Bin 2 (20.1-25.0 mph) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_bin_3 IS
'The number of vehicles in the NYSDOT Speed Bin 3 (25.1-30.0 mph) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_bin_4 IS
'The number of vehicles in the NYSDOT Speed Bin 4 (30.1-35.0 mph) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_bin_5 IS
'The number of vehicles in the NYSDOT Speed Bin 5 (35.1-40.0 mph) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_bin_6 IS
'The number of vehicles in the NYSDOT Speed Bin 6 (40.1-45.0 mph) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_bin_7 IS
'The number of vehicles in the NYSDOT Speed Bin 7 (45.1-50.0 mph) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_bin_8 IS
'The number of vehicles in the NYSDOT Speed Bin 8 (50.1-55.0 mph) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_bin_9 IS
'The number of vehicles in the NYSDOT Speed Bin 9 (55.1-60.0 mph) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_bin_10 IS
'The number of vehicles in the NYSDOT Speed Bin 10 (60.1-65.0 mph) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_bin_11 IS
'The number of vehicles in the NYSDOT Speed Bin 11 (65.1-70.0 mph) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_bin_12 IS
'The number of vehicles in the NYSDOT Speed Bin 12 (70.1-75.0 mph) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_bin_13 IS
'The number of vehicles in the NYSDOT Speed Bin 13 (75.1-80.0 mph) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_bin_14 IS
'The number of vehicles in the NYSDOT Speed Bin 14 (80.1-85.0 mph) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_bin_15 IS
'The number of vehicles in the NYSDOT Speed Bin 15 (>85.0 mph) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_unclassified IS
'Currently blank. Represents the number of unclassified vehicles as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_wkday_totals IS
'Represents the number of vehicles in all classes as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.avg_speed IS
'Represents the Average Speed of vehicles for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.fiftyth_percentile_speed IS
'Represents the speed of the vehicle in the 50th percentile, or median speed, for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.eightyfiveth_percentile_speed IS
'Represents the speed of the vehicle in the 85th percentile for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.percentile_exceeding_55 IS
'Represents the percentage of total vehicles that are exceeding 55mph for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.percentile_exceeding_65 IS
'Represents the percentage of total vehicles that are exceeding 65mph for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.flag_field IS
'A field designated to give additional information about a count.';

COMMENT ON COLUMN highway_data_services.average_weekday_speed.batch_id IS
'A system code related to data importing.';


COMMIT;
