BEGIN;

CREATE TABLE highway_data_services.average_weekday_vehicle_classification (
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
	  blank                          CHAR(1), 
    year                           SMALLINT,
    month                          SMALLINT REFERENCES highway_data_services.calendar_month_names(calendar_month),
    day_of_first_data              SMALLINT REFERENCES highway_data_services.day_of_month_ordinals(day_of_month),
    federal_direction              SMALLINT REFERENCES highway_data_services.fhwa_direction_of_travel_code_descriptions(code),
    full_count                     CHAR(1),
    avg_wkday_f1s                  INTEGER,
    avg_wkday_f2s                  INTEGER,
    avg_wkday_f3s                  INTEGER,
    avg_wkday_f4s                  INTEGER,
    avg_wkday_f5s                  INTEGER,
    avg_wkday_f6s                  INTEGER,
    avg_wkday_f7s                  INTEGER,
    avg_wkday_f8s                  INTEGER,
    avg_wkday_f9s                  INTEGER,
    avg_wkday_f10s                 INTEGER,
    avg_wkday_f11s                 INTEGER,
    avg_wkday_f12s                 INTEGER,
    avg_wkday_f13s                 INTEGER,
    avg_wkday_unclassified         INTEGER,
    avg_wkday_totals               INTEGER,
    avg_wkday_perc_f3_13           DOUBLE PRECISION,
    avg_wkday_perc_f4_13           DOUBLE PRECISION,
    avg_wkday_perc_f4_7            DOUBLE PRECISION,
    avg_wkday_perc_f8_13           DOUBLE PRECISION,
    avg_wkday_perc_f1              DOUBLE PRECISION,
    avg_wkday_perc_f2              DOUBLE PRECISION,
    avg_wkday_perc_f3              DOUBLE PRECISION,
    avg_wkday_perc_f4              DOUBLE PRECISION,
    avg_wkday_perc_f5_7            DOUBLE PRECISION,
    axle_correction_factor         DOUBLE PRECISION,
    su_peak                        DOUBLE PRECISION,
    cu_peak                        DOUBLE PRECISION,
    su_aadt                        INTEGER,
    cu_aadt                        INTEGER,
    flag_field                     VARCHAR,
    batch_id                       VARCHAR
);


-- https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb/repository/Field_Definitions_SC%20Formats.pdf
COMMENT ON TABLE highway_data_services.average_weekday_vehicle_classification IS
'Short count average weekday class distribution by direction for a given Region and Year. Weekday data is defined as Monday 6am through Friday Noon.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.rc_station IS
'Region‐County‐Station number, a seven character code uniquely identifying a traffic segment in NYS. Can be used to join data to shapefiles published by NYSDOT.'; 

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.count_id IS
'A unique ID for each count session loaded, each count has one Count_ID for all data types.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.rg IS
'Region Number, a number 1‐11 representing the NYSDOT Region in which the count station is located.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.region_code IS
'A single digit code for each NYSDOT Region. Can be concatenated with County_Code and Station number to create a unique ID.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.county_code IS
'A single digit code for each County within a NYSDOT Region. Can be concatenated with Region_Code and Station number to create a unique ID.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.stat IS
'Station Number, a four digit number unique within a county representing a specific segment of road for traffic counting purposes. Can be concatenated with Region_Code and County_Code to create a unique ID. Typically formatted as text to retain leading zeroes.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.rcsta IS
'Region_Code, County_Code, and Station Number concatenated into a 6 digit unique ID. Typically formatted as text to retain leading zeroes.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.functional_class IS
'Functional Classification of the roadway segment to which the station applies.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.factor_group IS
'Factor Group determines the set of seasonal factors to apply. Factor Groups are 30, 40, or 60 only.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.latitude IS
'Latitude, in decimal degrees, of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.longitude IS
'Longitude, in decimal degrees, of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.specific_recorder_placement IS
'Verbal description of the primary counter placement.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.channel_notes IS
'Any notes from the count collector, or processor, related to the count. The four digit Continuous Counter ID (CCID) is entered when the record is based on Continuous Data.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.data_type IS
'A description of the data type contained in the file.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.blank IS
'Blank in Classification data files.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.year IS
'The year in which the data was collected.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.month IS
'The month in which the data was collected.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.day_of_first_data IS
'The first day of data collection for the count.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.federal_direction IS
'The federal direction code for the data record. 1 – North, 3 – East, 5 – South, 7 – West, 9 – North/South Combined, 0 – East/West combined.   NOTED ERROR: Many North/South records are incorrectly labeled with a 0 code. Data remains correct.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.full_count IS
'Indicates if the record represents the total roadway, or just a single direction. ‘blank’ indicates data applies to direction in Federal Direction field. ‘Y’ indicates data applies to the entire roadway.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_f1s IS
'The number of vehicles in the FHWA F‐scheme class F1 (Motorcycles) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_f2s IS
'The number of vehicles in the FHWA F‐scheme class F2 (Autos) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_f3s IS
'The number of vehicles in the FHWA F‐scheme class F3 (2 axle, 4‐tire pickups, vans, motor‐homes) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_f4s IS
'The number of vehicles in the FHWA F‐scheme class F4 (Buses) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_f5s IS
'The number of vehicles in the FHWA F‐scheme class F5 (2 axle, 6‐tire single unit trucks) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_f6s IS
'The number of vehicles in the FHWA F‐scheme class F6 (3 axle single unit trucks) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_f7s IS
'The number of vehicles in the FHWA F‐scheme class F7 (4 or more axle single unit trucks) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_f8s IS
'The number of vehicles in the FHWA F‐scheme class F8 (4 or less axle vehicles, single trailer) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_f9s IS
'The number of vehicles in the FHWA F‐scheme class F9 (5 axle, single trailer) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_f10s IS
'The number of vehicles in the FHWA F‐scheme class F10 (6 or more axle, single trailer) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_f11s IS
'The number of vehicles in the FHWA F‐scheme class F11 (5 axle multi‐trailer trucks) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_f12s IS
'The number of vehicles in the FHWA F‐scheme class F12 (6 axle multi‐trailer trucks) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_f13s IS
'The number of vehicles in the FHWA F‐scheme class F13 (7 or more axle multi‐trailer trucks) as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_unclassified IS
'Currently blank. Represents the number of unclassified vehicles as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_totals IS
'Represents the number of vehicles in all classes as a daily total for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_perc_f3_13 IS
'Represents the percentage of vehicles in classes F3‐F13 for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_perc_f4_13 IS
'Represents the percentage of vehicles in classes F4‐F13, or Heavy Vehicles, for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_perc_f4_7 IS
'Represents the percentage of vehicles in classes F4‐F7, or Single Unit Vehicles, for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_perc_f8_13 IS
'Represents the percentage of vehicles in classes F8‐F13, or Combination Vehicles, for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_perc_f1 IS
'Represents the percentage of vehicles in class F1, or Motorcycles, for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_perc_f2 IS
'Represents the percentage of vehicles in class F2, or Passenger Vehicles, for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_perc_f3 IS
'Represents the percentage of vehicles in class F3, or Light Trucks, for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_perc_f4 IS
'Represents the percentage of vehicles in class F4, or Busses, for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.avg_wkday_perc_f5_7 IS
'Represents the percentage of vehicles in classes F5‐F7, or Single Unit Trucks, for the Average Weekday.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.axle_correction_factor IS
'Represents the axle correction factor for the count based on the Average Weekday class distribution.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.su_peak IS
'Represents the number of vehicles in classes F4‐F7 during the peak hour of the count, expressed as a percentage of the total daily count.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.cu_peak IS
'Represents the number of vehicles in classes F8‐F13 during the peak hour of the count, expressed as a percentage of the total count.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.su_aadt IS
'Currently Blank. The number of Single Unit Vehicles, classes F4‐F7, during an Average Day.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.cu_aadt IS
'Currently Blank. The number of Combination Vehicles, classes F8‐F13, during an Average Day.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.flag_field IS
'A field designated to give additional information about a count.';

COMMENT ON COLUMN highway_data_services.average_weekday_vehicle_classification.batch_id IS
'A system code related to data importing.';


COMMIT;
