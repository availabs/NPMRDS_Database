#!/bin/bash

set -e

mkdir -p ./sql

pg_dump -hares.availabs.org -Unpmrds_ninja -dnpmrds_test --schema-only --no-owner > ./sql/ares.schema.sql
