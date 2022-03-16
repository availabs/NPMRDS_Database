import { execSync } from "child_process";
import { join } from "path";

import yargs from "yargs";

import {
  getPsqlCredentials,
  cliArgsSpec,
} from "../../../../make_targets/utils/PostgreSQL";

const { argv } = yargs
  .strict()
  .parserConfiguration({
    "camel-case-expansion": false,
    "flatten-duplicate-arrays": false,
  })
  .wrap(yargs.terminalWidth() / 1.618)
  // @ts-ignore
  .option(cliArgsSpec);

// @ts-ignore
const pgCreds = getPsqlCredentials(argv.pg_env);

const sqlPath = join(
  __dirname,
  "../../../../sql/transcom_historical_events/transcom_event_classifications.sql"
);

execSync(`psql -f '${sqlPath}'`, { env: { ...process.env, ...pgCreds } });
