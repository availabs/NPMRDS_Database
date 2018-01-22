#!/bin/bash

set -e

cd ../../



#!/bin/bash

set -e

cd ..

ulimit -n 8192

export YEAR=2017
export MONTH=12

STATES=(ny nj)

time make db/drop-root-tmc-attributes

for STATE in "${STATES[@]}"
do
  export STATE
  time make db/load-state-tmc-attributes
done

