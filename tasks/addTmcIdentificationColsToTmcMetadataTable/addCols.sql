BEGIN;

alter table tmc_metadata_:YEAR add column type varchar;
alter table tmc_metadata_:YEAR add column road varchar;
alter table tmc_metadata_:YEAR add column road_order real;
alter table tmc_metadata_:YEAR add column intersection varchar;
alter table tmc_metadata_:YEAR add column isprimary smallint;
alter table tmc_metadata_:YEAR add column timezone_name varchar;
alter table tmc_metadata_:YEAR add column active_start_date date;
alter table tmc_metadata_:YEAR add column active_end_date date;

COMMIT;
