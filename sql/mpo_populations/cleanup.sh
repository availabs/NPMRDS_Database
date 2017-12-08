#!/bin/bash

# This script is used to clean up the table
#   as copy/pasted from https://www.planning.dot.gov/mpo.asp

set -e

sed -i 's/,//g' mpo_populations.csv 
sed -i 's/ *\t */,/g' mpo_populations.csv 
sed -i 's/,Click.*//g' mpo_populations.csv 
sed -i '/),/! s/,/,,/' mpo_populations.csv
sed -i 's/ (/,/g' mpo_populations.csv 
sed -i 's/)//g' mpo_populations.csv 
sed -i '1s/^/mpo_name,mpo_acrony,state,major_city,area,population,designation_year\n/' mpo_populations.csv
