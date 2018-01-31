#!/bin/bash

set -e

cd ../../

make db/drop-mpo-boundaries-view
time make db/create-mpo-boundaries-view
