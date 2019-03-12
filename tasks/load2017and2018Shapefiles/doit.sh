#!/bin/bash

set -e
set -a

pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

DATA_DIR='../data'

mkdir -p "$DATA_DIR"

export PG_ENV=production

## declare an array variable
declare -a arr=(
  "$(realpath ../../etl/CANADA_conflationYear2017_shpVersion20170906_downloadTS20190311T152437.tar)"
  "$(realpath ../../etl/CANADA_conflationYear2018_shpVersion20181011_downloadTS20190311T152444.tar)"
  "$(realpath ../../etl/USA_conflationYear2017_shpVersion20171108_downloadTS20190311T152401.tar)"
  "$(realpath ../../etl/USA_conflationYear2018_shpVersion20181011_downloadTS20190311T150618.tar)"
)

cd ../../

## now loop through the above array
for TAR_ARCHIVE_PATH in "${arr[@]}"
do
  export TAR_ARCHIVE_PATH

  states_list_archive_path="$(
    tar tf "$TAR_ARCHIVE_PATH" | grep STATES
  )"

  states="$(tar xOf "$TAR_ARCHIVE_PATH" "$states_list_archive_path")"

  while read -r STATE; do
    export STATE
    make db/upload-state-npmrds-shapefile-from-country-tar
  done <<< "$states"
done

popd >/dev/null
