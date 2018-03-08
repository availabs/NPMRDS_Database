#!/bin/bash

#  npmrds_local=# drop table tmc_attributes ;
#  ERROR:  cannot drop table tmc_attributes because other objects depend on it
#  DETAIL:  materialized view geography_level_to_states depends on table tmc_attributes
#  materialized view ny.pm_bottlenecks_summary depends on table tmc_attributes
#  materialized view geography_level_attributes_view depends on table tmc_attributes
#  table nj.tmc_attributes depends on table tmc_attributes
#  table ny.tmc_attributes depends on table tmc_attributes
#  HINT:  Use DROP ... CASCADE to drop the dependent objects too.

set -e

source ../../config/postgres.env.local

export PGDATABASE
export PGUSER
export PGPASSWORD
export PGHOST
export PGPORT

psql -c "COPY ny.npmrds_y2017m12 FROM STDIN" < ./npmrds.201712.Albany.csv 
