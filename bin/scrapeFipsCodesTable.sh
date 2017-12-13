#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

DATA_DIR=../data/csv/fip_codes/us

mkdir -p ${DATA_DIR}

FILE_NAME=fips_codes.us.csv.gz

#curl 'https://www2.census.gov/geo/docs/reference/codes/files/national_county.txt' | sed 's/\s\w\+,/,/g' 
curl 'https://www2.census.gov/geo/docs/reference/codes/files/national_county.txt' | gzip > "${DATA_DIR}/${FILE_NAME}"
