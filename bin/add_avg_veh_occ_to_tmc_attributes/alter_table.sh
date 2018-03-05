#!/bin/bash

set -e

source ../../config/postgres.env.local
# source ../../config/postgres.env.ares

export PGDATABASE
export PGUSER
export PGPASSWORD
export PGHOST
export PGPORT

psql -f ./alter_table.sql
