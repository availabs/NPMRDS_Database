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
.PRECIOUS: \
	${_DOWNLOAD_DIR}/%/data.zip \
	${_DOWNLOAD_DIR}/%/link \
	${_DOWNLOAD_DIR}/%/ 

.PHONY: \
	data/download-inrix-data \
	data/remove-state-year-month-directory \
	data/remove-state-year-month-zip-archive \
	data/extract-inrix-data \
	etl-sort-inrix-schema-datafile


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

# https://stackoverflow.com/a/10858332/3970755
# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))


echo_conf:
	# This is the default target because these variables should be verified first and foremost.
	@a=$$(cat ./config/postgres.env); \
	echo "$${a}"


#####################################################

db/list-tables:
	psql -c '\d'

db/%-list-tables:
	@schema=$*; psql -c "\connect \"$${schema,,}\"" -c "\d";

db/clean-db: drop-database create-database

db/drop-database:
	@# Drop the database if it exists.
	@# https://stackoverflow.com/a/16783253/3970755
	@psql -lqt | cut -d \| -f 1 | grep -qw "${PGDATABASE}" && dropdb "${PGDATABASE}"

db/create-database:
	@# Create the database if it does not exist.
	@# https://stackoverflow.com/a/16783253/3970755
	@psql -lqt | cut -d \| -f 1 | grep -qw "${PGDATABASE}" || createdb "${PGDATABASE}"

db/clean-schema-%: db/drop-schema-% db/create-schema-%
	@true

db/drop-schema-%:
	@schema=$*; psql -c "DROP SCHEMA IF EXISTS \"$${schema,,}\" CASCADE;"

db/create-schema-%: db/create-database
	@if [ -z $* ]; then\
		echo "Schema not defined.";\
		exit 1;\
	else\
		schema=$*;\
		schema=$${schema,,};\
		if [[ ! $$(psql -t -c "\dn $${schema}") ]]; then\
			psql -c "CREATE SCHEMA IF NOT EXISTS \"$${schema}\";";\
		fi;\
	fi

db/drop-root-npmrds-table:
	psql -f './sql/NPMRDS_Tables/root/dropRootNPMRDSDataTable.sql'

db/create-root-npmrds-table: db/create-database
	@if ! psql -c '\d public.npmrds' > /dev/null 2>&1; then\
		@psql -f './sql/NPMRDS_Tables/root/createRootNPMRDSDataTable.sql';\
	fi


db/drop-state-npmrds-table:
	@:$(call check_defined, STATE)
	@psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/NPMRDS_Tables/state/dropStateNPMRDSDataTable.sql)"


db/create-state-npmrds-table: db/create-root-npmrds-table db/create-schema-${STATE}
	@:$(call check_defined, STATE) #redundant
	@psql -c '\d "${STATE}".npmrds' > /dev/null 2>&1 || \
		@psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/NPMRDS_Tables/state/createStateNPMRDSDataTable.sql)"

db/create-state-npmrds-yrmo-table: db/create-state-npmrds-table
	@:$(call check_defined, STATE)
	@:$(call check_defined, YEAR)
	@:$(call check_defined, MONTH)
	@if ! psql -c '\d "${STATE}".npmrds_y${YEAR}m${MONTH}' > /dev/null 2>&1; then\
		START_DATE="$$(date -d "${YEAR}-${MONTH}-01" '+%F')";\
		END_DATE="$$(date -d "${START_DATE} + 1 month" '+%F')";\
		psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
				s/__YEAR__/${YEAR}/g;\
				s/__MONTH__/${MONTH}/g;\
				s/__START_DATE__/$${START_DATE}/g;\
				s/__END_DATE__/$${END_DATE}/g;\
			" ./sql/NPMRDS_Tables/state/createStateNPMRDSYrMoTable.sql\
		)";\
	fi

db/upload-state-npmrds-yrmo-csv: \
	etl/transformed/${STATE}/${YEAR}/${STATE}_y${YEAR}m${MONTH}.transformed.csv \
	db/create-state-npmrds-yrmo-table
	./bin/projectNPMRDSTableColumns.sh < $<	| psql -c 'COPY "${STATE}".npmrds_y${YEAR}m${MONTH} (tmc, date, epoch, travel_time_all_vehicles, travel_time_passenger_vehicles, travel_time_freight_trucks) FROM 'STDIN' CSV HEADER;'


#####################################################

#### External API

data/download-inrix-data: ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/data.zip

data/remove-state-year-month-directory: 
	rm -rf ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/

data/clean-state-year-month-directory:
	@find data/inrix-downloads/${STATE}/${YEAR}/${MONTH}\
		! \( -name 'data.zip' -o -name 'link' \) \
		-type f -delete

data/remove-state-year-month-zip-archive:
	rm -f ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/data.zip

#### Internal Use

${_DOWNLOAD_DIR}/%/link: ${_DOWNLOAD_DIR}/%/
	$(call parse_STATE_YR_MO, $*)

	@if [ ! -f $@ ]; then\
		if [ -z "${INRIX_DATA_URL}" ]; then\
			echo 'USAGE: make /${_DOWNLOAD_DIR}/%/link INRIX_DATA_URL=<url>';\
			exit 1;\
		fi;\
		echo "${INRIX_DATA_URL}" > "${SYM_INRIX_DOWNLOAD_DIR}/link";\
	fi

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
			ln -s ${INRIX_DOWNLOADS_DIR} '${_DOWNLOAD_DIR}/';\
		fi;\
	fi

data/:
	mkdir -p data/


data/extract-inrix-data: data/download-inrix-data
	@# If there are any unzipped CSVs in the dir, do not extract the archive.
	@ls ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/*.csv 1> /dev/null 2>&1 ||\
		unzip ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/data.zip \
			-d ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/ 1> /dev/null 2>&1;\

${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/${STATE}_y${YEAR}m${MONTH}.inrix-schema.csv: \
	data/extract-inrix-data

	@# Get the name of the file containing the NPMRDS data.
	@#   NOTE: Assumes the NPMRDS data file is the only one in the directory containing
	@#         the string 'measurement_tstamp'
	$(eval SYM_NPMRDS_CSV := $(shell grep -m 1 -rl 'measurement_tstamp' "${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/"))

	@if [ ! -f "$@" ]; then\
		mv "${SYM_NPMRDS_CSV}" $@ ;\
	fi

#####################################################

etl-sort-inrix-schema-datafile: etl/sorted/${STATE}_y${YEAR}m${MONTH}.inrix-schema.sorted.csv

etl/sorted/${STATE}_y${YEAR}m${MONTH}.inrix-schema.sorted.csv: \
	${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/${STATE}_y${YEAR}m${MONTH}.inrix-schema.csv \
	etl/sorted/

	@# Because the number of columns and their order is not guaranteed,
	@#   we need to verify the order the columns used to sort the rows,
	@#   and then keep the header for later use.
	@# NOTE: For sorting special charactersi (-/+), see https://superuser.com/a/226489 
	@if [ ! -f $@ ]; then\
		inf="${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/${STATE}_y${YEAR}m${MONTH}.inrix-schema.csv";\
		outf="$@";\
		ReqColOrder='datasource,tmc_code,measurement_tstamp';\
		First3Cols="$$(awk -F, -v OFS=',' '{print $$1,$$2,$$3; exit}' $$inf)";\
		if [[ $$First3Cols !=  $$ReqColOrder ]]; then\
			echo "The column order of $$inf does not match the required order:";\
			echo "     Given: $$First3Cols";\
			echo "     Required: $$ReqColOrder";\
			exit 1;\
		fi;\
		head -1 $$inf > $$outf;\
		tail -n +2 $$inf | LC_ALL=C sort -k3,3 -k2,2 -k1,1 -t',' - >> $$outf ;\
	fi

etl/sorted/:
	@mkdir -p etl/sorted/

etl-transform-inrix-schema: etl/transformed/${STATE}/${YEAR}/${STATE}_y${YEAR}m${MONTH}.transformed.csv

etl/transformed/${STATE}/${YEAR}/${STATE}_y${YEAR}m${MONTH}.transformed.csv: \
	etl/sorted/${STATE}_y${YEAR}m${MONTH}.inrix-schema.sorted.csv \
	etl/transformed/${STATE}/${YEAR}

	@if [ ! -f $@ ]; then\
		inf="$<";\
		outf="$@";\
		node ./bin/schemaTransformer.js < $$inf > $$outf;\
	fi
	
etl/transformed/${STATE}/${YEAR}:
	@mkdir -p etl/transformed/${STATE}/${YEAR}

etl/transformed/:
	@mkdir -p etl/transformed/

