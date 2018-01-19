#!/bin/bash

set -e

cd ../../

make db/drop-mpo-acronyms-table
make db/load-mpo-acronyms-table

make db/drop-mpo-boundaries-view
make db/upload-mpo-boundaries-shapefile

make db/drop-urban-area-boundaries-table
make db/upload-urban-area-boundaries-shapefile

make db/drop-fips-codes-table
make db/create-fips-codes-table
make db/load-fips-codes-table

make db/drop-state-codes-view
make db/create-state-codes-view

make db/drop-geography-level-to-states
make db/create-geography-level-to-states

make db/drop-inrix-shapefile
STATE=nj make db/upload-inrix-shapefile-for-state
STATE=ny make db/upload-inrix-shapefile-for-state

make db/drop-mpo-boundaries-view
make db/create-mpo-boundaries-view

make db/drop-state-abbreviations-table
make db/create-state-abbreviations-table
