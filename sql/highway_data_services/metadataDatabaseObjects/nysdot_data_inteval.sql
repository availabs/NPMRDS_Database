-- https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb/repository/Field_Definitions_SC%20Formats.pdf

BEGIN;

CREATE TABLE highway_data_services.nysdot_data_interval_descriptions (
  data_interval                REAL PRIMARY KEY,
  data_interval_description    VARCHAR(64) UNIQUE,
  CHECK (
    ( FLOOR(data_interval) BETWEEN 1 AND 24 )
    AND
    ( MOD((data_interval * 10)::INTEGER, 10) IN (1, 2, 3, 4) )
  )
) WITH (fillfactor=100, autovacuum_enabled=false);

INSERT INTO highway_data_services.nysdot_data_interval_descriptions (data_interval, data_interval_description)
VALUES
  (1.1,  '00:00 through 00:15'),
  (1.2,  '00:15 through 00:30'),
  (1.3,  '00:30 through 00:45'),
  (1.4,  '00:45 through 01:00'),
  (2.1,  '01:00 through 01:15'),
  (2.2,  '01:15 through 01:30'),
  (2.3,  '01:30 through 01:45'),
  (2.4,  '01:45 through 02:00'),
  (3.1,  '02:00 through 02:15'),
  (3.2,  '02:15 through 02:30'),
  (3.3,  '02:30 through 02:45'),
  (3.4,  '02:45 through 03:00'),
  (4.1,  '03:00 through 03:15'),
  (4.2,  '03:15 through 03:30'),
  (4.3,  '03:30 through 03:45'),
  (4.4,  '03:45 through 04:00'),
  (5.1,  '04:00 through 04:15'),
  (5.2,  '04:15 through 04:30'),
  (5.3,  '04:30 through 04:45'),
  (5.4,  '04:45 through 05:00'),
  (6.1,  '05:00 through 05:15'),
  (6.2,  '05:15 through 05:30'),
  (6.3,  '05:30 through 05:45'),
  (6.4,  '05:45 through 06:00'),
  (7.1,  '06:00 through 06:15'),
  (7.2,  '06:15 through 06:30'),
  (7.3,  '06:30 through 06:45'),
  (7.4,  '06:45 through 07:00'),
  (8.1,  '07:00 through 07:15'),
  (8.2,  '07:15 through 07:30'),
  (8.3,  '07:30 through 07:45'),
  (8.4,  '07:45 through 08:00'),
  (9.1,  '08:00 through 08:15'),
  (9.2,  '08:15 through 08:30'),
  (9.3,  '08:30 through 08:45'),
  (9.4,  '08:45 through 09:00'),
  (10.1, '09:00 through 09:15'),
  (10.2, '09:15 through 09:30'),
  (10.3, '09:30 through 09:45'),
  (10.4, '09:45 through 10:00'),
  (11.1, '10:00 through 10:15'),
  (11.2, '10:15 through 10:30'),
  (11.3, '10:30 through 10:45'),
  (11.4, '10:45 through 11:00'),
  (12.1, '11:00 through 11:15'),
  (12.2, '11:15 through 11:30'),
  (12.3, '11:30 through 11:45'),
  (12.4, '11:45 through 12:00'),
  (13.1, '12:00 through 12:15'),
  (13.2, '12:15 through 12:30'),
  (13.3, '12:30 through 12:45'),
  (13.4, '12:45 through 13:00'),
  (14.1, '13:00 through 13:15'),
  (14.2, '13:15 through 13:30'),
  (14.3, '13:30 through 13:45'),
  (14.4, '13:45 through 14:00'),
  (15.1, '14:00 through 14:15'),
  (15.2, '14:15 through 14:30'),
  (15.3, '14:30 through 14:45'),
  (15.4, '14:45 through 15:00'),
  (16.1, '15:00 through 15:15'),
  (16.2, '15:15 through 15:30'),
  (16.3, '15:30 through 15:45'),
  (16.4, '15:45 through 16:00'),
  (17.1, '16:00 through 16:15'),
  (17.2, '16:15 through 16:30'),
  (17.3, '16:30 through 16:45'),
  (17.4, '16:45 through 17:00'),
  (18.1, '17:00 through 17:15'),
  (18.2, '17:15 through 17:30'),
  (18.3, '17:30 through 17:45'),
  (18.4, '17:45 through 18:00'),
  (19.1, '18:00 through 18:15'),
  (19.2, '18:15 through 18:30'),
  (19.3, '18:30 through 18:45'),
  (19.4, '18:45 through 19:00'),
  (20.1, '19:00 through 19:15'),
  (20.2, '19:15 through 19:30'),
  (20.3, '19:30 through 19:45'),
  (20.4, '19:45 through 20:00'),
  (21.1, '20:00 through 20:15'),
  (21.2, '20:15 through 20:30'),
  (21.3, '20:30 through 20:45'),
  (21.4, '20:45 through 21:00'),
  (22.1, '21:00 through 21:15'),
  (22.2, '21:15 through 21:30'),
  (22.3, '21:30 through 21:45'),
  (22.4, '21:45 through 22:00'),
  (23.1, '22:00 through 22:15'),
  (23.2, '22:15 through 22:30'),
  (23.3, '22:30 through 22:45'),
  (23.4, '22:45 through 23:00'),
  (24.1, '23:00 through 23:15'),
  (24.2, '23:15 through 23:30'),
  (24.3, '23:30 through 23:45'),
  (24.4, '23:45 through 24:00')
;

COMMENT ON TABLE highway_data_services.nysdot_data_interval_descriptions IS 'NYSDOT data_interval code descriptions.';

COMMENT ON COLUMN highway_data_services.nysdot_data_interval_descriptions.data_interval IS
'The interval which the record applies. 1.1 indicates the first 15 minutes of the first hour of the day, or 00:00 through 00:15. 1.2 represents 00:15‐00:30, 12.3 represents 11:30‐11:45, 23.4 represents 22:45‐23:00 and so on.';

COMMENT ON COLUMN highway_data_services.nysdot_data_interval_descriptions.data_interval_description IS
'NYSDOT data_interval code description.';

COMMIT;
