# Based on the following Makefile 
#   https://github.com/stamen/toner-carto/blob/master/Makefile
# And its explanatory blog post found here:
#   http://mojodna.net/2015/01/07/make-for-data-using-make.html

# Use bash for sub-shells, allowing use of bash-specific functionality.
SHELL := /bin/bash

# Add npm-installed binaries to the PATH.
PATH := $(PATH):node_modules/.bin

.DEFAULT_GOAL := echo_conf

_DATA_DIR := data
_DOWNLOAD_DIR := ${_DATA_DIR}/inrix-downloads

_ETL_DIR := etl
_ETL_SORTED_DIR := ${_ETL_DIR}/sorted
_ETL_TRANSFORMED_DIR := ${_ETL_DIR}/transformed

# Transform STATE to lowercase
STATE := $(shell echo ${STATE} | tr '[:upper:]' '[:lower:]')

# zero-pad months: see https://stackoverflow.com/a/9671373/3970755
MONTH:=$(shell if [ ${MONTH} ]; then printf '%02d' ${MONTH}; fi)

# https://www.gnu.org/software/make/manual/make.html#Special-Targets
# The targets which .SECONDARY depends on are treated as intermediate files,
# 	except that they are never automatically deleted. See Chains of Implicit Rules.
# 
# .SECONDARY with no prerequisites causes all targets to be treated as secondary
# 	(i.e., no target is removed because it is considered intermediate).
.SECONDARY:

# https://www.gnu.org/software/make/manual/html_node/Chained-Rules.html
# Intermediate files are remade using their rules just like all other files. But
# intermediate files are treated differently in two ways.
# 
# The first difference is what happens if the intermediate file does not exist.
# If an ordinary file b does not exist, and make considers a target that depends
# on b, it invariably creates b and then updates the target from b. But if b is
# an intermediate file, then make can leave well enough alone. It won’t bother
# updating b, or the ultimate target, unless some prerequisite of b is newer than
# that target or there is some other reason to update that target.
# 
# The second difference is that if make does create b in order to update
# something else, it deletes b later on after it is no longer needed. Therefore,
# an intermediate file which did not exist before make also does not exist after
# make. make reports the deletion to you by printing a ‘rm -f’ command showing
# which file it is deleting.
# 
# Ordinarily, a file cannot be intermediate if it is mentioned in the makefile as
# a target or prerequisite. However, you can explicitly mark a file as
# intermediate by listing it as a prerequisite of the special target
# .INTERMEDIATE. This takes effect even if the file is mentioned explicitly in
# some other way.
# 
# You can prevent automatic deletion of an intermediate file by marking it as a
# secondary file. To do this, list it as a prerequisite of the special target
# .SECONDARY. When a file is secondary, make will not create the file merely
# because it does not already exist, but make does not automatically delete the
# file. Marking a file as secondary also marks it as intermediate.
.INTERMEDIATE: \
	data/inrix-downloads/ny/2016/02/link \
	etl/sorted/ny_y2016m02.inrix-schema.sorted.csv \
	${_DOWNLOAD_DIR}/**/* \
	${_ETL_SORTED_DIR}/**/*

#${_ETL_TRANSFORMED_DIR}/${STATE}/${YEAR}/${STATE}_y${YEAR}m${MONTH}.transformed.csv

.PHONY: \
	echo_conf \
	db/list-tables \
	db/%-list-tables \
	db/clean-db \
	db/drop-database \
	db/create-database \
	db/clean-schema-% \
	db/drop-schema-% \
	db/create-schema-% \
	db/drop-root-npmrds-table \
	db/create-root-npmrds-table \
	db/drop-npmrds-state-table \
	db/create-npmrds-state-table \
	db/drop-npmrds-state-yrmo-table \
	db/create-npmrds-state-yrmo-table \
	db/upload-npmrds-state-yrmo \
	data/download-inrix-data \
	data/remove-state-yrmo-directory \
	data/remove-state-yrmo-zip-archive \
	data/extract-inrix-data \
	etl/sort-inrix-schema-datafile \
	etl/transform-inrix-schema


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

# 	$(eval SYM_INRIX_DOWNLOAD_DIR := "${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/")

# https://stackoverflow.com/a/10858332/3970755
# Check that given variables are set and all have non-empty values,
#   die with an error otherwise.
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
			$(error ERROR: Undefined $1$(if $2, ($2))))

echo_conf:
	# This is the default target because these variables should be verified first and foremost.
	@cat ./config/postgres.env

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
	@if ! psql -c '\d public.npmrds' > /dev/null 2>&1; then\
		psql -f './sql/NPMRDS_Tables/root/dropRootNPMRDSDataTable.sql';\
	fi

db/create-root-npmrds-table: db/create-database
	@if ! psql -c '\d public.npmrds' > /dev/null 2>&1; then\
		@psql -f './sql/NPMRDS_Tables/root/createRootNPMRDSDataTable.sql';\
	fi

db/drop-npmrds-state-table:
	@:$(call check_defined, STATE)
	@psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/NPMRDS_Tables/state/dropStateNPMRDSDataTable.sql)"

db/create-npmrds-state-table: db/create-root-npmrds-table db/create-schema-${STATE}
	@:$(call check_defined, STATE) #redundant, since source target calls the same.
	@psql -c '\d "${STATE}".npmrds' > /dev/null 2>&1 || \
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/NPMRDS_Tables/state/createStateNPMRDSDataTable.sql)"

db/clean-npmrds-state-yrmo-table: db/drop-npmrds-state-yrmo-table db/create-npmrds-state-yrmo-table

db/drop-npmrds-state-yrmo-table:
	@:$(call check_defined, STATE) #redundant, since source target calls the same.
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
			" ./sql/NPMRDS_Tables/state/dropStateNPMRDSYrMoTable.sql\
		)";\
	fi

db/create-npmrds-state-yrmo-table: db/create-npmrds-state-table
	@:$(call check_defined, STATE) #redundant, since source target calls the same.
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

db/upload-npmrds-state-yrmo: \
	${_ETL_TRANSFORMED_DIR}/${STATE}/${YEAR}/${STATE}_y${YEAR}m${MONTH}.transformed.csv \
	db/drop-npmrds-state-yrmo-table \
	db/create-npmrds-state-yrmo-table

	./bin/projectNPMRDSTableColumns.sh < $<	| psql -c 'COPY "${STATE}".npmrds_y${YEAR}m${MONTH} (tmc,date,epoch,travel_time_all_vehicles,travel_time_passenger_vehicles,travel_time_freight_trucks) FROM STDIN CSV HEADER;'

#####################################################

#### External API

data/download-inrix-data: ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/data.zip

data/remove-state-yrmo-downloads-directory: 
	rm -rf ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/


# Removes any regular files not named data.zip or link
data/clean-downloads-directory:
	@find data/inrix-downloads/\
		! \( -name 'data.zip' -o -name 'link' \) \
		-type f -delete


data/clean-state-yrmo-downloads-directory:
	@find data/inrix-downloads/${STATE}/${YEAR}/${MONTH}\
		! \( -name 'data.zip' -o -name 'link' \) \
		-type f -delete

data/remove-state-yrmo-zip-archive:
	rm -f ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/data.zip

data/extract-inrix-data: \
	${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/${STATE}_y${YEAR}m${MONTH}.inrix-schema.csv

#### Internal Use

${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/link: ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}
	@if [ ! -f $@ ]; then\
		if [ -z "${DATA_URL}" ]; then\
			echo 'ERROR: DATA_URL environment variable is required';\
			exit 1;\
		fi;\
		echo "${DATA_URL}" > "${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/link";\
	fi

${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/data.zip: ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/link
	@if [ ! -f ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/data.zip ]; then\
		curl "$(shell cat "${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/link")" > \
			"${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/data.zip";\
	fi

${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}: ${_DOWNLOAD_DIR}
	mkdir -p "${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}"

${_DOWNLOAD_DIR}:
	mkdir -p $@

${_DATA_DIR}:
	mkdir -p $@

${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/${STATE}_y${YEAR}m${MONTH}.inrix-schema.csv: \
	${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/data.zip

	unzip -o ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/data.zip \
		-d ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/ 1> /dev/null 2>&1;

	@# Get the name of the file containing the NPMRDS data.
	@#   NOTE: Assumes the NPMRDS data file is the only one in the directory containing
	@#         the string 'measurement_tstamp'
	SYM_NPMRDS_CSV=$$(grep -m 1 -rl 'measurement_tstamp' "${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/");\
	mv $${SYM_NPMRDS_CSV} $@;
	touch $@

#####################################################

etl/sort-inrix-schema-datafile: ${_ETL_SORTED_DIR}/${STATE}_y${YEAR}m${MONTH}.inrix-schema.sorted.csv

${_ETL_SORTED_DIR}/${STATE}_y${YEAR}m${MONTH}.inrix-schema.sorted.csv: \
	${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/${STATE}_y${YEAR}m${MONTH}.inrix-schema.csv \
	${_ETL_SORTED_DIR}

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

${_ETL_SORTED_DIR}:
	@mkdir -p ${_ETL_SORTED_DIR}/

etl/transform-inrix-schema: \
	${_ETL_TRANSFORMED_DIR}/${STATE}/${YEAR}/${STATE}_y${YEAR}m${MONTH}.transformed.csv

${_ETL_TRANSFORMED_DIR}/${STATE}/${YEAR}/${STATE}_y${YEAR}m${MONTH}.transformed.csv: \
	${_ETL_SORTED_DIR}/${STATE}_y${YEAR}m${MONTH}.inrix-schema.sorted.csv \
	${_ETL_TRANSFORMED_DIR}/${STATE}/${YEAR}

	@if [ ! -f $@ ]; then\
		inf="$<";\
		outf="$@";\
		node ./bin/schemaTransformer.js < $$inf > $$outf;\
	fi
	
${_ETL_TRANSFORMED_DIR}/${STATE}/${YEAR}:
	@mkdir -p ${_ETL_TRANSFORMED_DIR}/${STATE}/${YEAR}

${_ETL_TRANSFORMED_DIR}:
	@mkdir -p ${_ETL_TRANSFORMED_DIR}

