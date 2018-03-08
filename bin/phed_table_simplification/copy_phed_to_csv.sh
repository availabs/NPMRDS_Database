#!/bin/bash

set -e

mkdir -p csv

# source ../../config/postgres.env.local
source ../../config/postgres.env.ares

export PGDATABASE
export PGUSER
export PGPASSWORD
export PGHOST
export PGPORT

psql -c 'COPY (SELECT * FROM phed ORDER BY year, month, tmc) TO STDOUT DELIMITER '\'','\'' CSV HEADER;' \
  > "./csv/phed.csv"
