#!/bin/bash

. ../config/postgres.env.local

docker exec -it npmrds_api_db su postgres -c "psql -U${PGUSER} ${PGDATABASE}"
