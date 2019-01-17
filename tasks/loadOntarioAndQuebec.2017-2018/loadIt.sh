#!/bin/bash

set -e

pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

cd ../../ || exit

## declare an array variable
declare -a PROVINCES=("on" "qc")

export PG_ENV

## now loop through the above array
for STATE in "${PROVINCES[@]}"; do
  export STATE
  for YEAR in $(seq 2017 2018); do
    export YEAR
    for MONTH in $(seq 1 12); do
      export MONTH

      make db/upload-npmrds-state-yrmo
      make db/postprocess-npmrds-state-yrmo
    done
  done
done

popd >/dev/null
