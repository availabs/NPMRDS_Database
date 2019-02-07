# TODO: For tables with load scripts, add TRUNCATE make rules
#       so that dependant tables are not DROPPED in the CASCADE.
#
# Based on the following Makefile 
#   https://github.com/stamen/toner-carto/blob/master/Makefile
# And its explanatory blog post found here:
# http://mojodna.net/2015/01/07/make-for-data-using-make.html

# Use bash for sub-shells, allowing use of bash-specific functionality.
SHELL := /bin/bash

# Add npm-installed binaries to the PATH.
PATH := $(PATH):node_modules/.bin

.DEFAULT_GOAL := echo_conf
.SUFFIXES:

# Transform STATE to lowercase
STATE := $(shell echo ${STATE} | tr '[:upper:]' '[:lower:]')

# zero-pad months: see https://stackoverflow.com/a/9671373/3970755
MONTH:=$(shell if [ ${MONTH} ]; then printf '%02.f' "${MONTH}"; fi)

_MKFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

_BIN_DIR := ${_MKFILE_DIR}bin

_PREPROCESSING_DIR := ${_MKFILE_DIR}preprocessing
_NPMRDS_SHAPEFILE_PREPROCESSING_DIR := ${_PREPROCESSING_DIR}/shapefiles/npmrds_shapefile

_DATA_DIR := ${_MKFILE_DIR}data
_DOWNLOAD_DIR := ${_DATA_DIR}/npmrds-downloads

_FIPS_CODES_CSVS_DIR := ${_DATA_DIR}/csv/fip_codes/

_MPOS_DIRS_SHAPEFILE_DIR := ${_DATA_DIR}/shapefiles/mpo_boundaries/us

_URBAN_AREAS_SHAPEFILE_DIR := ${_DATA_DIR}/shapefiles/urban_area_boundaries/us

_URBAN_AREA_POPULATIONS_DIR := ${_DATA_DIR}/csv/urban_area_populations/us/${YEAR}
_URBAN_AREA_POPULATIONS_ZIP_PATH := ${_URBAN_AREA_POPULATIONS_DIR}/urban_area_populations.5-year-estimate.${YEAR}.us.gz

_COUNTY_POPULATIONS_DIR :=  ${_DATA_DIR}/csv/county_populations/us/${YEAR}
_COUNTY_POPULATIONS_ZIP_PATH := ${_COUNTY_POPULATIONS_DIR}/county_populations.5-year-estimate.${YEAR}.us.gz

_STATE_POPULATIONS_DIR :=  ${_DATA_DIR}/csv/state_populations/us/${YEAR}
_STATE_POPULATIONS_ZIP_PATH := ${_STATE_POPULATIONS_DIR}/state_populations.5-year-estimate.${YEAR}.us.gz

_NPMRDS_SHAPEFILES_DIR := ${_DATA_DIR}/shapefiles/npmrds_shapefile

_SCRAPED_SPEEDLIMITS_DIR := "${_MKFILE_DIR}/src/speedlimitScraper/data"
_PARSED_SPEEDLIMITS_DIR := "${_MKFILE_DIR}/src/speedlimitScraper/parsed-speedlimit-data"
_SPEEDLIMITS_DATA_DIR := "${_DATA_DIR}/csv/speedlimits"

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
	${_DOWNLOAD_DIR}/**/* \
	${_ETL_SORTED_DIR}/**/*

# Define a macro that expands (splits on =) and
#   exports (makes available to sub-shells) key-value arguments,
#   e.g. DATABASE\_URL=postgres:///db.
define EXPAND_EXPORTS
export $(word 1, $(subst =, , $(1))) := $(word 2, $(subst =, , $(1)))
endef

# Read .env (squelching error messages if one doesn't exist) and pass each
# environment pair to EXPAND\_EXPORTS to make it available to commands in
# targets.
$(foreach a,$(shell if [ "$${PG_ENV}" = "production" ]; then cat ./config/postgres.env.prod; else cat ./config/postgres.env.dev; fi | sed -e '/\s*#.*$$/d' -e '/^\s*$$/d' 2> /dev/null),$(eval $(call EXPAND_EXPORTS,$(a))))

# https://stackoverflow.com/a/10858332/3970755
# Check that given variables are set and all have non-empty values,
#   die with an error otherwise.
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
#
# CONSIDER: This code was breaking EXPORT_ALL_VARIABLES. Is this a better solution:
#   https://stackoverflow.com/questions/4728810/makefile-variable-as-prerequisite/4731504#4731504
check_defined = $(strip $(foreach 1,$1, $(call __check_defined,$1,$(strip $(value 2)))))

__check_defined = $(if $(value $1),, $(error Undefined $1$(if $2, ($2))$(if $(value @), \ required by target `$@')))

echo_conf:
	# This is the default target because these variables should be verified first and foremost.
	@echo "PGDATABASE=${PGDATABASE}"
	@echo "PGUSER=${PGUSER}"
	@echo "PGHOST=${PGHOST}"
	@echo "PGPORT=${PGPORT}"

#####################################################

verify-state-env-variable-defined:
	@:$(call check_defined,STATE)

db/list-tables:
	psql -c '\d'

db/%-list-tables:
	@schema=$*; psql -c "\connect \"$${schema,,}\"" -c "\d";

db/clean-db: drop-database create-database

db/create-database:
	@# Create the database if it does not exist.
	@# https://stackoverflow.com/a/16783253/3970755
	@psql -lqt | cut -d \| -f 1 | grep -qw "${PGDATABASE}" || createdb "${PGDATABASE}"

db/create-schema-:
	$(error Make sure to define the STATE or COUNTRY env variable.)

db/create-schema-%: db/create-database
	@if [ ! '$*' ]; then\
		echo "Schema not defined.";\
		exit 1;\
	else\
		schema=$*;\
		schema=$${schema,,};\
		if ! psql -t -c "\dn $${schema}" | sed '/^$/d' > /dev/null 2>&1; then\
			echo "=== $$schema ===";\
			psql -c "CREATE SCHEMA IF NOT EXISTS \"$${schema}\";";\
		fi;\
	fi

db/create-root-npmrds-table: db/create-database db/create-enum-types
	@if ! psql -c '\d public.npmrds' > /dev/null 2>&1; then\
		psql -f './sql/npmrds/root/createRootNPMRDSDataTable.sql';\
	fi

db/create-root-tmc-date-ranges-table: db/create-database
	@set -e;\
	if ! psql -c '\d public.tmc_date_ranges' > /dev/null 2>&1; then\
		psql -f './sql/tmc_date_ranges/createRootTMCDateRangeTable.sql';\
	fi

db/create-npmrds-state-table: db/create-root-npmrds-table db/create-schema-${STATE}
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@psql -c '\d "${STATE}".npmrds' > /dev/null 2>&1 || \
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/npmrds/state/createStateNPMRDSDataTable.sql)"

db/clean-npmrds-state-yrmo-table: db/drop-npmrds-state-yrmo-table db/create-npmrds-state-yrmo-table

db/drop-npmrds-state-yrmo-table:
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@if ! psql -c '\d "${STATE}".npmrds_y${YEAR}m${MONTH}' > /dev/null 2>&1; then\
		psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
				s/__YEAR__/${YEAR}/g;\
				s/__MONTH__/${MONTH}/g;\
			" ./sql/npmrds/state/dropStateNPMRDSYrMoTable.sql\
		)";\
	fi

db/create-npmrds-state-yrmo-table: db/create-npmrds-state-table
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@if ! psql -c '\d "${STATE}".npmrds_y${YEAR}m${MONTH}' > /dev/null 2>&1; then\
		START_DATE="$$(date -d "${YEAR}-${MONTH}-01" '+%F')";\
		END_DATE="$$(date -d "$${START_DATE} + 1 month" '+%F')";\
		psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
				s/__YEAR__/${YEAR}/g;\
				s/__MONTH__/${MONTH}/g;\
				s/__START_DATE__/$${START_DATE}/g;\
				s/__END_DATE__/$${END_DATE}/g;\
			" ./sql/npmrds/state/createStateNPMRDSYrMoTable.sql\
		)";\
	fi

db/upload-npmrds-state-yrmo: db/drop-npmrds-state-yrmo-table db/create-npmrds-state-yrmo-table
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@if [[ ! $$(psql -t -c 'SELECT * FROM "${STATE}".npmrds_y${YEAR}m${MONTH} LIMIT 1;' | tr -d " \t\n\r";) ]]; then\
		export PG_ENV;\
		export DATA_FILE_PATH="${_ETL_TRANSFORMED_DIR}/${STATE}/here-schema/${STATE}.${YEAR}${MONTH}.here-schema.sorted.csv.gz";\
		export STATE;\
		export YEAR;\
		export MONTH;\
		./make_targets/db/upload-npmrds-state-yrmo.sh;\
	fi


# TODO: make this a dependency: db/upload-npmrds-state-yrmo
db/postprocess-npmrds-state-yrmo:
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@if psql -c '\d "${STATE}".npmrds_y${YEAR}m${MONTH}' > /dev/null 2>&1; then\
		psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
				s/__YEAR__/${YEAR}/g;\
				s/__MONTH__/${MONTH}/g;\
			" ./sql/npmrds/state/coalesceTimes.sql\
		)";\
		psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
				s/__YEAR__/${YEAR}/g;\
				s/__MONTH__/${MONTH}/g;\
			" ./sql/npmrds/state/deleteEmptyRows.sql\
		)";\
		psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
				s/__YEAR__/${YEAR}/g;\
				s/__MONTH__/${MONTH}/g;\
			" ./sql/npmrds/state/clusterTable.sql\
		)";\
	fi

db/create-state-tmc-date-ranges-table: db/create-schema-${STATE} db/create-root-tmc-date-ranges-table
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@if ! psql -c '\d "${STATE}".tmc_date_ranges' > /dev/null 2>&1; then\
		psql -c "$$(\
				sed "\
					s/__STATE__/${STATE}/g;\
				" ./sql/tmc_date_ranges/createStateTMCDateRangeTable.sql\
			)";\
	fi

db/refresh-state-tmc-date-ranges-table: db/create-state-tmc-date-ranges-table
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
			" ./sql/tmc_date_ranges/refreshStateTMCDateRangeTable.sql;\
		)";


db/drop-mpo-acronyms-table:
	@if psql -c '\d us.mpo_acronyms' > /dev/null 2>&1; then\
		psql -f ./sql/mpo_acronyms/drop_mpo_acronyms.sql;\
	fi

db/create-mpo-acronyms-table: db/create-schema-us
	@if ! psql -c '\d us.mpo_acronyms' > /dev/null 2>&1; then\
		psql -f ./sql/mpo_acronyms/create_mpo_acronyms.sql;\
	fi

db/drop-mpo-to-ua-table:
	@if psql -c '\d public.mpo_to_ua' > /dev/null 2>&1; then\
		psql -f ./sql/mpo_to_ua/drop-mpo_to_ua-table.sql;\
	fi

db/create-mpo-to-ua-table: db/create-schema-us
	@if ! psql -c '\d public.mpo_to_ua' > /dev/null 2>&1; then\
		psql -f ./sql/mpo_to_ua/create-mpo_to_ua-table.sql;\
	fi

db/load-mpo-to-ua-table: db/create-mpo-to-ua-table
	@psql -f ./sql/mpo_to_ua/load-mpo_to_ua-table.sql;\

db/load-mpo-acronyms-table: db/create-mpo-acronyms-table
	@set -e;\
	COUNT=$$(psql -t -c "SELECT COUNT(1) FROM us.mpo_acronyms;" | tr -d " \t\n\r";);\
	if [ $${COUNT} -eq 0 ]; then\
		psql -f ./sql/mpo_acronyms/load_mpo_acronyms.sql;\
	fi


db/upload-mpo-boundaries-shapefile: db/load-mpo-acronyms-table
	@# TODO: compare version in DB to version in data dir.
	@#       If a newer version available, upload. Otherwise, skip.
	@set -e;\
	LATEST_VERSION=$$(ls ${_MPOS_DIRS_SHAPEFILE_DIR} | sort | tail -1);\
	SHP_DIR=${_MPOS_DIRS_SHAPEFILE_DIR}/$${LATEST_VERSION};\
	pushd $${SHP_DIR} && unzip -o "*.zip" && popd;\
	psql -c "$$(sed "s/__LATEST_VERSION__/$${LATEST_VERSION}/g" ./sql/mpo_boundaries/drop_mpo_boundaries_version_table.sql)";\
	ogr2ogr -t_srs EPSG:4326 -f \
		PostgreSQL 'PG:host=${PGHOST} port=${PGPORT} user=${PGUSER} dbname=${PGDATABASE} password=${PGPASSWORD}' \
		"$${SHP_DIR}" -lco SCHEMA=us -lco OVERWRITE=YES -nlt PROMOTE_TO_MULTI -lco PRECISION=NO -nln "mpo_boundaries_$${LATEST_VERSION}";\
	psql -c "$$(sed "s/__LATEST_VERSION__/$${LATEST_VERSION}/g" ./sql/mpo_boundaries/create_root_mpo_boundaries_table_from_version_table.sql)";\
	OLDER_VERSION="$$(psql -t -f ./sql/mpo_boundaries/list_mpo_boundaries_child_table.sql | tr -d " \t\n\r")";\
	if [[ ! -z $${OLDER_VERSION} ]]; then\
		psql -c "ALTER TABLE us.$${OLDER_VERSION} NO INHERIT public.mpo_boundaries;";\
	fi;\
	psql -c "ALTER TABLE us.mpo_boundaries_$${LATEST_VERSION} INHERIT public.mpo_boundaries;";\
	find $${SHP_DIR} \
		\( -iname '*.shx' -o -iname '*.CPG' -o -iname '*.dbf' -o -iname '*.prj' -o -iname '*.sbn' -o -iname '*.sbx' -o -iname '*.shp' -o -iname '*.shp.xml' \)\
		-type f -delete;


db/drop-mpo-boundaries-view:
	@if psql -c '\d public.mpo_boundaries' > /dev/null 2>&1; then\
		psql -f './sql/mpo_boundaries_view/dropMPOBoundariesView.sql';\
	fi

db/create-mpo-boundaries-view:
	@if ! psql -c '\d public.mpo_boundaries_view' > /dev/null 2>&1; then\
		psql -f ./sql/mpo_boundaries_view/createMPOBoundariesView.sql;\
	fi


#############################################
# Uploading the versioned NPMRDS shapefiles #
#############################################

db/create-root-npmrds-shapefile-table:
	@if ! psql -c '\d public.npmrds_shapefile' > /dev/null 2>&1; then\
		psql -f ./sql/npmrds_shapefile/root/createRootNPMRDSShapefileTable.sql;\
	fi

db/create-state-npmrds-shapefile-table: db/create-schema-${STATE} db/create-root-npmrds-shapefile-table
	@:$(call check_defined,STATE)
	@if ! psql -c '\d "${STATE}".npmrds_shapefile' > /dev/null 2>&1; then\
		psql -v STATE="$${STATE}" -f ./sql/npmrds_shapefile/state/createStateNPMRDSShapefileTable.sql;\
	fi

db/create-state-npmrds-shapefile-year-table: db/create-state-npmrds-shapefile-table
	@:$(call check_defined,STATE)
	@:$(call check_defined,YEAR)
	@if ! psql -c '\d "${STATE}".npmrds_shapefile_${YEAR}' > /dev/null 2>&1; then\
		psql -v STATE="$${STATE}" -v YEAR="$${YEAR}" -f ./sql/npmrds_shapefile/state/createStateNPMRDSShapefileYearTable.sql;\
	fi

db/upload-state-npmrds-shapefile-from-country-tar.sh: db/create-state-npmrds-shapefile-table
	@:$(call check_defined,TAR_ARCHIVE_PATH)
	@:$(call check_defined,STATE)
	@export TAR_ARCHIVE_PATH;\
	export STATE;\
	${_MKFILE_DIR}/make_targets/db/upload-state-npmrds-shapefile-from-country-tar.sh

db/drop-urban-area-boundaries-table:
	@if psql -c '\d public.urban_area_boundaries' > /dev/null 2>&1; then\
		psql -f ./sql/urban_area_boundaries/drop_root_urban_area_boundaries_table.sql;\
	fi

db/upload-urban-area-boundaries-shapefile: db/create-database db/create-schema-us
	@set -e;\
	LATEST_VERSION=$$(ls ${_URBAN_AREAS_SHAPEFILE_DIR} | sort | tail -1);\
	SHP_DIR=${_URBAN_AREAS_SHAPEFILE_DIR}/$${LATEST_VERSION};\
	pushd $${SHP_DIR} && unzip -o "*.zip" && popd;\
	psql -c "$$(sed "s/__LATEST_VERSION__/$${LATEST_VERSION}/g" ./sql/urban_area_boundaries/drop_urban_area_boundaries_version_table.sql)";\
	ogr2ogr -t_srs EPSG:4326 -f \
		PostgreSQL 'PG:host=${PGHOST} port=${PGPORT} user=${PGUSER} dbname=${PGDATABASE} password=${PGPASSWORD}' \
		"$${SHP_DIR}" -lco SCHEMA=us -lco OVERWRITE=YES -nlt PROMOTE_TO_MULTI -lco PRECISION=NO -nln "urban_area_boundaries_$${LATEST_VERSION}";\
	psql -c "$$(sed "s/__LATEST_VERSION__/$${LATEST_VERSION}/g" ./sql/urban_area_boundaries/create_root_urban_area_boundaries_table_from_version_table.sql)";\
	OLDER_VERSION="$$(psql -t -f ./sql/urban_area_boundaries/list_urban_area_boundaries_child_table.sql | tr -d " \t\n\r")";\
	if [[ ! -z $${OLDER_VERSION} ]]; then\
		psql -c "ALTER TABLE us.$${OLDER_VERSION} NO INHERIT public.urban_area_boundaries;";\
	fi;\
	psql -c "ALTER TABLE us.urban_area_boundaries_$${LATEST_VERSION} INHERIT public.urban_area_boundaries;";\
	find $${SHP_DIR} \
		\( -iname '*.shx' -o -iname '*.CPG' -o -iname '*.dbf' -o -iname '*.prj' -o -iname '*.sbn' -o -iname '*.sbx' -o -iname '*.shp' -o -iname '*.shp.xml' \)\
		-type f -delete;


db/drop-state-abbreviations-table:
	@if psql -c '\d public.state_abbreviations' > /dev/null 2>&1; then\
		psql -f 'sql/state_abbreviations/dropStateAbbreviationsTable.sql';\
	fi

db/create-state-abbreviations-table: db/create-database db/create-schema-us
	@if ! psql -c '\d public.state_abbreviations' > /dev/null 2>&1; then\
		psql -f 'sql/state_abbreviations/createStateAbbreviationsTable.sql';\
	fi


db/drop-enum-types:\
	db/drop-traffic-dist-functional-class-type \
	db/drop-geography-level-type \
	db/drop-functional-class-type \
	db/drop-traffic-dist-day-type \
	db/drop-traffic-dist-congestion-level-type \
	db/drop-traffic-dist-directionality-type

db/drop-traffic-dist-functional-class-type:
	@if [[ $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'traffic_dist_functional_class_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f 'sql/traffic_dist_functional_class_type/dropTrafficDistFunctionalClassType.sql';\
	fi

db/drop-geography-level-type:
	@if [[ $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'geography_level_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f 'sql/geography_level_type/dropGeographyLevelType.sql';\
	fi

db/drop-functional-class-type:
	@if [[ $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'functional_class_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f 'sql/functional_class_type/dropFunctionalClassType.sql';\
	fi

db/drop-traffic-dist-day-type:
	@if [[ $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'traffic_dist_day_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f 'sql/traffic_dist_day_type/dropTrafficDistDayType.sql';\
	fi

db/drop-traffic-dist-congestion-level-type:
	@if [[ $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'traffic_dist_congestion_level_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f 'sql/traffic_dist_congestion_level_type/dropTrafficDistCongestionLevelType.sql';\
	fi

db/drop-traffic-dist-directionality-type:
	@if [[ $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'traffic_dist_directionality_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f 'sql/traffic_dist_directionality_type/dropTrafficDistDirectionalityType.sql';\
	fi

db/create-traffic-dist-functional-class-type: db/create-database
	@if [[ ! $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'traffic_dist_functional_class_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f 'sql/traffic_dist_functional_class_type/createTrafficDistFunctionalClassType.sql';\
	fi

db/create-geography-level-type: db/create-database
	@if [[ ! $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'geography_level_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f 'sql/geography_level_type/createGeographyLevelType.sql';\
	fi

db/create-functional-class-type: db/create-database
	@if [[ ! $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'functional_class_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f 'sql/functional_class_type/createFunctionalClassType.sql';\
	fi

db/create-traffic-dist-day-type: db/create-database
	@if [[ ! $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'traffic_dist_day_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f 'sql/traffic_dist_day_type/createTrafficDistDayType.sql';\
	fi

db/create-traffic-dist-congestion-level-type: db/create-database
	@if [[ ! $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'traffic_dist_congestion_level_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f 'sql/traffic_dist_congestion_level_type/createTrafficDistCongestionLevelType.sql';\
	fi

db/create-traffic-dist-directionality-type: db/create-database
	@if [[ ! $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'traffic_dist_directionality_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f 'sql/traffic_dist_directionality_type/createTrafficDistDirectionalityType.sql';\
	fi

db/create-enum-types:\
	db/create-database \
	db/create-traffic-dist-functional-class-type \
	db/create-geography-level-type \
	db/create-functional-class-type \
	db/create-traffic-dist-day-type \
	db/create-traffic-dist-congestion-level-type \
	db/create-traffic-dist-directionality-type


db/create-root-tmc-metadata: \
	db/create-enum-types \
	db/create-state-abbreviations-table \
	db/create-root-npmrds-table \
	db/create-root-tmc-date-ranges-table \
	db/create-root-npmrds-shapefile-table \
	db/create-root-average-speedlimits-table \
	db/create-mpo-boundaries-view \
	db/create-root-fips-codes-table
	@if ! psql -c '\d "public".tmc_metadata' > /dev/null 2>&1; then\
		psql -f './sql/tmc_metadata/root/createRootTMCMetadataTable.sql';\
	fi

db/drop-state-tmc-metadata:
	@:$(call check_defined,STATE)
	@if psql -c '\d "${STATE}".tmc_metadata' > /dev/null 2>&1; then\
		psql -v STATE="$${STATE}" -f ./sql/tmc_metadata/state/dropStateTMCMetadataTable.sql;\
	fi

db/create-state-tmc-metadata: db/create-root-tmc-metadata
	@:$(call check_defined,STATE)
	@if ! psql -c '\d "${STATE}".tmc_metadata' > /dev/null 2>&1; then\
		psql -v STATE="$${STATE}" -f ./sql/tmc_metadata/state/createStateTMCMetadataTable.sql;\
	else\
		echo "${STATE}.tmc_metadata exists. Skipping db/create-state-tmc-metadata.";\
	fi

db/create-state-year-tmc-metadata: db/create-state-tmc-metadata
	@:$(call check_defined,STATE)
	@:$(call check_defined,YEAR)
	@if ! psql -c '\d "${STATE}".tmc_metadata_${YEAR}' > /dev/null 2>&1; then\
		psql -v STATE="$${STATE}" -v YEAR="$${YEAR}" -f ./sql/tmc_metadata/state/createStateYearTMCMetadataTable.sql;\
	else\
		echo "${STATE}.tmc_metadata_${YEAR} exists. Skipping db/create-state-tmc-metadata.";\
	fi

db/load-state-year-tmc-metadata: db/create-state-average-speedlimits-table db/create-state-year-tmc-metadata
	@:$(call check_defined,STATE)
	@:$(call check_defined,YEAR)
		@export PG_ENV;\
		export STATE;\
		export YEAR;\
		./make_targets/db/load-state-year-tmc-metadata.js


db/drop-tmc-level-pm3-all-tables-for-version-fn:
	@psql -f './sql/tmc_level_pm3_all_tables_for_version_fn/drop_tmc_level_pm3_all_tables_for_version_fn.sql'

db/create-tmc-level-pm3-all-tables-for-version-fn: db/create-npmrds-version-type
	@psql -f './sql/tmc_level_pm3_all_tables_for_version_fn/create_tmc_level_pm3_all_tables_for_version_fn.sql'


db/drop-geo-level-pm3-all-tables-for-version-fn:
	@psql -f './sql/geo_level_pm3_all_tables_for_version_fn/drop_geo_level_pm3_all_tables_for_version_fn.sql'

db/create-geo-level-pm3-all-tables-for-version-fn: db/create-npmrds-version-type
	@psql -f './sql/geo_level_pm3_all_tables_for_version_fn/create_geo_level_pm3_all_tables_for_version_fn.sql'


db/drop-tmc-level-pm3-all-active-leaf-tables-for-version-fn:
	@psql -f './sql/tmc_level_pm3_all_active_leaf_tables_for_version_fn/drop_tmc_level_pm3_all_active_leaf_tables_for_version_fn.sql'

db/create-tmc-level-pm3-all-active-leaf-tables-for-version-fn: db/create-npmrds-version-type
	@psql -f './sql/tmc_level_pm3_all_active_leaf_tables_for_version_fn/create_tmc_level_pm3_all_active_leaf_tables_for_version_fn.sql'


db/drop-geo-level-pm3-all-active-leaf-tables-for-version-fn:
	@psql -f './sql/geo_level_pm3_all_active_leaf_tables_for_version_fn/drop_geo_level_pm3_all_active_leaf_tables_for_version_fn.sql'

db/create-geo-level-pm3-all-active-leaf-tables-for-version-fn: db/create-npmrds-version-type
	@psql -f './sql/geo_level_pm3_all_active_leaf_tables_for_version_fn/create_geo_level_pm3_all_active_leaf_tables_for_version_fn.sql'


db/drop-tmcs-within-geography-fn:
	@psql -f './sql/tmcs_within_geography_fn/drop_tmcs_within_geography_fn.sql'

db/create-tmcs-within-geography-fn:
	@psql -f './sql/tmcs_within_geography_fn/create_tmcs_within_geography_fn.sql'


db/drop-npmrds-version-type:
	@if [[ $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'npmrds_version_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f './sql/npmrds_version_type/drop_npmrds_version_type.sql';\
	fi

db/create-npmrds-version-type:
	@if [[ ! $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'npmrds_version_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f './sql/npmrds_version_type/create_npmrds_version_type.sql';\
	fi

db/drop-traffic-distributions-table:
	@if psql -c '\d public.traffic_distributions' > /dev/null 2>&1; then\
		psql -f ./sql/traffic_distributions/dropTrafficDistributionsTable.sql;\
	fi

db/create-traffic-distributions-table:
	@if ! psql -c '\d public.traffic_distributions' > /dev/null 2>&1; then\
		psql -f ./sql/traffic_distributions/createTrafficDistributionsTable.sql;\
	fi

db/drop-geography-level-to-states:
	@if psql -c '\d public.geography_level_to_states' > /dev/null 2>&1; then\
		psql -f './sql/geography_level_to_states/drop_geography_level_to_states.sql';\
	fi

db/create-geography-level-to-states:
	@if ! psql -c '\d public.geography_level_to_states' > /dev/null 2>&1; then\
		psql -f './sql/geography_level_to_states/create_geography_level_to_states.sql';\
	fi


db/drop-geography-level-attributes-view:
	@if psql -c '\d public.geography_level_attributes_view' > /dev/null 2>&1; then\
		psql -f './sql/geography_level_attributes_view/dropStateGeographyLevelAttributesView.sql';\
	fi

db/create-geography-level-attributes-view: db/create-root-tmc-attributes
	@if ! psql -c '\d public.geography_level_attributes_view' > /dev/null 2>&1; then\
		psql -f './sql/geography_level_attributes_view/createStateGeographyAttributesView.sql';\
	fi

db/drop-geography-level-attributes-view-2:
	@if psql -c '\d public.geography_level_attributes_view_2' > /dev/null 2>&1; then\
		psql -f './sql/geography_level_attributes_view_2/dropStateGeographyLevelAttributesView2.sql';\
	fi

db/create-geography-level-attributes-view-2: db/create-root-tmc-attributes
	@if ! psql -c '\d public.geography_level_attributes_view_2' > /dev/null 2>&1; then\
		psql -f './sql/geography_level_attributes_view_2/createStateGeographyAttributesView2.sql';\
	fi


db/create-npmrds-year-fn:
	@psql -f './sql/npmrds_year_fn/create_npmrds_year_function.sql'

db/create-npmrds-month-fn:
	@psql -f './sql/npmrds_month_fn/create_npmrds_month_function.sql'
		
db/create-npmrds-date-fn:
	@psql -f './sql/npmrds_date_fn/create_npmrds_date_function.sql'

db/create-timestamptoepoch-fn:
	@psql -f './sql/timestamptoepoch_fn/create_timestamptoepoch_function.sql'

db/drop-root-average-speedlimits-table:
	@if psql -c '\d public.avg_speedlimits' > /dev/null 2>&1; then\
		psql -f './sql/avg_speedlimits/dropRootAverageSpeedLimitsTable.sql';\
	fi

db/create-root-average-speedlimits-table:
	@if ! psql -c '\d public.avg_speedlimits' > /dev/null 2>&1; then\
		psql -f './sql/avg_speedlimits/createRootAverageSpeedLimitsTable.sql';\
	fi

db/drop-state-average-speedlimits-table:
	@if psql -c '\d ${STATE}.avg_speedlimits' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/avg_speedlimits/dropStateAvgSpeedlimitsTable.sql)";\
	fi

db/create-state-average-speedlimits-table: db/create-state-abbreviations-table db/create-root-average-speedlimits-table db/create-schema-${STATE}
	@:$(call check_defined,STATE)
	@echo ${STATE}
	@if ! psql -c '\d ${STATE}.avg_speedlimits' > /dev/null 2>&1; then\
		psql -c "$$(sed 's/__STATE__/${STATE}/g' ./sql/avg_speedlimits/createStateAvgSpeedlimitsTable.sql)";\
	fi

db/load-state-average-speedlimits-table: db/create-state-average-speedlimits-table
	@:$(call check_defined,STATE)
	@echo ${STATE}
	@if psql -c '\d ${STATE}.avg_speedlimits' > /dev/null 2>&1; then\
		psql -c 'TRUNCATE ${STATE}.avg_speedlimits';\
		cat ${_SPEEDLIMITS_DATA_DIR}/${STATE}_avg_speedlimits.csv |\
			psql -c "$$(sed 's/__STATE__/${STATE}/g' ./sql/avg_speedlimits/loadStateSpeedlimits.sql)";\
		psql -c "$$(sed 's/__STATE__/${STATE}/g' ./sql/avg_speedlimits/finishStateAvgSpeedlimitsTable.sql)";\
	fi

db/drop-federal-holidays-table:
	@if psql -c '\d public.federal_holidays' > /dev/null 2>&1; then\
		psql -f './sql/federal_holidays/dropFederalHolidaysTable.sql';\
	fi

db/create-federal-holidays-table: db/create-database
	@if ! psql -c '\d public.federal_holidays' > /dev/null 2>&1; then\
		psql -f './sql/federal_holidays/createFederalHolidaysTable.sql';\
	fi



db/drop-root-county-populations-table:
	@if psql -c '\d public.county_populations' > /dev/null 2>&1; then\
		psql -f './sql/county_populations/drop_root_county_populations_table.sql';\
	fi

db/drop-year-county-populations-table:
	@:$(call check_defined,YEAR)
	@if psql -c '\d us.county_populations_y${YEAR}' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__YEAR__/${YEAR}/g" './sql/county_populations/drop_year_county_populations_table.sql')";\
	fi

db/create-root-county-populations-table: db/create-database
	@if ! psql -c '\d public.county_populations' > /dev/null 2>&1; then\
		psql -f './sql/county_populations/create_root_county_populations_table.sql';\
	fi

db/create-year-county-populations-table: db/create-root-county-populations-table
	@:$(call check_defined,YEAR)
	@if ! psql -c '\d us.county_populations_y${YEAR}' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__YEAR__/${YEAR}/g" './sql/county_populations/create_year_county_populations_table.sql')";\
	fi

db/load-year-county-populations-table: db/create-year-county-populations-table
	@:$(call check_defined,YEAR)
	@set -e;\
	COUNT=$$(psql -t -c "SELECT COUNT(1) FROM us.county_populations_y${YEAR};" | tr -d " \t\n\r";);\
	if [ $${COUNT} -eq 0 ]; then\
		gunzip -c '${_COUNTY_POPULATIONS_ZIP_PATH}' | \
		tail -n +2 | \
			psql -c "$$(sed "s/__YEAR__/${YEAR}/g" ./sql/county_populations/load_year_county_populations.sql)";\
		psql -c "$$(sed "s/__YEAR__/${YEAR}/g" ./sql/county_populations/finish_year_county_populations.sql)";\
	fi


db/drop-root-urban-area-populations-table:
	@if psql -c '\d public.urban_area_populations' > /dev/null 2>&1; then\
		psql -f './sql/urban_area_populations/drop_root_urban_area_populations_table.sql';\
	fi

db/drop-year-urban-area-populations-table:
	@:$(call check_defined,YEAR)
	@if psql -c '\d us.urban_area_populations_y${YEAR}' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__YEAR__/${YEAR}/g" './sql/urban_area_populations/drop_year_urban_area_populations_table.sql')";\
	fi

db/create-root-urban-area-populations-table: db/create-database
	@if ! psql -c '\d public.urban_area_populations' > /dev/null 2>&1; then\
		psql -f './sql/urban_area_populations/create_root_urban_area_populations_table.sql';\
	fi

db/create-year-urban-area-populations-table: db/create-root-urban-area-populations-table
	@:$(call check_defined,YEAR)
	@if ! psql -c '\d us.urban_area_populations_y${YEAR}' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__YEAR__/${YEAR}/g" './sql/urban_area_populations/create_year_urban_area_populations_table.sql')";\
	fi

db/load-year-urban-area-populations-table: db/create-year-urban-area-populations-table
	@:$(call check_defined,YEAR)
	@set -e;\
	COUNT=$$(psql -t -c "SELECT COUNT(1) FROM us.urban_area_populations_y${YEAR};" | tr -d " \t\n\r";);\
	if [ $${COUNT} -eq 0 ]; then\
		gunzip -c '${_URBAN_AREA_POPULATIONS_ZIP_PATH}' | \
			psql -c "$$(sed "s/__YEAR__/${YEAR}/g" ./sql/urban_area_populations/load_year_urban_area_populations.sql)";\
		psql -c "$$(sed "s/__YEAR__/${YEAR}/g" ./sql/urban_area_populations/finish_year_urban_area_populations.sql)";\
	fi


db/drop-root-state-populations-table:
	@if psql -c '\d public.state_populations' > /dev/null 2>&1; then\
		psql -f './sql/state_populations/drop_root_state_populations_table.sql';\
	fi

db/drop-year-state-populations-table:
	@:$(call check_defined,YEAR)
	@if psql -c '\d us.state_populations_y${YEAR}' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__YEAR__/${YEAR}/g" './sql/state_populations/drop_year_state_populations_table.sql')";\
	fi

db/create-root-state-populations-table: db/create-database
	@if ! psql -c '\d public.state_populations' > /dev/null 2>&1; then\
		psql -f './sql/state_populations/create_root_state_populations_table.sql';\
	fi

db/create-year-state-populations-table: db/create-root-state-populations-table
	@:$(call check_defined,YEAR)
	@if ! psql -c '\d us.state_populations_y${YEAR}' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__YEAR__/${YEAR}/g" './sql/state_populations/create_year_state_populations_table.sql')";\
	fi

db/load-year-state-populations-table: db/create-year-state-populations-table
	@:$(call check_defined,YEAR)
	@set -e;\
	COUNT=$$(psql -t -c "SELECT COUNT(1) FROM us.state_populations_y${YEAR};" | tr -d " \t\n\r";);\
	if [ $${COUNT} -eq 0 ]; then\
		gunzip -c '${_STATE_POPULATIONS_ZIP_PATH}' | \
		tail -n +2 | \
			psql -c "$$(sed "s/__YEAR__/${YEAR}/g" ./sql/state_populations/load_year_state_populations.sql)";\
		psql -c "$$(sed "s/__YEAR__/${YEAR}/g" ./sql/state_populations/finish_year_state_populations.sql)";\
	fi


db/drop-root-fips-codes-table:
	@if psql -c '\d public.fip_codes' > /dev/null 2>&1; then\
		psql -f './sql/fips_codes/dropRootFipsCodesTable.sql';\
	fi

db/create-root-fips-codes-table: db/create-database
	@if ! psql -c '\d public.fips_codes' > /dev/null 2>&1; then\
		psql -f './sql/fips_codes/createRootFipsCodesTable.sql';\
	fi

db/drop-country-fips-codes-table:
	@:$(call check_defined,COUNTRY)
	@if psql -c "\d \"${COUNTRY}\".fip_codes" > /dev/null 2>&1; then\
		psql -f './sql/fips_codes/dropCountryFipsCodesTable.sql';\
	fi

db/create-country-fips-codes-table: db/create-root-fips-codes-table  db/create-schema-${COUNTRY}
	@:$(call check_defined,COUNTRY)
	@if ! psql -c "\d \"${COUNTRY}\".fip_codes" > /dev/null 2>&1; then\
		psql -v COUNTRY="$${COUNTRY}" -f './sql/fips_codes/createCountryFipsCodesTable.sql';\
	fi

db/load-country-fips-codes-table: db/create-country-fips-codes-table
	@:$(call check_defined,COUNTRY)
	@set -e;\
	COUNT=$$(psql -t -c "SELECT COUNT(1) FROM \"${COUNTRY}\".fips_codes;" | tr -d " \t\n\r";);\
	if [ $${COUNT} -eq 0 ]; then\
		FIPS_CODES_CSV_PATH="${_FIPS_CODES_CSVS_DIR}${COUNTRY}/fips_codes.${COUNTRY}.csv.gz";\
		gunzip -c "$${FIPS_CODES_CSV_PATH}" | \
			iconv -f iso-8859-1 -t utf-8 - |\
			psql -c "$$(sed 's/__COUNTRY__/${COUNTRY}/g;' ./sql/fips_codes/loadCountryFipsCodesTable.sql)" ;\
		psql -v COUNTRY="${COUNTRY}" -f ./sql/fips_codes/finishCountryFipsCodesTable.sql;\
	fi

db/drop-state-codes-view:
	@if psql -c '\d public.state_codes' > /dev/null 2>&1; then\
		psql -f './sql/state_codes/drop_state_codes_view.sql';\
	fi

db/create-state-codes-view: db/create-root-fips-codes-table
	@if ! psql -c '\d public.state_codes' > /dev/null 2>&1; then\
		psql -f './sql/state_codes/create_state_codes_view.sql';\
	fi


#####################################################

${_SPEEDLIMITS_DATA_DIR}:
	mkdir -p ${_SPEEDLIMITS_DATA_DIR}

scraping/scrape-speedlimits:
	@:$(call check_defined,STATE)
	@if [ ! -d "${_SCRAPED_SPEEDLIMITS_DIR}/${STATE}" ]; then\
		echo 'Scraping speedlimits.';\
		node ./src/speedlimitScraper/speedlimitsScraper.js --state=${STATE};\
	fi
	
scraping/update-scraped-speedlimits-info:
	@:$(call check_defined,STATE)
	node ./src/speedlimitScraper/speedlimitsScraper.js --state=${STATE};\

scraping/download-urban-area-boundaries-shapefile:
	@:$(call check_defined,YEAR)
	${_BIN_DIR}/scrapeCensusShapefiles.js --geographyType=urban_area --year=${YEAR}
	
scraping/download-county-populations-csv-for-year:
	@:$(call check_defined,YEAR)
	${_BIN_DIR}/scrapeCensusPopulations.js --year=${YEAR} --geographyType=county

scraping/download-urban-area-populations-csv-for-year:
	@:$(call check_defined,YEAR)
	${_BIN_DIR}/scrapeCensusPopulations.js --year=${YEAR} --geographyType=urban_area

scraping/download-state-populations-csv-for-year:
	@:$(call check_defined,YEAR)
	${_BIN_DIR}/scrapeCensusPopulations.js --year=${YEAR} --geographyType=state

scraping/download-fips-codes-csv:
	${_BIN_DIR}/scrapeFipsCodesTable.sh


preprocessing/create-speedlimits-csv: scraping/scrape-speedlimits
	@:$(call check_defined,STATE)
	@if [ ! -f "${_PARSED_SPEEDLIMITS_DIR}/${STATE}_avg_speedlimits.csv" ]; then\
		node ./src/speedlimitScraper/createSpeedlimitsCSV.js --state=${STATE};\
	fi

data/move-speedlimits-csv-to-data-dir: ${_SPEEDLIMITS_DATA_DIR} preprocessing/create-speedlimits-csv
	@:$(call check_defined,STATE)
	@if [ ! -d "${_SPEEDLIMITS_DATA_DIR}/${STATE}_avg_speedlimits.csv" ]; then\
		mv "${_PARSED_SPEEDLIMITS_DIR}/${STATE}_avg_speedlimits.csv" "${_SPEEDLIMITS_DATA_DIR}/${STATE}_avg_speedlimits.csv";\
	fi
	
preprocessing:
	mkdir -p ${_PREPROCESSING_DIR}

etl/download-and-partition-npmrds-shapefile:
	@:$(call check_defined,COUNTRY)
	@:$(call check_defined,YEAR)
	@export COUNTRY;\
	export YEAR;\
	${_MKFILE_DIR}make_targets/etl/download-and-partition-npmrds-shapefile.sh


${_NPMRDS_SHAPEFILES_DIR}:
	@mkdir -p ${_NPMRDS_SHAPEFILES_DIR};

data/copy-state-npmrds-shapefile-from-preprocessing-to-data: ${_NPMRDS_SHAPEFILES_DIR}
	@:$(call check_defined,STATE)
	@cp ${_PREPROCESSING_DIR}/shapefiles/npmrds_shapefile/states/${STATE}_*.zip ${_NPMRDS_SHAPEFILES_DIR}

data/clean-shapefiles-dir:
	$(shell find ./data/shapefiles \( -iname '*.shx' -o -iname '*.CPG' -o -iname '*.dbf' -o -iname '*.prj' -o -iname '*.sbn' -o -iname '*.sbx' -o -iname '*.shp' -o -iname '*.shp.xml' \) -type f -delete)
	@true

mapbox/create-tileset-for-year:
	@:$(call check_defined,YEAR)
	@export YEAR;\
	${_MKFILE_DIR}/make_targets/mapbox/create-tileset-for-year.sh

