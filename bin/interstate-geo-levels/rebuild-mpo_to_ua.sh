#!/bin/bash

set -e

cd ../../

make db/drop-mpo-to-ua-table
time make db/load-mpo-to-ua-table
