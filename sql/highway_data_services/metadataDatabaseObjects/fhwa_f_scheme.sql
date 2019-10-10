-- https://www.fhwa.dot.gov/publications/research/infrastructure/pavements/ltpp/13091/002.cfm

BEGIN;

CREATE TABLE highway_data_services.fhwa_f_scheme_class_descriptions (
  class              VARCHAR PRIMARY KEY,
  short_description  VARCHAR UNIQUE,
  long_description   VARCHAR UNIQUE,
  CHECK (
    class IN (
      'F1',
      'F2',
      'F3',
      'F4',
      'F5',
      'F6',
      'F7',
      'F8',
      'F9',
      'F10',
      'F11',
      'F12',
      'F13'
    )
  )
) WITH (fillfactor=100, autovacuum_enabled=false);

-- https://www.fhwa.dot.gov/ohim/tvtw/hvtis.htm
INSERT INTO highway_data_services.fhwa_f_scheme_class_descriptions (class, short_description, long_description)
  VALUES
    ('F1', 'Motorcycles', 'Motorcycles -- All two or three-wheeled motorized vehicles. Typical vehicles in this category have saddle type seats and are steered by handlebars rather than steering wheels. This category includes motorcycles, motor scooters, mopeds, motor-powered bicycles, and three-wheel motorcycles. This vehicle type may be reported at the option of the State.'),
    ('F2', 'Autos', 'Passenger Cars -- All sedans, coupes, and station wagons manufactured primarily for the purpose of carrying passengers and including those passenger cars pulling recreational or other light trailers.'),
    ('F3', '2 axle, 4‐tire pickups, vans, motor‐homes', 'Other Two-Axle, Four-Tire Single Unit Vehicles -- All two-axle, four-tire, vehicles, other than passenger cars. Included in this classification are pickups, panels, vans, and other vehicles such as campers, motor homes, ambulances, hearses, carryalls, and minibuses. Other two-axle, four-tire single-unit vehicles pulling recreational or other light trailers are included in this classification. Because automatic vehicle classifiers have difficulty distinguishing class 3 from class 2, these two classes may be combined into class 2.'),
    ('F4', 'Buses', 'Buses -- All vehicles manufactured as traditional passenger-carrying buses with two axles and six tires or three or more axles. This category includes only traditional buses (including school buses) functioning as passenger-carrying vehicles. Modified buses should be considered to be a truck and should be appropriately classified.'),
    ('F5', '2 axle, 6‐tire single unit trucks', 'Two-Axle, Six-Tire, Single-Unit Trucks -- All vehicles on a single frame including trucks, camping and recreational vehicles, motor homes, etc., with two axles and dual rear wheels.'),
    ('F6', '3 axle single unit trucks', 'Three-Axle Single-Unit Trucks -- All vehicles on a single frame including trucks, camping and recreational vehicles, motor homes, etc., with three axles.'),
    ('F7', '4 or more axle single unit trucks', 'Four or More Axle Single-Unit Trucks -- All trucks on a single frame with four or more axles.'),
    ('F8', '4 or less axle vehicles, single trailer', 'Four or Fewer Axle Single-Trailer Trucks -- All vehicles with four or fewer axles consisting of two units, one of which is a tractor or straight truck power unit.'),
    ('F9', '5 axle, single trailer', 'Five-Axle Single-Trailer Trucks -- All five-axle vehicles consisting of two units, one of which is a tractor or straight truck power unit.'),
    ('F10', '6 or more axle, single trailer', 'Six or More Axle Single-Trailer Trucks -- All vehicles with six or more axles consisting of two units, one of which is a tractor or straight truck power unit.'),
    ('F11', '5 axle multi‐trailer trucks', 'Five or fewer Axle Multi-Trailer Trucks -- All vehicles with five or fewer axles consisting of three or more units, one of which is a tractor or straight truck power unit.'),
    ('F12', '6 axle multi‐trailer trucks', 'Six-Axle Multi-Trailer Trucks -- All six-axle vehicles consisting of three or more units, one of which is a tractor or straight truck power unit.'),
    ('F13', '7 or more axle multi‐trailer trucks', 'Seven or More Axle Multi-Trailer Trucks -- All vehicles with seven or more axles consisting of three or more units, one of which is a tractor or straight truck power unit.')
;

COMMENT ON TABLE highway_data_services.fhwa_f_scheme_class_descriptions IS
'The classification scheme is separated into categories depending on whether the vehicle carries passengers or commodities. Non-passenger vehicles are further subdivided by number of axles and number of units, including both power and trailer units.';

COMMENT ON COLUMN highway_data_services.fhwa_f_scheme_class_descriptions.class IS
'The FHWA 13-category classification rule set currently used for most Federal reporting requirements and that serves as the basis for most State vehicle classification counting efforts.';

COMMIT;
