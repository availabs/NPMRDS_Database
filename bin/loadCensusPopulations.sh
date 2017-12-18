#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

cd ..

export YEAR=2016

time make scraping/download-county-populations-csv-for-year
time make db/drop-year-county-populations-table
time make db/load-year-county-populations-table

time make scraping/download-state-populations-csv-for-year
time make db/drop-year-state-populations-table
time make db/load-year-state-populations-table

time make scraping/download-urban-area-populations-csv-for-year
time make db/drop-year-urban-area-populations-table
time make db/load-year-urban-area-populations-table

