#!/bin/bash

set -e

psql -hpod2.rit.albany.edu -Unpmrds_user -dnpmrds_api \
  -c "COPY (SELECT * FROM avg_speedlimits WHERE state = 'nj' ORDER BY tmc) TO STDOUT CSV HEADER;" \
  > nj.avg_speedlimits.csv
