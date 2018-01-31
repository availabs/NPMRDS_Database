#!/bin/bash

set -e

cd ../../

STATE=nj

export STATE

make db/drop-state-occupancy-factor-table
make db/create-state-occupancy-factor-table
