#!/usr/bin/env node

const { execSync } = require('child_process');
const { Client } = require('pg');
const { join } = require('path');

const envFile = require('node-env-file');

const extractRequiredRelations = require('../../src/extractRequiredRelations');

const { PG_ENV, STATE, YEAR, NPMRDS_SHAPEFILE_VERSION } = process.env;

if (NPMRDS_SHAPEFILE_VERSION && !Number.isFinite(+NPMRDS_SHAPEFILE_VERSION)) {
  console.error(
    `ERROR: Invalid NPMRDS_SHAPEFILE_VERSION ${NPMRDS_SHAPEFILE_VERSION}`
  );
  process.exit(1);
}

const sqlFilePath = join(
  __dirname,
  '../../sql/tmc_metadata/state/loadStateTMCMetadataTableVersion.sql'
);

if (!(STATE && YEAR)) {
  console.error('STATE and YEAR are required ENV variables.');
  process.exit(1);
}

const dbConfigFileName =
  PG_ENV === 'production' ? 'postgres.env.prod' : 'postgres.env.dev';

const configPath = join(__dirname, '../../config', dbConfigFileName);
envFile(configPath);

const client = new Client();

const getDefaultNpmrdsShapefileVersion = async (state, year) => {
  const sql = `
    SELECT
        MAX(s.npmrds_shapefile_version) AS ver
      FROM npmrds_shapefile_${YEAR} AS s
        INNER JOIN state_abbreviations AS a
        ON (s.state = a.state_name)
      WHERE (
        (a.abbreviation = $1)
        AND
        (s.conflation_year = $2)
      )
  `;

  const { rows } = await client.query(sql, [state, year]);
  const [{ ver }] = rows;

  return ver;
};

const getTMCMetadataVersion = () => {
  const now = new Date();
  const yyyy = now.getFullYear();
  const mm = `0${now.getMonth() + 1}`.slice(-2);
  const dd = `0${now.getDate()}`.slice(-2);
  const HH = `0${now.getHours()}`.slice(-2);
  const MM = `0${now.getMinutes()}`.slice(-2);
  const SS = `0${now.getSeconds()}`.slice(-2);

  return `${yyyy}${mm}${dd}${HH}${MM}${SS}`;
};

const createTMCMetadataTable = (npmrdsShapefileVer, tmcMetadataVersion) => {
  const cmd = `
    psql \
      --quiet \
      --echo-queries \
      -v ON_ERROR_STOP=1 \
      -v STATE=${STATE} \
      -v YEAR=${YEAR} \
      -v NPMRDS_SHAPEFILE_VERSION=${npmrdsShapefileVer} \
      -v TMC_METADATA_VERSION=${tmcMetadataVersion} \
      -f '${sqlFilePath}'
  `;

  const createTableSQL = execSync(cmd, { encoding: 'utf8' });

  return createTableSQL;
};

const getDependencies = async requiredRelations => {
  const sql = `select relation_dependencies_fn($1::JSON) AS dependencies;`;

  const {
    rows: [{ dependencies }]
  } = await client.query(sql, [JSON.stringify(requiredRelations)]);

  return dependencies;
};

const getClassOID = async tableName => {
  const queryOID = `
		SELECT pg_class.oid AS oid
			FROM pg_class JOIN pg_namespace 
				ON (pg_class.relnamespace = pg_namespace.oid)	
			WHERE (
				(pg_class.relname = $1)
				AND
				(pg_namespace.nspname = $2)
			)
	`;

  const {
    rows: [{ oid = null }]
  } = await client.query(queryOID, [tableName, STATE]);

  return oid;
};

const insertRowInAvailMetadataTable = async ({
  npmrdsShapefileVer,
  createdTimestamp,
  tmcMetadataVersion,
  createTableSQL
}) => {
  const tableName = `tmc_metadata_${YEAR}_shpver${npmrdsShapefileVer}_v${tmcMetadataVersion}`;

  const classOID = await getClassOID(tableName);

  if (!classOID) {
    throw new Error(
      `Unable to find "${STATE}".${tableName} in pg_class system catalog.`
    );
  }

  const requiredRelations = extractRequiredRelations(createTableSQL);
  const dependencies = await getDependencies(requiredRelations);

  const metadata = {
    schemaname: STATE,
    relname: tableName,
    npmrdsShapefileVer,
    createdTimestamp,
    dependencies
  };

  const sql = `
		INSERT INTO avail_table_metadata (class_oid, metadata, sql)
			VALUES ($1, $2, $3);
	`;

  await client.query(sql, [classOID, metadata, createTableSQL]);
};

const doIt = async () => {
  try {
    await client.connect();

    const npmrdsShapefileVer =
      NPMRDS_SHAPEFILE_VERSION ||
      (await getDefaultNpmrdsShapefileVersion(STATE, YEAR));

    if (!npmrdsShapefileVer) {
      throw new Error(
        `ERROR: no shapefiles for ${STATE} conflation year ${YEAR}`
      );
    }

    const tmcMetadataVersion = getTMCMetadataVersion();

    const createTableSQL = createTMCMetadataTable(
      npmrdsShapefileVer,
      tmcMetadataVersion
    );

    const createdTimestamp = new Date();

    await insertRowInAvailMetadataTable({
      npmrdsShapefileVer,
      createdTimestamp,
      tmcMetadataVersion,
      createTableSQL
    });
  } catch (err) {
    console.error(err);
  } finally {
    await client.end();
  }
};

doIt();
