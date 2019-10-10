BEGIN;

CREATE TABLE highway_data_services.short_count_vehicle_classification (
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
    blank                          CHAR(1),
    year                           SMALLINT,
    month                          SMALLINT REFERENCES highway_data_services.calendar_month_names(calendar_month),
    day                            SMALLINT REFERENCES highway_data_services.day_of_month_ordinals(day_of_month),
    day_of_week                    VARCHAR REFERENCES highway_data_services.days_of_week(day_of_week),
    federal_direction              SMALLINT REFERENCES highway_data_services.fhwa_direction_of_travel_code_descriptions(code),
	  lane_code                      SMALLINT,
	  lanes_in_direction             SMALLINT,
	  collection_interval            SMALLINT,
	  data_interval                  REAL REFERENCES highway_data_services.nysdot_data_interval_descriptions(data_interval),
	  class_f1                       INTEGER,
	  class_f2                       INTEGER,
	  class_f3                       INTEGER,
	  class_f4                       INTEGER,
	  class_f5                       INTEGER,
	  class_f6                       INTEGER,
	  class_f7                       INTEGER,
	  class_f8                       INTEGER,
	  class_f9                       INTEGER,
	  class_f10                      INTEGER,
	  class_f11                      INTEGER,
	  class_f12                      INTEGER,
	  class_f13                      INTEGER,
	  unclassified                   INTEGER,
	  total                          INTEGER,
    flag_field                     VARCHAR,
    batch_id                       VARCHAR
);


-- https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb/repository/Field_Definitions_SC%20Formats.pdf

COMMENT ON TABLE highway_data_services.short_count_vehicle_classification IS
'Fifteen Minute short count speed data by direction for a given Region and Year.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.rc_station IS
'Region‐County‐Station number, a seven character code uniquely identifying a traffic segment in NYS. Can be used to join data to shapefiles published by NYSDOT.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.count_id IS
'A unique ID for each count session loaded, each count has one Count_ID for all data types.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.rg IS
'Region Number, a number 1‐11 representing the NYSDOT Region in which the count station is located.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.region_code IS
'A single digit code for each NYSDOT Region. Can be concatenated with County_Code and Station number to create a unique ID.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.county_code IS
'A single digit code for each County within a NYSDOT Region. Can be concatenated with Region_Code and Station number to create a unique ID.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.stat IS
'Station Number, a four digit number unique within a county representing a specific segment of road for traffic counting purposes. Can be concatenated with Region_Code and County_Code to create a unique ID. Typically formatted as text to retain leading zeroes.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.rcsta IS
'Region_Code, County_Code, and Station Number concatenated into a 6 digit unique ID. Typically formatted as text to retain leading zeroes.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.functional_class IS
'Functional Classification of the roadway segment to which the station applies.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.factor_group IS
'Factor Group determines the set of seasonal factors to apply. Factor Groups are 30, 40, or 60 only.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.latitude IS
'Latitude, in decimal degrees, of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.longitude IS
'Longitude, in decimal degrees, of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.specific_recorder_placement IS
'Verbal description of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.channel_notes IS
'Any notes from the count collector, or processor, related to the count. The four digit Continuous Counter ID (CCID) is entered when the record is based on Continuous Data.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.data_type IS
'Currently blank. Represents the number of unclassified vehicles for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.blank IS
'Speed_Limit for the count location in speed data files.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.year IS
'The year in which the data was collected.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.month IS
'The month in which the data was collected.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.day IS
'Where applicable, the day of the month on which the data was collected.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.day_of_week IS
'The day of week the data was collected.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.federal_direction IS
'The federal direction code for the data record. 1 – North, 3 – East, 5 – South, 7 – West, 9 – North/South Combined, 0 – East/West combined.   NOTED ERROR: Many North/South records are incorrectly labeled with a 0 code. Data remains correct.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.lane_code IS
'The lane code by direction, starting with 1 as the rightmost lane.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.lanes_in_direction IS
'The total number of lanes expected in this direction.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.collection_interval IS
'The interval, in minutes, in which the data was collected, typically 15 or 60.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.data_interval IS
'Speed and Classification data only. The interval which the record applies. 1.1 indicates the first 15 minutes of the first hour of the day, or 00:00 through 00:15. 1.2 represents 00:15‐00:30, 12.3 represents 11:30‐11:45, 23.4 represents 22:45‐23:00 and so on.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.class_f1 IS
'The number of vehicles in the FHWA F‐scheme class F1 (Motorcycles) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.class_f2 IS
'The number of vehicles in the FHWA F‐scheme class F2 (Autos) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.class_f3 IS
'The number of vehicles in the FHWA F‐scheme class F3 (2 axle, 4‐tire pickups, vans, motor‐homes) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.class_f4 IS
'The number of vehicles in the FHWA F‐scheme class F4 (Buses) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.class_f5 IS
'The number of vehicles in the FHWA F‐scheme class F5 (2 axle, 6‐tire single unit trucks) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.class_f6 IS
'The number of vehicles in the FHWA F‐scheme class F6 (3 axle single unit trucks) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.class_f7 IS
'The number of vehicles in the FHWA F‐scheme class F7 (4 or more axle single unit trucks) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.class_f8 IS
'The number of vehicles in the FHWA F‐scheme class F8 (4 or less axle vehicles, single trailer) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.class_f9 IS
'The number of vehicles in the FHWA F‐scheme class F9 (5 axle, single trailer) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.class_f10 IS
'The number of vehicles in the FHWA F‐scheme class F10 (6 or more axle, single trailer) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.class_f11 IS
'The number of vehicles in the FHWA F‐scheme class F11 (5 axle multi‐trailer trucks) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.class_f12 IS
'The number of vehicles in the FHWA F‐scheme class F12 (6 axle multi‐trailer trucks) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.class_f13 IS
'The number of vehicles in the FHWA F‐scheme class F13 (7 or more axle multi‐trailer trucks) for the interval represented.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.unclassified IS
'Speed and Classification only. Number of vehicles a counter was unable to correctly place in a bin. Currently blank, as not part of NYSDOT format at this time.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.total IS
'The sum of all bins or intervals for the record.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.flag_field IS
'A field designated to give additional information about a count.';

COMMENT ON COLUMN highway_data_services.short_count_vehicle_classification.batch_id IS
'A system code related to data importing.';

COMMIT;
