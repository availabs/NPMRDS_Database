#!/bin/bash

set -e

cd ../../

make db/drop-terse-bq-top-level-measures-fn
make db/create-terse-bq-top-level-measures-fn

make db/drop-verbose-bq-top-level-measures-fn
make db/create-verbose-bq-top-level-measures-fn
