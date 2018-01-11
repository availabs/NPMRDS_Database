#!/bin/bash

set -e

cd ..

source ./config/postgres.env

export PGDATABASE
export PGUSER
export PGPASSWORD
export PGHOSTADDR
export PGPORT


psql -c 'DROP MATERIALIZED VIEW IF EXISTS tmc_attributes CASCADE;'

export STATE=ny
time make db/load-state-tmc-attributes

export STATE=nj
time make db/load-state-tmc-attributes

psql -f './etc/pm_bottlenecks_summary.sql'

time make db/create-geography-level-attributes-view

