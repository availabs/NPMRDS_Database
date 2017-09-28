CREATE TABLE IF NOT EXISTS npmrds (
  tmc                            VARCHAR(9),
  date                           DATE,
  epoch                          SMALLINT,
  travel_time_all_vehicles       REAL,
  travel_time_passenger_vehicles REAL,
  travel_time_freight_trucks     REAL,
  state                          CHAR(2)
);
