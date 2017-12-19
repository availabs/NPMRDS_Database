#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

cd ..

time make db/create-tmc-attributes
time make db/create-geography-level-attributes-view
