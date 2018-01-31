#!/bin/bash

set -e

cd ../../

make db/drop-geography-level-to-states
time make db/create-geography-level-to-states
