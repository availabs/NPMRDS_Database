CREATE TABLE :"STATE".npmrds_shapefile_:YEAR (
  PRIMARY KEY (tmc),
  CHECK(conflation_year = :YEAR)
) INHERITS (:"STATE".npmrds_shapefile);

