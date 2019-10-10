BEGIN;

CREATE TABLE highway_data_services.continuous_vehicle_classification (
    rc            VARCHAR(2),
    station       VARCHAR(4),
    region        SMALLINT REFERENCES highway_data_services.nysdot_region_names(region),
    dotid         VARCHAR,
    ccid          VARCHAR(4),
    fc            SMALLINT REFERENCES highway_data_services.nysdot_functional_classification_code_descriptions(code),
    route         VARCHAR,
    roadname      VARCHAR,
    county        VARCHAR,
    county_fips   VARCHAR(3),
    begin_desc    VARCHAR,
    end_desc      VARCHAR,
    station_id    VARCHAR(6),
    road          SMALLINT REFERENCES highway_data_services.nysdot_road_direction_code_descriptions(code),
    one_way       CHAR(1) REFERENCES highway_data_services.nysdot_one_way_road_flag_descriptions(flag_value),
    year          SMALLINT,
    month         SMALLINT REFERENCES highway_data_services.calendar_month_names(calendar_month),
    day           SMALLINT REFERENCES highway_data_services.day_of_month_ordinals(day_of_month),
    dow           SMALLINT REFERENCES highway_data_services.days_of_week(dow),
    hour          SMALLINT REFERENCES highway_data_services.hour_of_day_ranges(hour_of_day),
    f1            INTEGER,
    f2            INTEGER,
    f3            INTEGER,
    f4            INTEGER,
    f5            INTEGER,
    f6            INTEGER,
    f7            INTEGER,
    f8            INTEGER,
    f9            INTEGER,
    f10           INTEGER,
    f11           INTEGER,
    f12           INTEGER,
    f13           INTEGER
);


-- https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb/repository/Field_Definitions_CC%20Formats.pdf

COMMENT ON TABLE highway_data_services.continuous_vehicle_classification IS
'Hourly continuous count class data by direction for a given Region and Year.';


COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.rc IS
'Region County Code, a two digit NYSDOT code representing the Region and County number within the Region.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.station IS
'A four digit number, unique within a county representing a specific segment of road for traffic counting purposes.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.region IS
'The NYSDOT Region number.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.dotid IS
'A unique ID for the road where the station is located.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.ccid IS
'Continuous Count ID, a four digit number identifying a continuous count location within a station. May also be referred to as CCSTA or Continuous Count Station Number.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.fc IS
'Functional Class of the roadway segment to which the station applies.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.route IS
'Route number of the roadway segment to which the station applies.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.roadname IS
'Name of the roadway segment to which the station applies.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.county IS
'Name of the county where the station is located.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.county_fips IS
'The FIPS county code is a five-digit Federal Information Processing Standards (FIPS) code (FIPS 6-4) which uniquely identifies counties and county equivalents in the United States, certain U.S. possessions, and certain freely associated states.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.begin_desc IS
'A description of the beginning of the roadway segment to which the station applies.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.end_desc IS
'A description of the ending of the roadway segment to which the station applies.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.station_id IS
'A concatenation of the Region County and Station fields. Creates a Unique six character ID for each station statewide.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.road IS
'The direction of the data for each record. 99 represents data traveling from the Begin Desc to the End Desc, or primary direction. ‐99 represents data traveling from the End Desc to the Begin Desc, or non‐primary direction.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.one_way IS
'Indicates if the segment is a one‐way road. ‘Y’ for one‐way or null for bi‐directional.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.year IS
'The year in which the data was collected.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.month IS
'Where applicable, the month in which the data was collected.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.day IS
'Where applicable, the day of the month on which the data was collected.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.dow IS
'Day of Week. Where applicable, the day of week, expressed as 1‐7 with 1 being Sunday and 7 being Saturday.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.hour IS
'Where applicable, the hour of the day in which the data was collected. Represented as 0‐23 where 0 is data from 12am‐1am and so on.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.f1 IS
'The number of vehicles in FHWA F‐scheme class f1 (Motorcycles) for the interval represented.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.f2 IS
'The number of vehicles in FHWA F‐scheme class f2 (Autos) for the interval represented.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.f3 IS
'The number of vehicles in FHWA F‐scheme class f3 (2 axle, 4‐tire pickups, vans, motor‐homes) for the interval represented.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.f4 IS
'The number of vehicles in FHWA F‐scheme class f4 (Buses) for the interval represented.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.f5 IS
'The number of vehicles in FHWA F‐scheme class f5 (2 axle, 6‐tire single unit trucks) for the interval represented.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.f6 IS
'The number of vehicles in FHWA F‐scheme class f6 (3 axle single unit trucks) for the interval represented.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.f7 IS
'The number of vehicles in FHWA F‐scheme class f7 (4 or more axle single unit trucks) for the interval represented.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.f8 IS
'The number of vehicles in FHWA F‐scheme class f8 (4 or less axle vehicles, single trailer) for the interval represented.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.f9 IS
'The number of vehicles in FHWA F‐scheme class f9 (5 axle, single trailer) for the interval represented.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.f10 IS
'The number of vehicles in FHWA F‐scheme class f10 (6 or more axle, single trailer) for the interval represented.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.f11 IS
'The number of vehicles in FHWA F‐scheme class f11 (5 axle multi‐trailer trucks) for the interval represented.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.f12 IS
'The number of vehicles in FHWA F‐scheme class f12 (6 axle multi‐trailer trucks) for the interval represented.';

COMMENT ON COLUMN highway_data_services.continuous_vehicle_classification.f13 IS
'The number of vehicles in FHWA F‐scheme class f13 (7 or more axle multi‐trailer trucks) for the interval represented.';


COMMIT;
