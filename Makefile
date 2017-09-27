# Based on the following Makefile 
#   https://github.com/stamen/toner-carto/blob/master/Makefile
# And its explanatory blog post found here:
#   http://mojodna.net/2015/01/07/make-for-data-using-make.html

# Use bash for sub-shells, allowing use of bash-specific functionality.
SHELL := /bin/bash

# Add npm-installed binaries to the PATH.
PATH := $(PATH):node_modules/.bin

_DOWNLOAD_DIR := data/inrix-downloads

# GNU Make unnecessarily re-running pattern rules:  https://stackoverflow.com/a/19018178/3970755
.PRECIOUS: ${_DOWNLOAD_DIR}/%/data.zip ${_DOWNLOAD_DIR}/%/link ${_DOWNLOAD_DIR}/%/ 

.PHONY: data/download-inrix-data data/remove-state-year-month-directory data/remove-state-year-month-zip-archive data/extract-inrix-data


# Define a macro that expands (splits on =) and
#   exports (makes available to sub-shells) key-value arguments,
#   e.g. DATABASE\_URL=postgres:///db.
define EXPAND_EXPORTS
export $(word 1, $(subst =, , $(1))) := $(word 2, $(subst =, , $(1)))
endef

# load postgres.env
#
# Read .env (squelching error messages if one doesn't exist) and pass each
# environment pair to EXPAND\_EXPORTS to make it available to commands in
# targets.
$(foreach a,$(shell cat ./config/postgres.env 2> /dev/null),$(eval $(call EXPAND_EXPORTS,$(a))))

# load data_paths.env
$(foreach a,$(shell cat ./config/data_paths.env 2> /dev/null),$(eval $(call EXPAND_EXPORTS,$(a))))

# Define make variable at rule execution time:
#		https://stackoverflow.com/q/1909188/3970755
# How to assign the output of a command to a Makefile variable:
# 	https://stackoverflow.com/a/2020006/3970755
define parse_STATE_YR_MO
 	@# Replace '/' with ' '
	$(eval STATE_YR_MO := $(subst /, ,$1))
	
	@# extract the state and convert to lower case: https://stackoverflow.com/a/10962047/3970755
	$(eval STATE := $(shell echo "$(word 1, ${STATE_YR_MO})" | tr '[:upper:]' '[:lower:]'))

	$(eval YEAR := $(word 2, ${STATE_YR_MO}))

	@# zero-pad months: see https://stackoverflow.com/a/9671373/3970755
	$(eval MONTH := $(shell printf '%02d' $(word 3, ${STATE_YR_MO})))

	$(eval SYM_INRIX_DOWNLOAD_DIR := "${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/")
endef

echo_conf:
	# This is the default target because these variables should be verified first and foremost.
	@a=$$(cat ./config/postgres.env); \
	echo "$${a}"


#####################################################


db/list_tables:
	psql -c '\d'

db/%/list_tables:
	@schema=$*; psql -c "\connect \"$${schema,,}\"" -c "\d";

db/clean_db: drop_database create_database

db/drop_database:
	@# Drop the database if it exists.
	@# https://stackoverflow.com/a/16783253/3970755
	@psql -lqt | cut -d \| -f 1 | grep -qw "${PGDATABASE}" && dropdb "${PGDATABASE}"

db/create_database:
	@# Create the database if it does not exist.
	@# https://stackoverflow.com/a/16783253/3970755
	@psql -lqt | cut -d \| -f 1 | grep -qw "${PGDATABASE}" || createdb "${PGDATABASE}"

db/%/clean_schema: db/%/drop_schema db/%/create_schema
	@true

db/%/drop_schema:
	@schema=$*; psql -c "DROP SCHEMA IF EXISTS \"$${schema,,}\";"

db/%/create_schema: db/create_database
	@schema=$*; psql -c "CREATE SCHEMA IF NOT EXISTS \"$${schema,,}\";"


#####################################################

#### External API

data/download-inrix-data: ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/data.zip

data/remove-state-year-month-directory: 
	rm -rf ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/

data/remove-state-year-month-zip-archive:
	rm -f ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/data.zip

#### Internal Use

# data/downloads/%/data.zip: data/downloads/%/link
${_DOWNLOAD_DIR}/%/link: ${_DOWNLOAD_DIR}/%/
	@if [ -z "${INRIX_DATA_URL}" ]; then\
		echo 'USAGE: make /${_DOWNLOAD_DIR}/%/link INRIX_DATA_URL=<url>';\
		exit 1;\
	fi

	$(call parse_STATE_YR_MO, $*)
	@echo "${INRIX_DATA_URL}" > "${SYM_INRIX_DOWNLOAD_DIR}/link"

${_DOWNLOAD_DIR}/%/data.zip: ${_DOWNLOAD_DIR}/%/link
	$(call parse_STATE_YR_MO, $*)

	@if [ ! -f ${SYM_INRIX_DOWNLOAD_DIR}/data.zip ]; then\
		curl "$(shell cat "${SYM_INRIX_DOWNLOAD_DIR}/link")" > \
			"${SYM_INRIX_DOWNLOAD_DIR}/data.zip";\
	fi

${_DOWNLOAD_DIR}/%/: ${_DOWNLOAD_DIR}/
	$(call parse_STATE_YR_MO, $*)
	
	mkdir -p "${SYM_INRIX_DOWNLOAD_DIR}"

${_DOWNLOAD_DIR}/: data/
	@echo '${_DOWNLOAD_DIR}: data/'
	@# Works with a symlink dir: https://stackoverflow.com/a/59839/3970755
	@if [ ! -d '${_DOWNLOAD_DIR}' ]; then\
		if [ -z ${INRIX_DOWNLOADS_DIR} ]; then\
			mkdir -p '${_DOWNLOAD_DIR}/';\
		else\
			ln -d ${INRIX_DOWNLOADS_DIR} '${_DOWNLOAD_DIR}/';\
		fi;\
	fi

data/:
	mkdir -p data/


#####################################################


data/extract-inrix-data: data/download-inrix-data
	@# If there are any unzipped CSVs in the dir, do not extract the archive.
	@ls ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/*.csv 1> /dev/null 2>&1 ||\
		@unzip ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/data.zip \
			-d ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/ ;\

${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/${STATE}_y${YEAR}m${MONTH}.inrix-schema.csv: data/extract-inrix-data

	@# Get the name of the file containing the NPMRDS data.
	@#   NOTE: Assumes the NPMRDS data file is the only one in the directory containing
	@#         the string 'measurement_tstamp'
	$(eval SYM_NPMRDS_CSV := $(shell grep -m 1 -rl 'measurement_tstamp' "${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/"))

	@if [ ! -f "$@" ]; then\
		mv "${SYM_NPMRDS_CSV}" $@ ;\
	fi



