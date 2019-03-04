#!/bin/bash

set -e

pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

cd ../../ || exit

export ARCHIVE_DIRECTORY_PATH=archive
export STATE=ny
export PG_ENV=production


for YEAR in $(seq 2015 2018); do
  export YEAR
  for MONTH in $(seq 1 12); do
    export MONTH

    make db/archive-npmrds-state-yrmo
  done
done

popd >/dev/null
