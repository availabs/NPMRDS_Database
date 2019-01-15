#!/bin/bash

set -e
set -a

if ! [ -x "$(command -v 7za)" ]; then
  echo 'The 7za program is required to extract the RITIS shapefiles.'
  echo 'See: https://unix.stackexchange.com/a/183453'
  exit 1
fi;

if [[ -z "$1" ]]; then
  echo "ERROR: 1st cli arg is the WORK_DIR where Zipped Shapefile are located."
  exit 1
fi;

WORK_DIR="$(readlink -f "$1")"

pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

. ../../bin/stateAbbreviations.sh;

cd "$WORK_DIR" || exit

STATES_DIR=states;

# If the STATES_DIR output directory currently exists, rename it,
#   using the timestamp of it last data modification as the suffix.
if [[ -d "$STATES_DIR" ]]; then
  STATES_DIR_TIMESTAMP="$(stat -c %Y "$STATES_DIR")"
  mv "$STATES_DIR" "${STATES_DIR}_${STATES_DIR_TIMESTAMP}"
fi;

mkdir -p "$STATES_DIR"

# Unzip all archives in the WORK_DIR, and send to the STATES_DIR
ls -la

while read -r f; do
  echo "### $f ###"
  7za x "$f" -o"$STATES_DIR"
done <<< "$(find . -maxdepth 1 -name '*.zip')"

cd "$STATES_DIR" || exit;

# Move all files for each state into the state's respective directory.
#   Each state gets a dir based on it's 2 letter code.
#   NOTE: "state" includes Mexico (mx) and Canada (cn)
while read -r s; do
  state="$(sed 's/ //g;' <<< ${s,,})"
  dir="${STATE_ABBREVIATIONS[${state}]}";
  if [[ -z "$dir" ]]; then
    echo "$state is not a recognized state" 
  else
    mkdir "$dir";
    mv "$s"* "$dir";
  fi
done <<< "$(find . -type f | sed 's/^\.\///; s/\..*//g;' | sort -u)"

while read -r state_dir; do
  pushd "${state_dir}";
  ver=$(ogrinfo -ro -so -al . | grep 'DBF_DATE_LAST_UPDATE' | sed 's/.*=//g; s/-//g');
  if [ -z "${ver}" ]; then ver='00000000'; fi;
  mkdir -p ${ver};
  find . -maxdepth 1 -type f -exec mv "{}" "${ver}/{}" \;
  popd;
  zip -rm "${state_dir}_${ver}.zip" "$state_dir";
done <<< "$(find . -mindepth 1 -type d )"

popd >/dev/null
