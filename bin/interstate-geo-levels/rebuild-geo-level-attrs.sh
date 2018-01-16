#!/bin/bash

set -e

cd ../../

make db/drop-geography-level-attributes-view
time make db/create-geography-level-attributes-view
