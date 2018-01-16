#!/bin/bash

set -e

source ../../config/postgres.env

export PGDATABASE
export PGUSER
export PGPASSWORD
export PGHOST
export PGPORT

pushd ../../

STATE=nj make db/create-state-average-speedlimits-table

popd

psql -c "COPY nj.avg_speedlimits FROM STDIN CSV HEADER;" < ./nj.avg_speedlimits.csv

# # npmrds_test=# select count(distinct tmc) from nj.tmc_attributes where tmc not in (select distinct tmc from nj.avg_speedlimits);
# #  count
# # -------
# #   6584
# # (1 row)

psql -f './backfill-speedlimits-using-regex.sql'

# # npmrds_test=# select count(tmc) from nj.tmc_attributes where tmc not in (select tmc from nj.avg_speedlimits);
# #  count
# # -------
# #   1176
# # (1 row)
# # 
# # npmrds_test=# select count(tmc) from nj.tmc_attributes;
# #  count
# # -------
# #  10525
# # (1 row)
# # 
# # npmrds_test=# select 1176.0 / 10525.0;
# #         ?column?
# # ------------------------
# #  0.11173396674584323040
# # (1 row)

psql -f './backfill-nj.tmc_attributes.sql'
