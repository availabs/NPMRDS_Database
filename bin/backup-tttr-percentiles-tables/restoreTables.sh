#!/bin/bash

set -e

mkdir -p ./dump

source ../../config/postgres.env.local
# source ./config/postgres.env.ares

export PGDATABASE
export PGUSER
export PGPASSWORD
export PGHOST
export PGPORT

psql -f ./dump/tttr_percentiles.dump.sql
