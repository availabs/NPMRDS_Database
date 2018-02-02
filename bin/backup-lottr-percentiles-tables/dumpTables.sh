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
  --table='public.lottr_percentiles*' \
  --table='nj.lottr_percentiles*' \
  --table='ny.lottr_percentiles*' \
> ./dump/lottr_percentiles.dump.sql
