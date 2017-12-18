#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

DATA_DIR=../data/csv/fip_codes/us

mkdir -p ${DATA_DIR}

FILE_NAME=fips_codes.us.csv.gz

curl 'https://www2.census.gov/geo/docs/reference/codes/files/national_county.txt' |\
  awk -F"," '{print tolower($1),$2,$3,$4}' OFS="," |\
  sed 's/ \w\+$//g' |\
  gzip > "${DATA_DIR}/${FILE_NAME}"
