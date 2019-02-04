#!/bin/bash

set -e
set -a

if ! [ -x "$(command -v 7za)" ]; then
  echo 'The 7za program is required to extract the RITIS shapefiles.'
  echo 'See: https://unix.stackexchange.com/a/183453'
  exit 1
fi;

if [ -z "$1" ]; then
  echo "ERROR: The required 1st cli arg is the Zipped Shapefile path."
  exit 1
fi;

if [ ! -f "$1" ]; then
  echo "ERROR: No file found at the provided Zipped Shapefile path $1."
  exit 1
fi;

# Get absolute paths
SHP_ZIP_PATH="$(readlink -f "$1")"
SHP_ZIP_DIR="$( dirname "$SHP_ZIP_PATH")"

# Change to this scripts dir so we can use relative paths for dependencies.
pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

# Get the stateName -> stateAbbreviation associative array
. ../../bin/stateAbbreviations.sh;

# Change to the zipped shapefile's dir
cd "$SHP_ZIP_DIR" || exit

STATES_DIR=states;

# If the STATES_DIR output directory currently exists, exit.
if [[ -d "$STATES_DIR" ]]; then
  (
    >&2 echo "ERROR: It appears the shapefile has already been partitioned.
      Before continuing, remove ${SHP_ZIP_DIR}states"
  )
  exit 1
fi;

mkdir -p "$STATES_DIR"

7za x "$SHP_ZIP_PATH" -o"$STATES_DIR"

cd "$STATES_DIR" || exit;

# Move all files for each state into the state's respective directory.
#   Each state gets a dir based on it's 2 letter code.
#   NOTE: "state" includes Mexico (mx) and Canada (cn)
while read -r s; do
  state="$(sed 's/ //g;' <<< "${s,,}")"
  dir="${STATE_ABBREVIATIONS[${state}]}";
  if [[ -z "$dir" ]]; then
    echo "$state is not a recognized state" 
  else
    mkdir "$dir";
    mv "$s"* "$dir";
  fi
done <<< "$(find . -type f | sed 's/^\.\///; s/\..*//g;' | sort -u)"

LATEST_VER='00000000'

while read -r state_dir; do
  pushd "${state_dir}" >/dev/null;

  # Get the last update info from the state's shapfile
  ver=$(ogrinfo -ro -so -al . | grep 'DBF_DATE_LAST_UPDATE' | sed 's/.*=//g; s/-//g');
  if [ -z "${ver}" ]; then ver="$LATEST_VER"; fi;

  # Update the interstate LATEST_VER, if needed.
  if [[ "${ver}" > "${LATEST_VER}" ]]; then LATEST_VER="$ver"; fi;

  popd >/dev/null;

  # Create a zip archive of the state specific shapefile.
  zip -q -rm "${state_dir}.zip" "$state_dir";
done <<< "$(find . -mindepth 1 -type d )"

echo "$LATEST_VER" > "${SHP_ZIP_DIR}/SHAPEFILE_VERSION"

popd >/dev/null

