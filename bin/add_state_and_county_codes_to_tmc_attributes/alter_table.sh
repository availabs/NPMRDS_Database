#!/bin/bash

set -e
set -a

source ../../config/postgres.env.local
# source ../../config/postgres.env.ares

psql -f ./alter_table.sql
