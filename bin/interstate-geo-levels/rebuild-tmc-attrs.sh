#!/bin/bash

set -e

cd ../../

STATES=(ny nj)

time make db/drop-root-tmc-attributes

for STATE in "${STATES[@]}"
do
  export STATE
  time make db/load-state-tmc-attributes
done

