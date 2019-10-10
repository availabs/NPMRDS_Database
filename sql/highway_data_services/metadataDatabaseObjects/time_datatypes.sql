-- https://www.fhwa.dot.gov/policyinformation/tmguide/tmg_2013/traffic-monitoring-formats.cfm

BEGIN;

CREATE TABLE highway_data_services.calendar_month_names (
  calendar_month      SMALLINT PRIMARY KEY,
  calendar_month_name VARCHAR UNIQUE,
  CHECK (calendar_month BETWEEN 1 AND 12)
) WITH (fillfactor=100, autovacuum_enabled=false);

INSERT INTO highway_data_services.calendar_month_names (calendar_month, calendar_month_name)
VALUES
  (1,  'January'),
  (2,  'February'),
  (3,  'March'),
  (4,  'April'),
  (5,  'May'),
  (6,  'June'),
  (7,  'July'),
  (8,  'August'),
  (9,  'September'),
  (10, 'October'),
  (11, 'November'),
  (12, 'December')
;

CREATE TABLE highway_data_services.days_of_week (
  dow          SMALLINT PRIMARY KEY,
  day_of_week  VARCHAR UNIQUE,
  CHECK (dow BETWEEN 1 AND 7),
  CHECK (
    day_of_week IN (
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    )
  )
) WITH (fillfactor=100, autovacuum_enabled=false);

INSERT INTO highway_data_services.days_of_week (dow, day_of_week)
VALUES
  (1, 'Sunday'),
  (2, 'Monday'),
  (3, 'Tuesday'),
  (4, 'Wednesday'),
  (5, 'Thursday'),
  (6, 'Friday'),
  (7, 'Saturday')
;

CREATE TABLE highway_data_services.day_of_month_ordinals (
  day_of_month         SMALLINT PRIMARY KEY,
  day_of_month_ordinal VARCHAR UNIQUE
  CHECK (day_of_month BETWEEN 1 AND 31)
) WITH (fillfactor=100, autovacuum_enabled=false);

INSERT INTO highway_data_services.day_of_month_ordinals (day_of_month, day_of_month_ordinal)
VALUES
  (1,  '1st'),
  (2,  '2nd'),
  (3,  '3rd'),
  (4,  '4th'),
  (5,  '5th'),
  (6,  '6th'),
  (7,  '7th'),
  (8,  '8th'),
  (9,  '9th'),
  (10, '10th'),
  (11, '11th'),
  (12, '12th'),
  (13, '13th'),
  (14, '14th'),
  (15, '15th'),
  (16, '16th'),
  (17, '17th'),
  (18, '18th'),
  (19, '19th'),
  (20, '20th'),
  (21, '21st'),
  (22, '22nd'),
  (23, '23rd'),
  (24, '24th'),
  (25, '25th'),
  (26, '26th'),
  (27, '27th'),
  (28, '28th'),
  (29, '29th'),
  (30, '30th'),
  (31, '31st')
;

CREATE TABLE highway_data_services.hour_of_day_ranges (
  hour_of_day        SMALLINT PRIMARY KEY,
  time_of_day_range  VARCHAR UNIQUE,
  CHECK (hour_of_day BETWEEN 0 AND 23)
) WITH (fillfactor=100, autovacuum_enabled=false);

INSERT INTO highway_data_services.hour_of_day_ranges (hour_of_day, time_of_day_range)
VALUES
  (0,  '12am to 1am'),
  (1,   '1am to 2am'),
  (2,   '2am to 3am'),
  (3,   '3am to 4am'),
  (4,   '4am to 5am'),
  (5,   '5am to 6am'),
  (6,   '6am to 7am'),
  (7,   '7am to 8am'),
  (8,   '8am to 9am'),
  (9,   '9am to 10am'),
  (10, '10am to 11am'),
  (11, '11am to 12pm'),
  (12, '12pm to 1pm'),
  (13,  '1pm to 2pm'),
  (14,  '2pm to 3pm'),
  (15,  '3pm to 4pm'),
  (16,  '4pm to 5pm'),
  (17,  '5pm to 6pm'),
  (18,  '6pm to 7pm'),
  (19,  '7pm to 8pm'),
  (20,  '8pm to 9pm'),
  (21,  '9pm to 10pm'),
  (22, '10pm to 11pm'),
  (23, '11pm to 12am')
;
  
COMMIT;
