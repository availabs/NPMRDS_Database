#!/bin/bash

set -e
set -a

# Change CWD to this script's directory.
pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

if [ "$PG_ENV" = "production" ]; then
	. ../../config/postgres.env.ares
else
	. ../../config/postgres.env.dev
fi

popd >/dev/null

pushd ../../

for year in $( seq 2016 2019 ); do
  while read -r state; do
    ./run load_state_year_tmc_metadata --year="${year}" --state="${state}" --pg_env=production
  done <<< "$( psql -c "COPY (SELECT DISTINCT state FROM tmc_metadata_${year}) TO STDOUT;" )"
done

popd >/dev/null
