BEGIN;

CREATE TABLE highway_data_services.short_count_volume (
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
    vehicle_axle_code              SMALLINT REFERENCES highway_data_services.nysdot_vehicle_axle_code_descriptions(code),
    year                           SMALLINT,
    month                          SMALLINT REFERENCES highway_data_services.calendar_month_names(calendar_month),
    day                            SMALLINT REFERENCES highway_data_services.day_of_month_ordinals(day_of_month),
    day_of_week                    VARCHAR REFERENCES highway_data_services.days_of_week(day_of_week),
    federal_direction              SMALLINT REFERENCES highway_data_services.fhwa_direction_of_travel_code_descriptions(code),
	  lane_code                      SMALLINT,
	  lanes_in_direction             SMALLINT,
	  collection_interval            SMALLINT,
    interval_1_1                   INTEGER,
    interval_1_2                   INTEGER,
    interval_1_3                   INTEGER,
    interval_1_4                   INTEGER,
    interval_2_1                   INTEGER,
    interval_2_2                   INTEGER,
    interval_2_3                   INTEGER,
    interval_2_4                   INTEGER,
    interval_3_1                   INTEGER,
    interval_3_2                   INTEGER,
    interval_3_3                   INTEGER,
    interval_3_4                   INTEGER,
    interval_4_1                   INTEGER,
    interval_4_2                   INTEGER,
    interval_4_3                   INTEGER,
    interval_4_4                   INTEGER,
    interval_5_1                   INTEGER,
    interval_5_2                   INTEGER,
    interval_5_3                   INTEGER,
    interval_5_4                   INTEGER,
    interval_6_1                   INTEGER,
    interval_6_2                   INTEGER,
    interval_6_3                   INTEGER,
    interval_6_4                   INTEGER,
    interval_7_1                   INTEGER,
    interval_7_2                   INTEGER,
    interval_7_3                   INTEGER,
    interval_7_4                   INTEGER,
    interval_8_1                   INTEGER,
    interval_8_2                   INTEGER,
    interval_8_3                   INTEGER,
    interval_8_4                   INTEGER,
    interval_9_1                   INTEGER,
    interval_9_2                   INTEGER,
    interval_9_3                   INTEGER,
    interval_9_4                   INTEGER,
    interval_10_1                  INTEGER,
    interval_10_2                  INTEGER,
    interval_10_3                  INTEGER,
    interval_10_4                  INTEGER,
    interval_11_1                  INTEGER,
    interval_11_2                  INTEGER,
    interval_11_3                  INTEGER,
    interval_11_4                  INTEGER,
    interval_12_1                  INTEGER,
    interval_12_2                  INTEGER,
    interval_12_3                  INTEGER,
    interval_12_4                  INTEGER,
    interval_13_1                  INTEGER,
    interval_13_2                  INTEGER,
    interval_13_3                  INTEGER,
    interval_13_4                  INTEGER,
    interval_14_1                  INTEGER,
    interval_14_2                  INTEGER,
    interval_14_3                  INTEGER,
    interval_14_4                  INTEGER,
    interval_15_1                  INTEGER,
    interval_15_2                  INTEGER,
    interval_15_3                  INTEGER,
    interval_15_4                  INTEGER,
    interval_16_1                  INTEGER,
    interval_16_2                  INTEGER,
    interval_16_3                  INTEGER,
    interval_16_4                  INTEGER,
    interval_17_1                  INTEGER,
    interval_17_2                  INTEGER,
    interval_17_3                  INTEGER,
    interval_17_4                  INTEGER,
    interval_18_1                  INTEGER,
    interval_18_2                  INTEGER,
    interval_18_3                  INTEGER,
    interval_18_4                  INTEGER,
    interval_19_1                  INTEGER,
    interval_19_2                  INTEGER,
    interval_19_3                  INTEGER,
    interval_19_4                  INTEGER,
    interval_20_1                  INTEGER,
    interval_20_2                  INTEGER,
    interval_20_3                  INTEGER,
    interval_20_4                  INTEGER,
    interval_21_1                  INTEGER,
    interval_21_2                  INTEGER,
    interval_21_3                  INTEGER,
    interval_21_4                  INTEGER,
    interval_22_1                  INTEGER,
    interval_22_2                  INTEGER,
    interval_22_3                  INTEGER,
    interval_22_4                  INTEGER,
    interval_23_1                  INTEGER,
    interval_23_2                  INTEGER,
    interval_23_3                  INTEGER,
    interval_23_4                  INTEGER,
    interval_24_1                  INTEGER,
    interval_24_2                  INTEGER,
    interval_24_3                  INTEGER,
    interval_24_4                  INTEGER,
    total                          INTEGER,
    flag_field                     VARCHAR,
    batch_id                       VARCHAR
);


-- https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb/repository/Field_Definitions_SC%20Formats.pdf

COMMENT ON TABLE highway_data_services.short_count_volume IS
'Fifteen Minute short count speed data by direction for a given Region and Year.';

COMMENT ON COLUMN highway_data_services.short_count_volume.rc_station IS
'Region‐County‐Station number, a seven character code uniquely identifying a traffic segment in NYS. Can be used to join data to shapefiles published by NYSDOT.';

COMMENT ON COLUMN highway_data_services.short_count_volume.count_id IS
'A unique ID for each count session loaded, each count has one Count_ID for all data types.';

COMMENT ON COLUMN highway_data_services.short_count_volume.rg IS
'Region Number, a number 1‐11 representing the NYSDOT Region in which the count station is located.';

COMMENT ON COLUMN highway_data_services.short_count_volume.region_code IS
'A single digit code for each NYSDOT Region. Can be concatenated with County_Code and Station number to create a unique ID.';

COMMENT ON COLUMN highway_data_services.short_count_volume.county_code IS
'A single digit code for each County within a NYSDOT Region. Can be concatenated with Region_Code and Station number to create a unique ID.';

COMMENT ON COLUMN highway_data_services.short_count_volume.stat IS
'Station Number, a four digit number unique within a county representing a specific segment of road for traffic counting purposes. Can be concatenated with Region_Code and County_Code to create a unique ID. Typically formatted as text to retain leading zeroes.';

COMMENT ON COLUMN highway_data_services.short_count_volume.rcsta IS
'Region_Code, County_Code, and Station Number concatenated into a 6 digit unique ID. Typically formatted as text to retain leading zeroes.';

COMMENT ON COLUMN highway_data_services.short_count_volume.functional_class IS
'Functional Classification of the roadway segment to which the station applies.';

COMMENT ON COLUMN highway_data_services.short_count_volume.factor_group IS
'Factor Group determines the set of seasonal factors to apply. Factor Groups are 30, 40, or 60 only.';

COMMENT ON COLUMN highway_data_services.short_count_volume.latitude IS
'Latitude, in decimal degrees, of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.short_count_volume.longitude IS
'Longitude, in decimal degrees, of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.short_count_volume.specific_recorder_placement IS
'Verbal description of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.short_count_volume.channel_notes IS
'Any notes from the count collector, or processor, related to the count. The four digit Continuous Counter ID (CCID) is entered when the record is based on Continuous Data.';

COMMENT ON COLUMN highway_data_services.short_count_volume.data_type IS
'A description of the data type contained in the file.';

COMMENT ON COLUMN highway_data_services.short_count_volume.vehicle_axle_code IS
'Vehicle/Axle code in Volume files: 1=Vehicle count 2=Axles/2 count.';

COMMENT ON COLUMN highway_data_services.short_count_volume.year IS
'The year in which the data was collected.';

COMMENT ON COLUMN highway_data_services.short_count_volume.month IS
'The month in which the data was collected.';

COMMENT ON COLUMN highway_data_services.short_count_volume.day IS
'Where applicable, the day of the month on which the data was collected.';

COMMENT ON COLUMN highway_data_services.short_count_volume.day_of_week IS
'The day of week the data was collected.';

COMMENT ON COLUMN highway_data_services.short_count_volume.federal_direction IS
'The federal direction code for the data record. 1 – North, 3 – East, 5 – South, 7 – West, 9 – North/South Combined, 0 – East/West combined.   NOTED ERROR: Many North/South records are incorrectly labeled with a 0 code. Data remains correct.';

COMMENT ON COLUMN highway_data_services.short_count_volume.lane_code IS
'The lane code by direction, starting with 1 as the rightmost lane.';

COMMENT ON COLUMN highway_data_services.short_count_volume.lanes_in_direction IS
'The total number of lanes expected in this direction.';

COMMENT ON COLUMN highway_data_services.short_count_volume.collection_interval IS
'The interval, in minutes, in which the data was collected, typically 15 or 60.';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_1_1 IS
'Volume Data for the 15 minute interval 00:00 through 00:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_1_2 IS
'Volume Data for the 15 minute interval 00:15 through 00:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_1_3 IS
'Volume Data for the 15 minute interval 00:30 through 00:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_1_4 IS
'Volume Data for the 15 minute interval 00:45 through 01:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_2_1 IS
'Volume Data for the 15 minute interval 01:00 through 01:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_2_2 IS
'Volume Data for the 15 minute interval 01:15 through 01:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_2_3 IS
'Volume Data for the 15 minute interval 01:30 through 01:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_2_4 IS
'Volume Data for the 15 minute interval 01:45 through 02:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_3_1 IS
'Volume Data for the 15 minute interval 02:00 through 02:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_3_2 IS
'Volume Data for the 15 minute interval 02:15 through 02:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_3_3 IS
'Volume Data for the 15 minute interval 02:30 through 02:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_3_4 IS
'Volume Data for the 15 minute interval 02:45 through 03:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_4_1 IS
'Volume Data for the 15 minute interval 03:00 through 03:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_4_2 IS
'Volume Data for the 15 minute interval 03:15 through 03:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_4_3 IS
'Volume Data for the 15 minute interval 03:30 through 03:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_4_4 IS
'Volume Data for the 15 minute interval 03:45 through 04:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_5_1 IS
'Volume Data for the 15 minute interval 04:00 through 04:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_5_2 IS
'Volume Data for the 15 minute interval 04:15 through 04:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_5_3 IS
'Volume Data for the 15 minute interval 04:30 through 04:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_5_4 IS
'Volume Data for the 15 minute interval 04:45 through 05:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_6_1 IS
'Volume Data for the 15 minute interval 05:00 through 05:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_6_2 IS
'Volume Data for the 15 minute interval 05:15 through 05:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_6_3 IS
'Volume Data for the 15 minute interval 05:30 through 05:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_6_4 IS
'Volume Data for the 15 minute interval 05:45 through 06:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_7_1 IS
'Volume Data for the 15 minute interval 06:00 through 06:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_7_2 IS
'Volume Data for the 15 minute interval 06:15 through 06:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_7_3 IS
'Volume Data for the 15 minute interval 06:30 through 06:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_7_4 IS
'Volume Data for the 15 minute interval 06:45 through 07:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_8_1 IS
'Volume Data for the 15 minute interval 07:00 through 07:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_8_2 IS
'Volume Data for the 15 minute interval 07:15 through 07:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_8_3 IS
'Volume Data for the 15 minute interval 07:30 through 07:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_8_4 IS
'Volume Data for the 15 minute interval 07:45 through 08:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_9_1 IS
'Volume Data for the 15 minute interval 08:00 through 08:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_9_2 IS
'Volume Data for the 15 minute interval 08:15 through 08:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_9_3 IS
'Volume Data for the 15 minute interval 08:30 through 08:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_9_4 IS
'Volume Data for the 15 minute interval 08:45 through 09:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_10_1 IS
'Volume Data for the 15 minute interval 09:00 through 09:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_10_2 IS
'Volume Data for the 15 minute interval 09:15 through 09:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_10_3 IS
'Volume Data for the 15 minute interval 09:30 through 09:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_10_4 IS
'Volume Data for the 15 minute interval 09:45 through 10:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_11_1 IS
'Volume Data for the 15 minute interval 10:00 through 10:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_11_2 IS
'Volume Data for the 15 minute interval 10:15 through 10:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_11_3 IS
'Volume Data for the 15 minute interval 10:30 through 10:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_11_4 IS
'Volume Data for the 15 minute interval 10:45 through 11:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_12_1 IS
'Volume Data for the 15 minute interval 11:00 through 11:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_12_2 IS
'Volume Data for the 15 minute interval 11:15 through 11:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_12_3 IS
'Volume Data for the 15 minute interval 11:30 through 11:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_12_4 IS
'Volume Data for the 15 minute interval 11:45 through 12:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_13_1 IS
'Volume Data for the 15 minute interval 12:00 through 12:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_13_2 IS
'Volume Data for the 15 minute interval 12:15 through 12:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_13_3 IS
'Volume Data for the 15 minute interval 12:30 through 12:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_13_4 IS
'Volume Data for the 15 minute interval 12:45 through 13:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_14_1 IS
'Volume Data for the 15 minute interval 13:00 through 13:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_14_2 IS
'Volume Data for the 15 minute interval 13:15 through 13:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_14_3 IS
'Volume Data for the 15 minute interval 13:30 through 13:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_14_4 IS
'Volume Data for the 15 minute interval 13:45 through 14:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_15_1 IS
'Volume Data for the 15 minute interval 14:00 through 14:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_15_2 IS
'Volume Data for the 15 minute interval 14:15 through 14:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_15_3 IS
'Volume Data for the 15 minute interval 14:30 through 14:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_15_4 IS
'Volume Data for the 15 minute interval 14:45 through 15:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_16_1 IS
'Volume Data for the 15 minute interval 15:00 through 15:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_16_2 IS
'Volume Data for the 15 minute interval 15:15 through 15:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_16_3 IS
'Volume Data for the 15 minute interval 15:30 through 15:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_16_4 IS
'Volume Data for the 15 minute interval 15:45 through 16:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_17_1 IS
'Volume Data for the 15 minute interval 16:00 through 16:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_17_2 IS
'Volume Data for the 15 minute interval 16:15 through 16:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_17_3 IS
'Volume Data for the 15 minute interval 16:30 through 16:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_17_4 IS
'Volume Data for the 15 minute interval 16:45 through 17:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_18_1 IS
'Volume Data for the 15 minute interval 17:00 through 17:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_18_2 IS
'Volume Data for the 15 minute interval 17:15 through 17:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_18_3 IS
'Volume Data for the 15 minute interval 17:30 through 17:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_18_4 IS
'Volume Data for the 15 minute interval 17:45 through 18:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_19_1 IS
'Volume Data for the 15 minute interval 18:00 through 18:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_19_2 IS
'Volume Data for the 15 minute interval 18:15 through 18:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_19_3 IS
'Volume Data for the 15 minute interval 18:30 through 18:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_19_4 IS
'Volume Data for the 15 minute interval 18:45 through 19:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_20_1 IS
'Volume Data for the 15 minute interval 19:00 through 19:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_20_2 IS
'Volume Data for the 15 minute interval 19:15 through 19:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_20_3 IS
'Volume Data for the 15 minute interval 19:30 through 19:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_20_4 IS
'Volume Data for the 15 minute interval 19:45 through 20:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_21_1 IS
'Volume Data for the 15 minute interval 10:00 through 10:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_21_2 IS
'Volume Data for the 15 minute interval 20:15 through 20:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_21_3 IS
'Volume Data for the 15 minute interval 20:30 through 20:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_21_4 IS
'Volume Data for the 15 minute interval 20:45 through 21:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_22_1 IS
'Volume Data for the 15 minute interval 21:00 through 21:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_22_2 IS
'Volume Data for the 15 minute interval 21:15 through 21:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_22_3 IS
'Volume Data for the 15 minute interval 21:30 through 21:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_22_4 IS
'Volume Data for the 15 minute interval 21:45 through 22:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_23_1 IS
'Volume Data for the 15 minute interval 22:00 through 22:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_23_2 IS
'Volume Data for the 15 minute interval 22:15 through 22:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_23_3 IS
'Volume Data for the 15 minute interval 22:30 through 22:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_23_4 IS
'Volume Data for the 15 minute interval 22:45 through 23:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_24_1 IS
'Volume Data for the 15 minute interval 23:00 through 23:15';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_24_2 IS
'Volume Data for the 15 minute interval 23:15 through 23:30';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_24_3 IS
'Volume Data for the 15 minute interval 23:30 through 23:45';

COMMENT ON COLUMN highway_data_services.short_count_volume.interval_24_4 IS
'Volume Data for the 15 minute interval 23:45 through 24:00';

COMMENT ON COLUMN highway_data_services.short_count_volume.total IS
'The sum of all bins or intervals for the record.';

COMMENT ON COLUMN highway_data_services.short_count_volume.flag_field IS
'A field designated to give additional information about a count.';

COMMENT ON COLUMN highway_data_services.short_count_volume.batch_id IS
'A system code related to data importing.';


COMMIT;
