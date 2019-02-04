#!/usr/bin/env node

const { execSync } = require('child_process');
const { Client } = require('pg');
const { join } = require('path');
const envFile = require('node-env-file');


const now = new Date()
const yyyy = now.getFullYear()
const mm = `0${now.getMonth() + 1}`.slice(-2)
const dd = `0${now.getDate()}`.slice(-2)
const HH = `0${now.getHours()}`.slice(-2)
const MM = `0${now.getMinutes()}`.slice(-2)
const SS = `0${now.getSeconds()}`.slice(-2)

const defaultTMCMetadataVer = `${yyyy}${mm}${dd}${HH}${MM}${SS}`

const {
	PG_ENV,
	STATE,
	YEAR,
	INRIX_SHAPEFILE_VER,
	TMC_METADATA_VER
} = process.env

if (!(STATE && YEAR)) {
	console.error('STATE and YEAR are required ENV variables.')
	process.exit(1)
}

const dbConfigFileName =
	PG_ENV === 'production'
		? 'postgres.env.prod'
		: 'postgres.env.dev'

const configPath = join(__dirname, '../../config', dbConfigFileName);
envFile(configPath);

const client = new Client();


const getDefaultInrixShapefileVersion = (state, year) => {
	const sql = `
		SELECT c.relname AS table_name
			FROM pg_inherits 
				JOIN pg_class AS c ON (inhrelid=c.oid)
				JOIN pg_class as p ON (inhparent=p.oid)
				JOIN pg_namespace pn ON pn.oid = p.relnamespace
				JOIN pg_namespace cn ON cn.oid = c.relnamespace
			WHERE (
				(pn.nspname = '${state}')
				AND
				(p.relname = 'inrix_shapefile_${year}')
			)
	`

	const rows = (await client.query(sql))
	const [{ table_name }] = rows

	const [ver] = table_name.match(/v\d{8}/) || [null]

	return ver
}

const doIt = async () => {
  await client.connect();

  const theSQL = `
  `;

  await client.query(theSQL);

  await client.end();
};

doIt();

