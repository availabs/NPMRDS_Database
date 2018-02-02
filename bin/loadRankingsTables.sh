#!/bin/bash

set -e

cd ../

source ./config/postgres.env.local
# source ./config/postgres.env.ares

export PGDATABASE
export PGUSER
export PGPASSWORD
export PGHOST
export PGPORT

SQL="
  SELECT *
    FROM (
      SELECT
          ' YEAR=' || substring(tablename from 9 for 4) ||
          ' MONTH=' || substring(tablename from 14 for 2)
        FROM pg_tables
        WHERE (tablename LIKE '%npmrds_y%')
      UNION
      SELECT DISTINCT
          ' YEAR=' || substring(tablename from 9 for 4) ||
          ' MONTH=00'
        FROM pg_tables
        WHERE (tablename LIKE '%npmrds_y%')
    ) AS t(c)
    ORDER BY c
;"

OUTPUT=$(psql --tuples-only -c "${SQL}")

echo "${OUTPUT}" |\
while read -r line ; do

  eval "${line}"

  export YEAR
  export MONTH

  make db/load-lottr-percentiles-rankings-yrmo-table
  make db/load-tttr-percentiles-rankings-yrmo-table
  make db/load-excessive-delay-rankings-yrmo-table
done

