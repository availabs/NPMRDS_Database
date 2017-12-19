#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

cd ..

export YEAR=2017

make scraping/download-core-based-statistical-area-boundaries-shapefile
make scraping/download-urban-area-boundaries-shapefile

psql -h127.0.0.1 -Unpmrds_ninja -p5432 -dnpmrds_test -W -c 'DROP VIEW core_based_statistical_area_boundaries CASCADE';
psql -h127.0.0.1 -Unpmrds_ninja -p5432 -dnpmrds_test -W -c 'DROP VIEW mpo_boundaries CASCADE';
psql -h127.0.0.1 -Unpmrds_ninja -p5432 -dnpmrds_test -W -c 'DROP VIEW urban_area_boundaries CASCADE';

make scraping/download-core-based-statistical-area-boundaries-shapefile
make scraping/download-urban-area-boundaries-shapefile

make db/upload-core-based-staticstical-area-boundaries-shapefile
make db/upload-mpo-boundaries-shapefile
make db/upload-urban-area-boundaries-shapefile

make db/create-mpo-boundaries-view
