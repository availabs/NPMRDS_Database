#!/bin/bash

set -e

cd ../

# source ./config/postgres.env.local
# source ./config/postgres.env.ares
source ./config/postgres.env

export PGDATABASE
export PGUSER
export PGPASSWORD
export PGHOST
export PGPORT

SQL="
  SELECT *
    FROM (
      SELECT
          'STATE=' || schemaname ||
          ' YEAR=' || substring(tablename from 9 for 4) ||
          ' MONTH=' || substring(tablename from 14 for 2)
        FROM pg_tables
        WHERE (tablename LIKE '%npmrds_y%')
      UNION
      SELECT DISTINCT
          'STATE=' || schemaname ||
          ' YEAR=' || substring(tablename from 9 for 4) ||
          ' MONTH=00'
        FROM pg_tables
        WHERE (tablename LIKE '%npmrds_y%')
    ) AS t(c)
    ORDER BY c
;"

OUTPUT=$(psql --tuples-only -c "${SQL}")

make db/drop-root-lottr-table
make db/drop-root-tttr-table
make db/drop-root-phed-table

echo "${OUTPUT}" |\
while read -r line ; do

  eval "${line}"

  export STATE
  export YEAR
  export MONTH

  make db/load-state-lottr-yrmo-table
  make db/load-state-tttr-yrmo-table
  make db/load-state-phed-yrmo-table
done

