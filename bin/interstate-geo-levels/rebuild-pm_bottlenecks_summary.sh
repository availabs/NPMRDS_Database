#!/bin/bash

set -e

cd ../../

source ./config/postgres.env.local
# source ./config/postgres.env.ares

export PGDATABASE
export PGUSER
export PGPASSWORD
export PGHOST
export PGPORT

psql -f ../../etc/pm_bottlenecks_summary.sql

