#!/bin/bash

set -e

cd ../../

make db/drop-root-urban-area-populations-table

YEARS=( 2015 2016 )

for YEAR in "${YEARS[@]}"
do
  export YEAR
  time make db/load-year-urban-area-populations-table
done
