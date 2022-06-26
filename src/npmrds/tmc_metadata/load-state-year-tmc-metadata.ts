#!/usr/bin/env node

import { execSync } from "child_process";

import { getPsqlCredentials } from "../../utils/PostgreSQL";

import { PgEnv } from "../../domain/PostgreSQLTypes.d";

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

export default function main(state: string, year: number, pgEnv: PgEnv) {
  const tmcMetadataVersion = getTMCMetadataVersion();

  const pgCreds = getPsqlCredentials(pgEnv);

  const cmd = `
    psql \
      --single-transaction \
      --quiet \
      --echo-queries \
      -v ON_ERROR_STOP=1 \
      -v STATE=${state} \
      -v YEAR=${year} \
      -v TMC_METADATA_VERSION=${tmcMetadataVersion} \
      -f './sql/root/createRootYearTMCMetadataTable.sql' \
      -f './sql/state/createStateYearTMCMetadataTable.sql' \
      -f './sql/state/loadStateTMCMetadataTableVersion.sql'
  `;

  const createTableSQL = execSync(cmd, {
    cwd: __dirname,
    env: { ...process.env, ...pgCreds },
    encoding: "utf8",
  });

  return createTableSQL;
}
