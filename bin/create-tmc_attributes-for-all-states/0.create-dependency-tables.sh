#!/bin/bash

pushd "$( dirname "${BASH_SOURCE[0]}" )/../../" >/dev/null

make db/load-fips-codes-table

make db/upload-mpo-boundaries-shapefile
make db/create-mpo-boundaries-view

make db/upload-urban-area-boundaries-shapefile

popd >/dev/null
