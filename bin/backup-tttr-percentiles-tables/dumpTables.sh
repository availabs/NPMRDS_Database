#!/bin/bash

set -e

mkdir -p ./dump

source ../../config/postgres.env.ares
# source ./config/postgres.env.ares

export PGDATABASE
export PGUSER
export PGPASSWORD
export PGHOST
export PGPORT

pg_dump \
  --verbose \
  --no-owner \
  --table='public.tttr_percentiles*' \
  --table='nj.tttr_percentiles*' \
  --table='ny.tttr_percentiles*' \
> ./dump/tttr_percentiles.dump.sql
