#!/bin/bash

set -e

source ../../config/postgres.env

export PGDATABASE
export PGUSER
export PGPASSWORD
export PGHOST
export PGPORT

cd ./csv

for f in *; do
  psql -c "TRUNCATE ${f};" -c "COPY ${f} FROM STDIN CSV HEADER;" < "$f"
done
