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


DATA_DIR=../data/csv/fip_codes/cn

mkdir -p ${DATA_DIR}

FILE_NAME=fips_codes.cn.csv.gz

# NOTE: Canadian FIPS codes were transformed using the following rule:
#     1. Drop the CA prefix
#     2. Add 80 to the remaining 2-digit code
#   Example: CA08 -> 88
CANADIAN_FIPS_SUBSET="ab,81,002,Division No. 2
bc,82,003,Central Kootenay
bc,82,009,Fraser Valley
bc,82,015,Greater Vancouver
mb,83,003,Division No.  3
nb,84,011,Carleton
nb,84,002,Charlotte
nb,84,013,Madawaska
on,88,057,Algoma
on,88,037,Essex
on,88,038,Lambton
on,88,007,Leeds and Grenville
on,88,026,Niagara
qc,90,070,Beauce-Sartigan
qc,90,046,Brome-Missisquoi
qc,90,044,Coaticook
qc,90,056,Le Haut-Richelieu
qc,90,068,Les Jardins-de-Napierville
qc,90,045,Memphrémagog
sk,91,001,Division No.  1"

echo "${CANADIAN_FIPS_SUBSET}" |
  gzip > "${DATA_DIR}/${FILE_NAME}"
