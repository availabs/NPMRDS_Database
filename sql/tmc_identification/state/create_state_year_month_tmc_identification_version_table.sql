\set tbl_name :"STATE"'.tmc_identification_':YEAR'_v':DOWNLOAD_TIMESTAMP

CREATE TABLE IF NOT EXISTS :tbl_name (
  LIKE :"STATE".tmc_identification_:YEAR INCLUDING ALL,
  PRIMARY KEY(tmc),
  CHECK(download_timestamp = :'DOWNLOAD_TIMESTAMP'::TIMESTAMP)
) WITH (fillfactor = 100, autovacuum_enabled=false);

ALTER TABLE :tbl_name
  ALTER download_timestamp SET DEFAULT :'DOWNLOAD_TIMESTAMP';
