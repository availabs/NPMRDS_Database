#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

cd ..

make scraping/download-fips-codes-csv
make db/load-fips-codes-table
make db/create-state-codes-view

