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

_FIPS_CODES_CSVS_DIR := ${_DATA_DIR}/csv/fip_codes/

_NPMRDS_SHAPEFILES_DIR := ${_DATA_DIR}/shapefiles/npmrds_shapefile

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

db/create-postgis-extension:
	psql -c 'CREATE EXTENSION IF NOT EXISTS postgis;'

db/create-enum-types:\
	db/create-database \
	db/create-traffic-dist-functional-class-type \
	db/create-geography-level-type \
	db/create-functional-class-type \
	db/create-traffic-dist-day-type \
	db/create-traffic-dist-congestion-level-type \
	db/create-traffic-dist-directionality-type

db/initialize-root-tables: \
	db/create-postgis-extension \
	db/create-enum-types \
	db/create-state-abbreviations-table \
	db/create-mpo-acronyms-table \
	db/create-root-fips-codes-table \
	db/create-root-avg-speedlimits-table \
	db/create-root-npmrds-table \
	db/create-root-tmc-date-ranges-table \
	db/create-root-mpo-boundaries-table \

db/initialize-root-year-tables: \
	db/create-root-year-npmrds-shapefile-table \
	db/create-root-year-tmc-metadata

db/initialize-minimal-database:
	@:$(call check_defined,YEARS)
	${_MKFILE_DIR}/make_targets/db/initialize-minimal-database

db/create-schema-%: db/create-database
	@if [ ! '$*' ]; then\
		echo "Schema not defined.";\
		exit 1;\
	else\
		schema=$*;\
		schema=$${schema,,};\
		if ! psql -t -c "\dn $$schema" | sed '/^$/d' > /dev/null 2>&1; then\
			psql --quiet -c "CREATE SCHEMA IF NOT EXISTS \"$${schema}\";";\
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

db/upload-npmrds-state-yrmo: db/create-npmrds-state-yrmo-table
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@:$(call check_defined,DATA_FILE_PATH)
	@if [[ ! $$(psql -t -c 'SELECT * FROM "${STATE}".npmrds_y${YEAR}m${MONTH} LIMIT 1;' | tr -d " \t\n\r";) ]]; then\
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
		psql -v STATE="$${STATE}" -f ./sql/tmc_date_ranges/createStateTMCDateRangeTable.sql;\
	fi

db/refresh-state-tmc-date-ranges-table: db/create-state-tmc-date-ranges-table
	@:$(call check_defined,STATE)
	@psql --quiet -v STATE="$${STATE}" -f ./sql/tmc_date_ranges/refreshStateTMCDateRangeTable.sql;

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

db/create-root-mpo-boundaries-table:
	@if ! psql -c '\d public.mpo_boundaries' > /dev/null 2>&1; then\
		psql -f ./sql/mpo_boundaries/create_root_mpo_boundaries_table.sql;\
	fi

db/upload-mpo-boundaries-shapefile:
	@:$(call check_defined,MPO_SHAPEFILE_ZIP_PATH)
	${_MKFILE_DIR}/make_targets/db/upload-mpo-boundaries-shapefile

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

# NOTE: Here for convenience.
#       make_targets/db/upload-state-npmrds-shapefile-from-country-tar.sh takes care of this internally.
db/create-root-year-npmrds-shapefile-table:
	@:$(call check_defined,YEAR)
	@if ! psql -c '\d public.npmrds_shapefile_${YEAR}' > /dev/null 2>&1; then\
		psql -v YEAR="$${YEAR}" -f ./sql/npmrds_shapefile/root/createRootYearNPMRDSShapefileTable.sql;\
	fi

# NOTE: Here for convenience.
#       make_targets/db/upload-state-npmrds-shapefile-from-country-tar.sh takes care of this internally.
db/create-state-npmrds-shapefile-year-table: db/create-schema-${STATE} db/create-root-year-npmrds-shapefile-table
	@:$(call check_defined,STATE)
	@:$(call check_defined,YEAR)
	@if ! psql -c '\d "${STATE}".npmrds_shapefile_${YEAR}' > /dev/null 2>&1; then\
		psql -v STATE="$${STATE}" -v YEAR="$${YEAR}" -f ./sql/npmrds_shapefile/state/createStateNPMRDSShapefileYearTable.sql;\
	fi

# NOTE: make_targets/db/upload-state-npmrds-shapefile-from-country-tar.sh
# 			takes care of creating the ancestor tables in the inheritance hierarchy.
db/upload-state-npmrds-shapefile-from-country-tar: db/create-schema-${STATE}
	@:$(call check_defined,TAR_ARCHIVE_PATH)
	@:$(call check_defined,STATE)
	@export TAR_ARCHIVE_PATH;\
	export STATE;\
	${_MKFILE_DIR}/make_targets/db/upload-state-npmrds-shapefile-from-country-tar.sh

db/create-placeholder-npmrds-shapefile-view:
	@:$(call check_defined,YEAR)
	psql --quiet -v YEAR="$${YEAR}" -v SHP_YEAR="$$((YEAR - 1))" \
		-f ./sql/placeholder_npmrds_shapefile_view/create_placeholder_npmrds_shapefile.sql


####################################################
# Uploading the versioned tmc_identification files #
####################################################

# NOTE: make_targets/db/upload-state-year-tmc-identification-from-etl-tar
# 			takes care of creating the ancestor tables in the inheritance hierarchy.
db/upload-state-year-tmc-identification-from-etl-tar:
	@:$(call check_defined,TAR_ARCHIVE_PATH)
	@${_MKFILE_DIR}/make_targets/db/upload-state-year-tmc-identification-from-etl-tar "$$TAR_ARCHIVE_PATH"


db/upload-urban-area-boundaries-shapefile:
	@:$(call check_defined,UA_SHAPEFILE_ZIP_PATH)
	${_MKFILE_DIR}/make_targets/db/upload-urban-area-boundaries-shapefile

db/create_transcom_events_table:
	@PGOPTIONS='--client-min-messages=warning' psql --quiet -f ./sql/transcom_events/create_transcom_events_table.sql

etl/transcom_events: db/create_transcom_events_table
	@:$(call check_defined,START_DATE)
	@:$(call check_defined,END_DATE)
	@export START_DATE;\
	export END_DATE;\
	export PG_ENV;\
	./src/transcomDataETL/main

db/drop-state-abbreviations-table:
	@if psql -c '\d public.state_abbreviations' > /dev/null 2>&1; then\
		psql -f 'sql/state_abbreviations/dropStateAbbreviationsTable.sql';\
	fi

db/create-state-abbreviations-table: db/create-database db/create-schema-us db/create-schema-cn
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

db/create-avail-table-metadata-table:
	@if ! psql -c '\d public.avail_table_metadata' > /dev/null 2>&1; then\
		psql -f ./sql/avail_table_metadata/create_avail_table_metadata.sql;\
	else\
		echo "public.avail_table_metadata exists. Skipping db/create-avail-table-metadata-table.";\
	fi

db/create-relation-dependencies-fn:
	@psql -f './sql/relation_dependencies_fn/create_relation_dependencies_fn.sql';

db/create-root-year-tmc-metadata: \
	db/create-enum-types \
	db/create-state-abbreviations-table \
	db/create-root-npmrds-table \
	db/create-root-tmc-date-ranges-table \
	db/create-root-year-npmrds-shapefile-table \
	db/create-root-avg-speedlimits-table \
	db/create-mpo-boundaries-view \
	db/create-root-fips-codes-table
	@:$(call check_defined,YEAR)
	@if ! psql -c '\d public.tmc_metadata_${YEAR}' > /dev/null 2>&1; then\
		psql --quiet -v YEAR="$${YEAR}" -f ./sql/tmc_metadata/root/createRootYearTMCMetadataTable.sql;\
	fi

db/create-state-year-tmc-metadata: db/create-root-year-tmc-metadata
	@:$(call check_defined,STATE)
	@:$(call check_defined,YEAR)
	@if ! psql -c '\d "${STATE}".tmc_metadata_${YEAR}' > /dev/null 2>&1; then\
		psql --quiet -v STATE="$${STATE}" -v YEAR="$${YEAR}" -f ./sql/tmc_metadata/state/createStateYearTMCMetadataTable.sql;\
	fi

db/load-state-year-tmc-metadata: \
	db/create-npmrds-state-table \
	db/create-root-fips-codes-table \
	db/create-state-avg-speedlimits-table \
	db/create-state-year-tmc-metadata \
	db/create-avail-table-metadata-table \
	db/create-relation-dependencies-fn
	@:$(call check_defined,STATE)
	@:$(call check_defined,YEAR)
		@export PG_ENV;\
		export STATE;\
		export YEAR;\
		./make_targets/db/load-state-year-tmc-metadata.js

db/create-placeholder-tmc-metadata-view:
	@:$(call check_defined,YEAR)
	@psql --quiet -v YEAR="$${YEAR}" -v METADATA_YEAR="$$((YEAR - 1))" \
		-f ./sql/placeholder_tmc_metadata_view/create_placeholder_tmc_metadata.sql


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

db/create-geography-metadata-view: db/create-root-year-tmc-metadata
	@:$(call check_defined,YEAR)
	@psql --quiet -v YEAR="$${YEAR}" -f ./sql/geography_metadata/create_geography_metadata_view.sql


db/create-npmrds-year-fn:
	@psql -f './sql/npmrds_year_fn/create_npmrds_year_function.sql'

db/create-npmrds-month-fn:
	@psql -f './sql/npmrds_month_fn/create_npmrds_month_function.sql'
		
db/create-npmrds-date-fn:
	@psql -f './sql/npmrds_date_fn/create_npmrds_date_function.sql'

db/create-timestamptoepoch-fn:
	@psql -f './sql/timestamptoepoch_fn/create_timestamptoepoch_function.sql'

db/create-root-avg-speedlimits-table: 
	@if ! psql -c '\d public.avg_speedlimits' > /dev/null 2>&1; then\
		psql --quiet -f ./sql/avg_speedlimits/create_root_avg_speedlimits_table.sql; \
	fi

db/create-state-avg-speedlimits-table: db/create-root-avg-speedlimits-table
	@:$(call check_defined,STATE)
	@if ! psql -c '\d "${STATE}".avg_speedlimits' > /dev/null 2>&1; then\
		psql --quiet -v STATE="$${STATE}" -f ./sql/avg_speedlimits/create_state_avg_speedlimits.sql; \
	fi

db/drop-federal-holidays-table:
	@if psql -c '\d public.federal_holidays' > /dev/null 2>&1; then\
		psql -f './sql/federal_holidays/dropFederalHolidaysTable.sql';\
	fi

db/create-federal-holidays-table: db/create-database
	@if ! psql -c '\d public.federal_holidays' > /dev/null 2>&1; then\
		psql -f './sql/federal_holidays/createFederalHolidaysTable.sql';\
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

db/archive-npmrds-state-yrmo:
	@:$(call check_defined,STATE)
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@:$(call check_defined,ARCHIVE_DIRECTORY_PATH)
	./make_targets/db/archive-npmrds-state-yrmo.sh;



#####################################################

db/create_pm3_calculator_metadata_table:
	@if ! psql -c '\d public.pm3_calculator_metadata' > /dev/null 2>&1; then\
		psql -f './sql/pm3_calculator_metadata/create_pm3_calculator_metadata_table.sql';\
	fi

db/create_pm3_measure_calculator_metadata_table: db/create_pm3_calculator_metadata_table
	@if ! psql -c '\d public.pm3_measure_calculator_metadata' > /dev/null 2>&1; then\
		psql -f './sql/pm3_measure_calculator_metadata/create_pm3_measure_calculator_metadata_table.sql';\
	fi

db/create_pm3_eav_append_only_table: db/create_pm3_measure_calculator_metadata_table
	@if ! psql -c '\d public.pm3_eav_append_only' > /dev/null 2>&1; then\
		psql -f './sql/pm3_eav_append_only/create_pm3_eav_append_only.sql';\
	fi

db/cluster_pm3_eav_append_only_table: db/create_pm3_eav_append_only_table
	@psql --quiet -f './sql/pm3_eav_append_only/cluster_pm3_eav_append_only.sql'

db/create_pm3_authoritative_view: db/create_pm3_eav_append_only_table
	@psql --quiet -f './sql/pm3_authoritative_view/create_pm3_authoritative_view.sql';

db/create_pm3_authoritative_geolevel_mview: db/create_pm3_authoritative_view
	@psql --quiet -f './sql/pm3_authoritative_geolevel_mview/create_pm3_authoritative_geolevel_mview.sql';

db/create_pm3_tables: db/create_pm3_authoritative_view

#####################################################


db/create-root-avgtt-table: db/create-root-npmrds-table
	@set -e;\
	if ! psql -c '\d public.avgtt' > /dev/null 2>&1; then\
		psql --quiet -f './sql/avgtt/root/create_avgtt_table.sql';\
	fi

db/load-state-year-avgtt-table: db/create-root-avgtt-table db/create-npmrds-state-table
	@:$(call check_defined,STATE) 
	@:$(call check_defined,YEAR) 
	@psql --quiet -v STATE="$${STATE}" -v YEAR="$${YEAR}" -f ./sql/avgtt/state/create_state_year_avgtt_table.sql


db/create-routing-tables-and-funcitons-for-year: db/create-root-year-npmrds-shapefile-table
	@:$(call check_defined,YEAR)
	@psql --quiet -c "$$(\
		sed "s/__YEAR__/${YEAR}/g;" \
			./sql/routing/create_routing_tables_and_functions_for_year.sql\
	)";


scraping/download-urban-area-boundaries-shapefile:
	@:$(call check_defined,YEAR)
	@${_MKFILE_DIR}/make_targets/etl/download-urban-area-boundaries-shapefile.js \
		--year=${YEAR} \
		--downloadDir="${_MKFILE_DIR}etl/urban_area_boundaries/"
	
scraping/download-fips-codes-csv:
	${_BIN_DIR}/scrapeFipsCodesTable.sh


preprocessing:
	mkdir -p ${_PREPROCESSING_DIR}

etl/download-and-transform-npmrds-data:
	@:$(call check_defined,DOWNLOAD_LINKS)
	@export DOWNLOAD_LINKS;\
	${_MKFILE_DIR}/src/etlPipeline/main

etl/download-and-partition-npmrds-shapefile:
	@:$(call check_defined,COUNTRY)
	@:$(call check_defined,YEAR)
	@export COUNTRY;\
	export YEAR;\
	${_MKFILE_DIR}/make_targets/etl/download-and-partition-npmrds-shapefile.sh


${_NPMRDS_SHAPEFILES_DIR}:
	@mkdir -p ${_NPMRDS_SHAPEFILES_DIR};

data/clean-shapefiles-dir:
	$(shell find ./data/shapefiles \( -iname '*.shx' -o -iname '*.CPG' -o -iname '*.dbf' -o -iname '*.prj' -o -iname '*.sbn' -o -iname '*.sbx' -o -iname '*.shp' -o -iname '*.shp.xml' \) -type f -delete)
	@true

mapbox/create-tileset-for-year:
	@:$(call check_defined,YEAR)
	@export YEAR;\
	${_MKFILE_DIR}/make_targets/mapbox/create-tileset-for-year.sh

