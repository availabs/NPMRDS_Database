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
  --table='public.excessive_delay_brkdwn*' \
  --table='nj.excessive_delay_brkdwn*' \
  --table='ny.excessive_delay_brkdwn*' \
> ./dump/excessive_delay_brkdwn.dump.sql
