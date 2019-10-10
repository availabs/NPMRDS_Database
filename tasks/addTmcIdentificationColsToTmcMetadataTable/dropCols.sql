BEGIN;

alter table tmc_metadata_:YEAR drop column road;
alter table tmc_metadata_:YEAR drop column intersection;

COMMIT;
