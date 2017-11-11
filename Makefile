# Based on the following Makefile 
#   https://github.com/stamen/toner-carto/blob/master/Makefile
# And its explanatory blog post found here:
# http://mojodna.net/2015/01/07/make-for-data-using-make.html

# Use bash for sub-shells, allowing use of bash-specific functionality.
SHELL := /bin/bash

# Add npm-installed binaries to the PATH.
PATH := $(PATH):node_modules/.bin

.DEFAULT_GOAL := echo_conf

# Transform STATE to lowercase
STATE := $(shell echo ${STATE} | tr '[:upper:]' '[:lower:]')

# zero-pad months: see https://stackoverflow.com/a/9671373/3970755
MONTH:=$(shell if [ ${MONTH} ]; then printf '%02.f' "${MONTH}"; fi)


_MKFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

_BIN_DIR := ${_MKFILE_DIR}bin

_PREPROCESSING_DIR := ${_MKFILE_DIR}preprocessing
_INRIX_SHAPEFILE_PREPROCESSING_DIR := ${_PREPROCESSING_DIR}/shapefiles/inrix_shapefile

_DATA_DIR := ${_MKFILE_DIR}data
_DOWNLOAD_DIR := ${_DATA_DIR}/inrix-downloads

_ETL_DIR := etl
_ETL_SORTED_DIR := ${_ETL_DIR}/sorted
_ETL_TRANSFORMED_DIR := ${_ETL_DIR}/transformed

_MPO_BOUNDARIES_DIR := ${_DATA_DIR}/shapefiles/mpo_boundaries/us
_MPO_ACRONYMS_CSV_PATH := ${_DATA_DIR}/csvs/mpo_abbreviations/mpo_abbreviations.csv

_URBAN_AREAS_DIR := ${_DATA_DIR}/shapefiles/urban_area_boundaries/us

_CORE_BASED_STATISTICAL_AREAS_DIR := ${_DATA_DIR}/shapefiles/core_based_statistical_area_boundaries/us

_INRIX_SHAPEFILES_DIR := ${_DATA_DIR}/shapefiles/inrix_shapefile

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
	data/inrix-downloads/ny/2016/02/link \
	etl/sorted/ny_y2016m02.inrix-schema.sorted.csv \
	${_DOWNLOAD_DIR}/**/* \
	${_ETL_SORTED_DIR}/**/*
#  
#  #${_ETL_TRANSFORMED_DIR}/${STATE}/${YEAR}/${STATE}_y${YEAR}m${MONTH}.transformed.csv
#  
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
	data/clean-shapefiles-dir \
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
# !!! NOTE: A comment in postgres.env will cause this Makefile to break !!!
$(foreach a,$(shell cat ./config/postgres.env 2> /dev/null),$(eval $(call EXPAND_EXPORTS,$(a))))

# load data_paths.env
$(foreach a,$(shell cat ./config/data_paths.env 2> /dev/null),$(eval $(call EXPAND_EXPORTS,$(a))))

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
        $(error Undefined $1$(if $2, ($2))$(if $(value @), \
                required by target `$@')))

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
	@if [ ! '$*' ]; then\
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
	@if psql -c '\d public.npmrds' > /dev/null 2>&1; then\
		psql -f './sql/npmrds/root/dropRootNPMRDSDataTable.sql';\
	fi

db/create-root-npmrds-table: db/create-database
	@if ! psql -c '\d public.npmrds' > /dev/null 2>&1; then\
		@psql -f './sql/npmrds/root/createRootNPMRDSDataTable.sql';\
	fi

db/create-root-tmc-date-ranges-table: db/create-database
	@set -e;\
	if ! psql -c '\d public.tmc_date_ranges' > /dev/null 2>&1; then\
		psql -f './sql/tmc_date_ranges/createRootTMCDateRangeTable.sql';\
	fi

db/drop-npmrds-state-table:
	@:$(call check_defined,STATE)
	@psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/npmrds/state/dropStateNPMRDSDataTable.sql)"

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


db/upload-npmrds-state-yrmo: \
	db/drop-npmrds-state-yrmo-table \
	db/create-npmrds-state-yrmo-table

	@# These should be integrated into this target/recipe
	@#${_ETL_TRANSFORMED_DIR}/${STATE}/${YEAR}/${STATE}_y${YEAR}m${MONTH}.transformed.csv \
	@#./bin/projectNPMRDSTableColumns.sh < $<	| psql -c 'COPY "${STATE}".npmrds_y${YEAR}m${MONTH} (tmc,date,epoch,travel_time_all_vehicles,travel_time_passenger_vehicles,travel_time_freight_trucks) FROM STDIN CSV HEADER;'

	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)

	@if [[ $$(psql -t -c 'SELECT * FROM "${STATE}".npmrds_y${YEAR}m${MONTH} LIMIT 1;' | tr -d " \t\n\r";) ]]; then\
		./bin/projectNPMRDSTableColumns.sh < ${_ETL_TRANSFORMED_DIR}/${STATE}/${YEAR}/${STATE}_y${YEAR}m${MONTH}.transformed.csv | psql -c 'COPY "${STATE}".npmrds_y${YEAR}m${MONTH} (tmc,date,epoch,travel_time_all_vehicles,travel_time_passenger_vehicles,travel_time_freight_trucks) FROM STDIN CSV HEADER;';\
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
	fi


db/create-state-tmc-date-ranges-table: db/create-schema-${STATE} db/create-root-tmc-date-ranges-table
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
			" ./sql/tmc_date_ranges/createStateTMCDateRangeTable.sql\
		)";


db/upload-mpo-boundaries: db/create-database db/create-schema-us
	@# TODO: compare version in DB to version in data dir.
	@#       If a newer version available, upload. Otherwise, skip.
	@set -e;\
	LATEST_VERSION=$$(ls ${_MPO_BOUNDARIES_DIR} | sort | tail -1);\
	SHP_DIR=${_MPO_BOUNDARIES_DIR}/$${LATEST_VERSION};\
	pushd $${SHP_DIR} && unzip -o "*.zip" && popd;\
	OGR_OUTPUT=$$(\
		ogr2ogr -t_srs EPSG:4326 -f \
			PostgreSQL 'PG:host=${PGHOST} port=${PGPORT} user=${PGUSER} dbname=${PGDATABASE} password=${PGPASSWORD}' \
			"$${SHP_DIR}" -t_srs EPSG:4326 -lco SCHEMA=us -lco OVERWRITE=YES -nln "mpo_boundaries_$${LATEST_VERSION}" 2>&1;\
	);\
	if [[ $${OGR_OUTPUT} =~ ERROR ]]; then\
		ogr2ogr -t_srs EPSG:4326 -f \
			PostgreSQL 'PG:host=${PGHOST} port=${PGPORT} user=${PGUSER} dbname=${PGDATABASE} password=${PGPASSWORD}' \
			"$${SHP_DIR}" -lco SCHEMA=us -lco OVERWRITE=YES -nlt PROMOTE_TO_MULTI -lco PRECISION=NO -nln "mpo_boundaries_$${LATEST_VERSION}";\
	fi;\
	if [ -f '${_MPO_ACRONYMS_CSV_PATH}' ]; then\
		psql -c 'DROP TABLE IF EXISTS us.mpo_acronymns;';\
		psql -c 'CREATE TABLE us.mpo_acronymns (mpo_id VARCHAR PRIMARY KEY, mpo_acrony VARCHAR);';\
		cat '${_MPO_ACRONYMS_CSV_PATH}' | psql -c "COPY us.mpo_acronymns (mpo_id, mpo_acrony) FROM STDIN CSV HEADER;";\
	fi;\
	psql -c "DROP VIEW IF EXISTS public.mpo_boundaries;";\
	psql -c "CREATE VIEW public.mpo_boundaries AS SELECT * FROM us.mpo_boundaries_$${LATEST_VERSION} LEFT OUTER JOIN us.mpo_acronymns USING (mpo_id);";\
	find $${SHP_DIR} \
		\( -iname '*.shx' -o -iname '*.CPG' -o -iname '*.dbf' -o -iname '*.prj' -o -iname '*.sbn' -o -iname '*.sbx' -o -iname '*.shp' -o -iname '*.shp.xml' \)\
		-type f -delete;

db/upload-inrix-shapefile-for-state: db/create-schema-${STATE}
	@:$(call check_defined,STATE)
	@cd ${_INRIX_SHAPEFILES_DIR} && unzip -o ${STATE}_*.zip;\
	VER=$$(ls ${_INRIX_SHAPEFILES_DIR}/${STATE} | sort | tail -1);\
	LATEST_FILE_VERSION="inrix_shapefile_$${VER}";\
	LATEST_PGDB_VERSION=$$(psql -t -c "SELECT table_name FROM information_schema.tables WHERE (table_schema='${STATE}') and (table_name LIKE 'inrix_shapefile_%') ORDER BY table_name DESC LIMIT 1;" | tr -d " \t\n\r";);\
	echo "== lpgv: $${LATEST_PGDB_VERSION}";\
	if [ -z $${LATEST_PGDB_VERSION} ] || [[ $${LATEST_FILE_VERSION} > $${LATEST_PGDB_VERSION} ]]; then\
		if [ $${LATEST_PGDB_VERSION} ]; then\
			psql -c "DROP TABLE IF EXISTS \"${STATE}\".$${LATEST_PGDB_VERSION} CASCADE;";\
		fi;\
		SHP_DIR="${_INRIX_SHAPEFILES_DIR}/${STATE}/$${VER}/";\
		OGR_OUTPUT=$$(\
			ogr2ogr -t_srs EPSG:4326 -f \
				PostgreSQL 'PG:host=${PGHOST} port=${PGPORT} user=${PGUSER} dbname=${PGDATABASE} password=${PGPASSWORD}' \
				"$${SHP_DIR}" -t_srs EPSG:4326 -lco SCHEMA=${STATE} -lco GEOM_TYPE=geometry -lco OVERWRITE=YES -nln "$${LATEST_FILE_VERSION}" 2>&1;\
		);\
		if [[ $${OGR_OUTPUT} =~ ERROR ]]; then\
			ogr2ogr -t_srs EPSG:4326 -f \
				PostgreSQL 'PG:host=${PGHOST} port=${PGPORT} user=${PGUSER} dbname=${PGDATABASE} password=${PGPASSWORD}' \
				"$${SHP_DIR}" -lco SCHEMA=${STATE} -lco GEOM_TYPE=geometry -lco OVERWRITE=YES -nlt PROMOTE_TO_MULTI -lco PRECISION=NO -nln "$${LATEST_FILE_VERSION}";\
		fi;\
		psql -c "CREATE TABLE IF NOT EXISTS public.inrix_shapefile (LIKE \"${STATE}\".$${LATEST_FILE_VERSION} EXCLUDING ALL);";\
		psql -c "ALTER TABLE \"${STATE}\".$${LATEST_FILE_VERSION} INHERIT public.inrix_shapefile;";\
	else\
		echo "INRIX Shapefile in the database is the latest.";\
	fi;

db/upload-urban-area-boundaries-shapefile: db/create-database db/create-schema-us
	@set -e;\
	LATEST_VERSION=$$(ls ${_URBAN_AREAS_DIR} | sort | tail -1);\
	SHP_DIR=${_URBAN_AREAS_DIR}/$${LATEST_VERSION};\
	pushd $${SHP_DIR} && unzip -o "*.zip" && popd;\
	OGR_OUTPUT=$$(\
		ogr2ogr -t_srs EPSG:4326 -f \
			PostgreSQL 'PG:host=${PGHOST} port=${PGPORT} user=${PGUSER} dbname=${PGDATABASE} password=${PGPASSWORD}' \
			"$${SHP_DIR}" -t_srs EPSG:4326 -lco SCHEMA=us -lco OVERWRITE=YES -nln "urban_area_boundaries_$${LATEST_VERSION}" 2>&1;\
	);\
	if [[ $${OGR_OUTPUT} =~ ERROR ]]; then\
		OGR_OUTPUT=$$(\
			ogr2ogr -t_srs EPSG:4326 -f \
				PostgreSQL 'PG:host=${PGHOST} port=${PGPORT} user=${PGUSER} dbname=${PGDATABASE} password=${PGPASSWORD}' \
				"$${SHP_DIR}" -lco SCHEMA=us -lco OVERWRITE=YES -nlt PROMOTE_TO_MULTI -lco PRECISION=NO -nln "urban_area_boundaries_$${LATEST_VERSION}";\
		);\
		if [[ $${OGR_OUTPUT} =~ ERROR ]]; then\
			echo $${OGR_OUTPUT};\
			exit 1;\
		fi;\
	fi;\
	psql -c "DROP VIEW IF EXISTS public.urban_area_boundaries;";\
	psql -c "CREATE VIEW public.urban_area_boundaries AS SELECT * FROM us.urban_area_boundaries_$${LATEST_VERSION};";\
	find $${SHP_DIR} \
		\( -iname '*.shx' -o -iname '*.CPG' -o -iname '*.dbf' -o -iname '*.prj' -o -iname '*.sbn' -o -iname '*.sbx' -o -iname '*.shp' -o -iname '*.shp.xml' \)\
		-type f -delete;


db/upload-core-based-staticstical-area-boundaries-shapefile: db/create-database db/create-schema-us
	@set -e;\
	LATEST_VERSION=$$(ls ${_CORE_BASED_STATISTICAL_AREAS_DIR} | sort | tail -1);\
	SHP_DIR=${_CORE_BASED_STATISTICAL_AREAS_DIR}/$${LATEST_VERSION};\
	pushd $${SHP_DIR} && unzip -o "*.zip" && popd;\
	OGR_OUTPUT=$$(\
		ogr2ogr -t_srs EPSG:4326 -f \
			PostgreSQL 'PG:host=${PGHOST} port=${PGPORT} user=${PGUSER} dbname=${PGDATABASE} password=${PGPASSWORD}' \
			"$${SHP_DIR}" -t_srs EPSG:4326 -lco SCHEMA=us -lco OVERWRITE=YES -nln "core_based_statistical_area_boundaries_$${LATEST_VERSION}" 2>&1;\
	);\
	if [[ $${OGR_OUTPUT} =~ ERROR ]]; then\
		OGR_OUTPUT=$$(\
			ogr2ogr -t_srs EPSG:4326 -f \
				PostgreSQL 'PG:host=${PGHOST} port=${PGPORT} user=${PGUSER} dbname=${PGDATABASE} password=${PGPASSWORD}' \
				"$${SHP_DIR}" -lco SCHEMA=us -lco OVERWRITE=YES -nlt PROMOTE_TO_MULTI -lco PRECISION=NO -nln "core_based_statistical_area_boundaries_$${LATEST_VERSION}";\
		);\
		if [[ $${OGR_OUTPUT} =~ ERROR ]]; then\
			echo $${OGR_OUTPUT};\
			exit 1;\
		fi;\
	fi;\
	psql -c "DROP VIEW IF EXISTS public.core_based_statistical_area_boundaries;";\
	psql -c "CREATE VIEW public.core_based_statistical_area_boundaries AS SELECT * FROM us.core_based_statistical_area_boundaries_$${LATEST_VERSION};";\
	find $${SHP_DIR} \
		\( -iname '*.shx' -o -iname '*.CPG' -o -iname '*.dbf' -o -iname '*.prj' -o -iname '*.sbn' -o -iname '*.sbx' -o -iname '*.shp' -o -iname '*.shp.xml' \)\
		-type f -delete;




db/create-state-abbreviations-table: db/create-database
	@if ! psql -c '\d public.state_abbreviations' > /dev/null 2>&1; then\
		psql -f 'sql/state_abbreviations/createStateAbbreviationsTable.sql';\
	fi


db/drop-root-regions-table:
	@if psql -c '\d public.regions' > /dev/null 2>&1; then\
		psql -f ./sql/regions/drop_root_regions_table.sql;\
	fi

db/create-root-regions-table: db/create-database
	@if ! psql -c '\d public.regions' > /dev/null 2>&1; then\
		psql -f ./sql/regions/create_root_regions_table.sql;\
	fi


db/drop-state-regions-table:
	@:$(call check_defined,STATE)
	@if psql -c '\d "${STATE}".regions' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/regions/drop_state_regions_table.sql)";\
	fi

db/create-state-regions-table: db/create-root-regions-table
	@:$(call check_defined,STATE)
	@if ! psql -c '\d "${STATE}".regions' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/regions/create_state_regions_table.sql)";\
	fi


db/load-state-regions-table: db/create-state-regions-table
	@:$(call check_defined,STATE)
	@if [ -f ./sql/regions/${STATE}/load_regions.sql ]; then\
		psql -f ./sql/regions/${STATE}/load_regions.sql;\
	fi


db/drop-root-region-to-county-table:
	@if psql -c '\d public.region_to_county' > /dev/null 2>&1; then\
		psql -f ./sql/region_to_county/drop_root_region_to_county_table.sql;\
	fi

db/create-root-region-to-county-table: db/create-database
	@if ! psql -c '\d public.region_to_county' > /dev/null 2>&1; then\
		psql -f ./sql/region_to_county/create_root_region_to_county_table.sql;\
	fi


db/drop-state-region-to-county-table:
	@:$(call check_defined,STATE)
	@if psql -c '\d "${STATE}".region_to_county' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/region_to_county/drop_state_region_to_county_table.sql)";\
	fi

db/create-state-region-to-county-table: db/create-root-region-to-county-table
	@:$(call check_defined,STATE)
	@if ! psql -c '\d "${STATE}".region_to_county' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/region_to_county/create_state_region_to_county_table.sql)";\
	fi


db/load-state-region-to-county-table: db/create-state-region-to-county-table
	@:$(call check_defined,STATE)
	@if [ -f ./sql/region_to_county/${STATE}/load_region_to_county.sql ]; then\
		psql -f ./sql/region_to_county/${STATE}/load_region_to_county.sql;\
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

db/drop-phed-peak-period-type:
	@if [[ $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'phed_peak_period_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f 'sql/phed_peak_period_type/dropPHEDPeakPeriodType.sql';\
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

db/create-phed-peak-period-type: db/create-database
	@if [[ ! $$(psql -t -c "SELECT 1 FROM pg_type WHERE typname = 'phed_peak_period_type';" | tr -d " \t\n\r";) ]]; then\
		psql -f 'sql/phed_peak_period_type/createPHEDPeakPeriodType.sql';\
	fi

db/create-enum-types:\
	db/create-database \
	db/create-traffic-dist-functional-class-type \
	db/create-geography-level-type \
	db/create-functional-class-type \
	db/create-traffic-dist-day-type \
	db/create-traffic-dist-congestion-level-type \
	db/create-traffic-dist-directionality-type

db/drop-root-occupancy-factor-table:
	@if psql -c '\d public.occupancy_factor' > /dev/null 2>&1; then\
		psql -f 'sql/occupancy_factor/drop_root_occupancy_factor_table.sql';\
	fi

db/create-root-occupancy-factor-table: db/create-geography-level-type
	@if ! psql -c '\d public.occupancy_factor' > /dev/null 2>&1; then\
		psql -f 'sql/occupancy_factor/create_root_occupancy_factor_table.sql';\
	fi

db/drop-state-occupancy-factor-table:
	@:$(call check_defined,STATE)
	@if psql -c '\d "${STATE}".occupancy_factor' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" sql/occupancy_factor/drop_state_occupancy_factor_table.sql)";\
	fi

db/create-state-occupancy-factor-table: db/create-state-abbreviations-table db/create-root-occupancy-factor-table
	@:$(call check_defined,STATE)
	@if ! psql -c '\d "${STATE}".occupancy_factor' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" sql/occupancy_factor/create_state_occupancy_factor_table.sql)";\
	fi


db/drop-tmc-attributes:
	# TODO: Handle dependencies
	@if psql -c '\d "public".tmc_attributes' > /dev/null 2>&1; then\
		psql -f './sql/tmc_attributes/dropTMCAttributesMaterializedView.sql';\
	fi

db/create-tmc-attributes:
	# TODO: Handle dependencies
	@if ! psql -c '\d "public".tmc_attributes' > /dev/null 2>&1; then\
		psql -f './sql/tmc_attributes/createTMCAttributesMaterializedView.sql';\
	fi

db/drop-root-lottr-percentiles-table:
	@if psql -c '\d public.lottr_percentiles' > /dev/null 2>&1; then\
		psql -f './sql/lottr_percentiles/drop_root_lottr_percentiles.sql';\
	fi

db/create-root-lottr-percentiles-table:
	@if ! psql -c '\d public.lottr_percentiles' > /dev/null 2>&1; then\
		psql -f './sql/lottr_percentiles/create_root_lottr_percentiles.sql';\
	fi

db/drop-state-lottr-percentiles-table:
	@:$(call check_defined,STATE)
	@if psql -c '\d "${STATE}".lottr_percentiles' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/lottr_percentiles/drop_state_lottr_percentiles.sql)";\
	fi

db/create-state-lottr-percentiles-table: db/create-root-lottr-percentiles-table
	@:$(call check_defined,STATE)
	@if ! psql -c '\d "${STATE}".lottr_percentiles' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/lottr_percentiles/create_state_lottr_percentiles.sql)";\
	fi

db/drop-state-lottr-percentiles-yrmo-table:
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@if psql -c '\d "${STATE}".lottr_percentiles_y${YEAR}m${MONTH}' > /dev/null 2>&1; then\
		psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
				s/__YEAR__/${YEAR}/g;\
				s/__MONTH__/${MONTH}/g;\
			" ./sql/lottr_percentiles/drop_state_lottr_percentiles_yrmo.sql\
		)";\
	fi

db/create-state-lottr-percentiles-yrmo-table: \
	db/create-state-lottr-percentiles-table
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@if ! psql -c '\d "${STATE}".lottr_percentiles_y${YEAR}m${MONTH}' > /dev/null 2>&1; then\
		if [[ ${MONTH} -eq 0 ]]; then\
			START_DATE="$$(date -d "${YEAR}-01-01" '+%F')";\
			END_DATE="$$(date -d "$${START_DATE} + 1 year" '+%F')";\
		else\
			START_DATE="$$(date -d "${YEAR}-${MONTH}-01" '+%F')";\
			END_DATE="$$(date -d "$${START_DATE} + 1 month" '+%F')";\
		fi;\
		psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
				s/__YEAR__/${YEAR}/g;\
				s/__MONTH__/${MONTH}/g;\
				s/__START_DATE__/$${START_DATE}/g;\
				s/__END_DATE__/$${END_DATE}/g;\
			" ./sql/lottr_percentiles/create_state_lottr_percentiles_yrmo.sql\
		)";\
	fi


db/drop-root-tttr-percentiles-table:
	@if psql -c '\d public.tttr_percentiles' > /dev/null 2>&1; then\
		psql -f './sql/tttr_percentiles/drop_root_tttr_percentiles.sql';\
	fi

db/create-root-tttr-percentiles-table:
	@if ! psql -c '\d public.tttr_percentiles' > /dev/null 2>&1; then\
		psql -f './sql/tttr_percentiles/create_root_tttr_percentiles.sql';\
	fi

db/drop-state-tttr-percentiles-table:
	@:$(call check_defined,STATE)
	@if psql -c '\d "${STATE}".tttr_percentiles' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/tttr_percentiles/drop_state_tttr_percentiles.sql)";\
	fi

db/create-state-tttr-percentiles-table: db/create-root-tttr-percentiles-table
	@:$(call check_defined,STATE)
	@if ! psql -c '\d "${STATE}".tttr_percentiles' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/tttr_percentiles/create_state_tttr_percentiles.sql)";\
	fi

db/drop-state-tttr-percentiles-yrmo-table:
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@if psql -c '\d "${STATE}".tttr_percentiles_y${YEAR}m${MONTH}' > /dev/null 2>&1; then\
		psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
				s/__YEAR__/${YEAR}/g;\
				s/__MONTH__/${MONTH}/g;\
			" ./sql/tttr_percentiles/drop_state_tttr_percentiles_yrmo.sql\
		)";\
	fi

db/create-state-tttr-percentiles-yrmo-table: \
	db/create-state-tttr-percentiles-table
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@if ! psql -c '\d "${STATE}".tttr_percentiles_y${YEAR}m${MONTH}' > /dev/null 2>&1; then\
		if [[ ${MONTH} -eq 0 ]]; then\
			START_DATE="$$(date -d "${YEAR}-01-01" '+%F')";\
			END_DATE="$$(date -d "$${START_DATE} + 1 year" '+%F')";\
		else\
			START_DATE="$$(date -d "${YEAR}-${MONTH}-01" '+%F')";\
			END_DATE="$$(date -d "$${START_DATE} + 1 month" '+%F')";\
		fi;\
		psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
				s/__YEAR__/${YEAR}/g;\
				s/__MONTH__/${MONTH}/g;\
				s/__START_DATE__/$${START_DATE}/g;\
				s/__END_DATE__/$${END_DATE}/g;\
			" ./sql/tttr_percentiles/create_state_tttr_percentiles_yrmo.sql\
		)";\
	fi


db/drop-root-top-level-travel-time-reliability-table:
	@if psql -c '\d public.top_level_travel_time_reliability' > /dev/null 2>&1; then\
		psql -f './sql/top_level_travel_time_reliability/drop_root_top_level_travel_time_reliability.sql';\
	fi

db/create-root-top-level-travel-time-reliability-table:
	@if ! psql -c '\d public.top_level_travel_time_reliability' > /dev/null 2>&1; then\
		psql -f './sql/top_level_travel_time_reliability/create_root_top_level_travel_time_reliability.sql';\
	fi

db/drop-state-top-level-travel-time-reliability-table:
	@:$(call check_defined,STATE)
	@if psql -c '\d "${STATE}".top_level_travel_time_reliability' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/top_level_travel_time_reliability/drop_state_top_level_travel_time_reliability.sql)";\
	fi

db/create-state-top-level-travel-time-reliability-table: db/create-root-top-level-travel-time-reliability-table
	@:$(call check_defined,STATE)
	@if ! psql -c '\d "${STATE}".top_level_travel_time_reliability' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/top_level_travel_time_reliability/create_state_top_level_travel_time_reliability.sql)";\
	fi

db/load-state-top-level-travel-time-reliability-yrmo-table: db/create-state-top-level-travel-time-reliability-table
	@:$(call check_defined,STATE)
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@psql -c "$$(\
		sed "\
			s/__STATE__/${STATE}/g;\
			s/__YEAR__/${YEAR}/g;\
			s/__MONTH__/${MONTH}/g;\
			" ./sql/top_level_travel_time_reliability/create_state_top_level_travel_time_reliability_yrmo.sql\
		)";\


db/drop-root-top-level-freight-reliability-table:
	@if psql -c '\d public.top_level_freight_reliability' > /dev/null 2>&1; then\
		psql -f './sql/top_level_freight_reliability/drop_root_top_level_freight_reliability.sql';\
	fi

db/create-root-top-level-freight-reliability-table:
	@if ! psql -c '\d public.top_level_freight_reliability' > /dev/null 2>&1; then\
		psql -f './sql/top_level_freight_reliability/create_root_top_level_freight_reliability.sql';\
	fi

db/drop-state-top-level-freight-reliability-table:
	@:$(call check_defined,STATE)
	@if psql -c '\d "${STATE}".top_level_freight_reliability' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/top_level_freight_reliability/drop_state_top_level_freight_reliability.sql)";\
	fi

db/create-state-top-level-freight-reliability-table: db/create-root-top-level-freight-reliability-table
	@:$(call check_defined,STATE)
	@if ! psql -c '\d "${STATE}".top_level_freight_reliability' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/top_level_freight_reliability/create_state_top_level_freight_reliability.sql)";\
	fi

db/load-state-top-level-freight-reliability-yrmo-table: db/create-state-top-level-freight-reliability-table
	@:$(call check_defined,STATE)
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@psql -c "$$(\
		sed "\
			s/__STATE__/${STATE}/g;\
			s/__YEAR__/${YEAR}/g;\
			s/__MONTH__/${MONTH}/g;\
			" ./sql/top_level_freight_reliability/create_state_top_level_freight_reliability_yrmo.sql\
		)";\

db/drop-traffic-distributions-table:
	@if psql -c '\d public.traffic_distributions' > /dev/null 2>&1; then\
		psql -f ./sql/traffic_distributions/dropTrafficDistributionsTable.sql;\
	fi

db/create-traffic-distributions-table:
	@if ! psql -c '\d public.traffic_distributions' > /dev/null 2>&1; then\
		psql -f ./sql/traffic_distributions/createTrafficDistributionsTable.sql;\
	fi

db/drop-geography-level-attributes-view:
	@if psql -c '\d public.geography_level_attributes_view' > /dev/null 2>&1; then\
		psql -f './sql/geography_level_attributes_view/dropStateGeographyLevelAttributesView.sql';\
	fi

db/create-geography-level-attributes-view: db/create-tmc-attributes
	@if ! psql -c '\d public.geography_level_attributes_view' > /dev/null 2>&1; then\
		psql -f './sql/geography_level_attributes_view/createStateGeographyAttributesView.sql';\
	fi



db/drop-root-excessive-delay-brkdwn-table:
	@if psql -c '\d public.excessive_delay_brkdwn' > /dev/null 2>&1; then\
		psql -f './sql/excessive_delay_brkdwn/dropRootExcessiveDelayBrkdwwnTable.sql';\
	fi

db/create-root-excessive-delay-brkdwn-table:
	@if ! psql -c '\d public.excessive_delay_brkdwn' > /dev/null 2>&1; then\
		psql -f './sql/excessive_delay_brkdwn/createRootExcessiveDelayBrkdwnTable.sql';\
	fi

db/drop-state-excessive-delay-brkdwn-table:
	@:$(call check_defined,STATE)
	@if psql -c '\d "${STATE}".excessive_delay_brkdwn' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/excessive_delay_brkdwn/dropStateExcessiveDelayBrkdwnTable.sql)";\
	fi

db/create-state-excessive-delay-brkdwn-table: db/create-root-excessive-delay-brkdwn-table
	@:$(call check_defined,STATE)
	@if ! psql -c '\d "${STATE}".excessive_delay_brkdwn' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/excessive_delay_brkdwn/createStateExcessiveDelayBrkdwnTable.sql)";\
	fi

db/drop-state-excessive-delay-brkdwn-yrmo-table:
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@if psql -c '\d "${STATE}".excessive_delay_brkdwn_y${YEAR}m${MONTH}' > /dev/null 2>&1; then\
		psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
				s/__YEAR__/${YEAR}/g;\
				s/__MONTH__/${MONTH}/g;\
			" ./sql/excessive_delay_brkdwn/dropStateExcessiveDelayBrkdwnYrMoTable.sql\
		)";\
	fi

db/create-state-excessive-delay-brkdwn-yrmo-table: \
	db/create-state-excessive-delay-brkdwn-table
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@if ! psql -c '\d "${STATE}".excessive_delay_brkdwn_y${YEAR}m${MONTH}' > /dev/null 2>&1; then\
		if [[ ${MONTH} -eq 0 ]]; then\
			START_DATE="$$(date -d "${YEAR}-01-01" '+%F')";\
			END_DATE="$$(date -d "$${START_DATE} + 1 year" '+%F')";\
		else\
			START_DATE="$$(date -d "${YEAR}-${MONTH}-01" '+%F')";\
			END_DATE="$$(date -d "$${START_DATE} + 1 month" '+%F')";\
		fi;\
		psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
				s/__YEAR__/${YEAR}/g;\
				s/__MONTH__/${MONTH}/g;\
				s/__START_DATE__/$${START_DATE}/g;\
				s/__END_DATE__/$${END_DATE}/g;\
			" ./sql/excessive_delay_brkdwn/createStateExcessiveDelayBrkdwnYrMoTable.step-1.sql\
		)";\
		psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
				s/__YEAR__/${YEAR}/g;\
				s/__MONTH__/${MONTH}/g;\
				s/__START_DATE__/$${START_DATE}/g;\
				s/__END_DATE__/$${END_DATE}/g;\
			" ./sql/excessive_delay_brkdwn/createStateExcessiveDelayBrkdwnYrMoTable.step-2.sql\
		)";\
	fi


db/drop-root-top-level-total-excessive-delay-table:
	@if psql -c '\d public.top_level_total_excessive_delay' > /dev/null 2>&1; then\
		psql -f './sql/top_level_total_excessive_delay/drop_root_top_level_total_excessive_delay.sql';\
	fi

db/create-root-top-level-total-excessive-delay-table:
	@if ! psql -c '\d public.top_level_total_excessive_delay' > /dev/null 2>&1; then\
		psql -f './sql/top_level_total_excessive_delay/create_root_top_level_total_excessive_delay.sql';\
	fi

db/drop-state-top-level-total-excessive-delay-table:
	@:$(call check_defined,STATE)
	@if psql -c '\d "${STATE}".top_level_total_excessive_delay' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/top_level_total_excessive_delay/drop_state_top_level_total_excessive_delay.sql)";\
	fi

db/create-state-top-level-total-excessive-delay-table: db/create-root-top-level-total-excessive-delay-table
	@:$(call check_defined,STATE)
	@if ! psql -c '\d "${STATE}".top_level_total_excessive_delay' > /dev/null 2>&1; then\
		psql -c "$$(sed "s/__STATE__/${STATE}/g" ./sql/top_level_total_excessive_delay/create_state_top_level_total_excessive_delay.sql)";\
	fi

db/drop-state-top-level-total-excessive-delay-yrmo-table:
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@if psql -c '\d "${STATE}".top_level_total_excessive_delay_y${YEAR}m${MONTH}' > /dev/null 2>&1; then\
		psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
				s/__YEAR__/${YEAR}/g;\
				s/__MONTH__/${MONTH}/g;\
			" ./sql/top_level_total_excessive_delay/drop_state_top_level_total_excessive_delay_yrmo.sql\
		)";\
	fi

db/create-state-top-level-total-excessive-delay-yrmo-table: \
	db/create-state-top-level-total-excessive-delay-table
	@:$(call check_defined,STATE) #redundant, since source target calls the same.
	@:$(call check_defined,YEAR)
	@:$(call check_defined,MONTH)
	@if ! psql -c '\d "${STATE}".top_level_total_excessive_delay_y${YEAR}m${MONTH}' > /dev/null 2>&1; then\
		psql -c "$$(\
			sed "\
				s/__STATE__/${STATE}/g;\
				s/__YEAR__/${YEAR}/g;\
				s/__MONTH__/${MONTH}/g;\
			" ./sql/top_level_total_excessive_delay/create_state_top_level_total_excessive_delay_yrmo.sql\
		)";\
	fi


db/drop-terse-bq-top-level-measures-fn:
	@psql -f './sql/bq_top_level_measures_fn/drop_terse_bq_top_level_measures_fn.sql'

db/create-terse-bq-top-level-measures-fn:
	@psql -f './sql/bq_top_level_measures_fn/create_terse_bq_top_level_measures_fn.sql'
		
db/drop-verbose-bq-top-level-measures-fn:
	@psql -f './sql/bq_top_level_measures_fn/drop_verbose_bq_top_level_measures_fn.sql'

db/create-verbose-bq-top-level-measures-fn:
	@psql -f './sql/bq_top_level_measures_fn/create_verbose_bq_top_level_measures_fn.sql'
		

db/create-npmrds-year-fn:
	@psql -f './sql/npmrds_year_fn/create_npmrds_year_function.sql'

db/create-npmrds-month-fn:
	@psql -f './sql/npmrds_month_fn/create_npmrds_month_function.sql'
		
db/create-npmrds-date-fn:
	@psql -f './sql/npmrds_date_fn/create_npmrds_date_function.sql'

db/create-timestamptoepoch-fn:
	@psql -f './sql/timestamptoepoch_fn/create_timestamptoepoch_function.sql'

		

#####################################################

#### External API

${_SPEEDLIMITS_DATA_DIR}:
	mkdir -p ${_SPEEDLIMITS_DATA_DIR}

scraping/scrape-speedlimits: db/upload-inrix-shapefile-for-state
	@:$(call check_defined,STATE)
	@if [ ! -d "${_SCRAPED_SPEEDLIMITS_DIR}/${STATE}" ]; then\
		echo 'Scraping speedlimits.';\
		node ./src/speedlimitScraper/speedlimitsScraper.js --state=${STATE};\
	fi
	
scraping/update-scraped-speedlimits-info: db/upload-inrix-shapefile-for-state
	@:$(call check_defined,STATE)
	node ./src/speedlimitScraper/speedlimitsScraper.js --state=${STATE};\

scraping/download-urban-area-boundaries-shapefile:
	${_BIN_DIR}/scrapeCensus.js --geographyType=urban_area
	
scraping/download-core-based-statistical-area-boundaries-shapefile:
	${_BIN_DIR}/scrapeCensus.js --geographyType=core_based_statistical_area
	

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

db/create-state-average-speedlimits-table: data/move-speedlimits-csv-to-data-dir db/create-root-average-speedlimits-table db/create-schema-${STATE}
	@:$(call check_defined,STATE)
	@if ! psql -c '\d ${STATE}.avg_speedlimits' > /dev/null 2>&1; then\
		psql -c "$$(sed 's/__STATE__/${STATE}/g' ./sql/avg_speedlimits/createStateAvgSpeedlimitsTable.sql)";\
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


	

preprocessing:
	mkdir -p ${_PREPROCESSING_DIR}

preprocessing/partition-inrix-shapefile:
	source ${_BIN_DIR}/stateAbbreviations.sh;\
	SHP_ZIP=${_INRIX_SHAPEFILE_PREPROCESSING_DIR}/USA.zip;\
	STATES_DIR=${_INRIX_SHAPEFILE_PREPROCESSING_DIR}/states;\
	if [ ! -f $${SHP_ZIP} ]; then\
		echo 'ERROR: The INRIX-Shapefile is expected to be here: $${SHP_ZIP}';\
	else\
		rm -rf $${STATES_DIR};\
		mkdir -p $${STATES_DIR};\
		unzip -o $${SHP_ZIP} -d $${STATES_DIR};\
		pushd $${STATES_DIR};\
		for f in *; do \
			state="$${f/\.*/}";\
			dir="$${STATE_ABBREVIATIONS[$${state,,}]}";\
			mkdir -p "$${dir}";\
			mv "$${f}" "$${dir}";\
		done;\
		for state_dir in *; do\
			pushd "$${state_dir}";\
			ver=$$(ogrinfo -ro -so -al . | grep 'DBF_DATE_LAST_UPDATE' | sed 's/.*=//g; s/-//g');\
			if [ -z $${ver} ]; then ver='00000000'; fi;\
			mkdir -p $${ver};\
			find . -maxdepth 1 -type f -exec mv "{}" "$${ver}/{}" \;;\
			popd;\
			zip -r "$${state_dir}_$${ver}.zip" $${state_dir};\
			rm -rf $${state_dir};\
		done;\
	fi

# preprocessing/extract-here-shapefile-from-tar: ${_HERE_SHAPEFILES_DIR}
	# @set -e;\
	# cd ${_HERE_SHAPEFILE_PREPROCESSING_DIR};\
	# LATEST_TAR="$$(find '${_HERE_SHAPEFILE_PREPROCESSING_DIR}' -maxdepth 1 -name '*.tar' | sort | tail -1)";\
	# tar -xf "$${LATEST_TAR}" -C'${_HERE_SHAPEFILES_DIR}' --wildcards "*Shapefile*";

${_INRIX_SHAPEFILES_DIR}:
	@mkdir -p ${_INRIX_SHAPEFILES_DIR};

# ${_HERE_SHAPEFILES_DIR}:
	# @mkdir -p ${_HERE_SHAPEFILES_DIR};

data/copy-state-inrix-shapefile-from-preprocessing-to-data: ${_INRIX_SHAPEFILES_DIR}
	@:$(call check_defined,STATE)
	@cp ${_PREPROCESSING_DIR}/shapefiles/inrix_shapefile/states/${STATE}_*.zip ${_INRIX_SHAPEFILES_DIR}

data/download-inrix-data: ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/data.zip

data/remove-state-yrmo-downloads-directory: 
	rm -rf ${_DOWNLOAD_DIR}/${STATE}/${YEAR}/${MONTH}/

# Removes any regular files not named data.zip or link
data/clean-downloads-directory:
	@find data/inrix-downloads/\
		! \( -name 'data.zip' -o -name 'link' \) \
		-type f -delete

data/clean-shapefiles-dir:
	$(shell find ./data/shapefiles \( -iname '*.shx' -o -iname '*.CPG' -o -iname '*.dbf' -o -iname '*.prj' -o -iname '*.sbn' -o -iname '*.sbx' -o -iname '*.shp' -o -iname '*.shp.xml' \) -type f -delete)
	@true

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
