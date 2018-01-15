#!/bin/bash

set -e

source ../../config/postgres.env

export PGDATABASE
export PGUSER
export PGPASSWORD
export PGHOST
export PGPORT

mkdir -p csv

SQL="
	SELECT schemaname || '.' || tablename
		FROM pg_tables
		WHERE (
      (
        (tablename = ANY(ARRAY['tmc_attributes']))
        OR
        (tablename LIKE '%county_populations%')
        OR
        (tablename LIKE '%state_populations%')
        OR
        (tablename LIKE '%state_codes%')
      )
      AND
      (schemaname <> 'public')
		)
		ORDER BY schemaname, tablename
;"

OUTPUT=$(psql --tuples-only -c "${SQL}")

echo "${OUTPUT}" |\
while read -r line ; do
  psql -c "COPY (SELECT * FROM ${line}) TO STDOUT CSV HEADER;" > "./csv/${line}"
done

