#!/bin/bash

set -e

source ../../config/postgres.env

export PGDATABASE
export PGUSER
export PGPASSWORD
export PGHOST
export PGPORT

psql < ./sql/ares.schema.sql

