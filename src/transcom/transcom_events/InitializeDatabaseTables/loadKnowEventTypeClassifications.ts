import { execSync } from "child_process";
import { createReadStream } from "fs";
import { join } from "path";

import yargs from "yargs";

import {
  getPsqlCredentials,
  cliArgsSpec,
} from "../../../../make_targets/utils/PostgreSQL";

const sqlPath = join(
  __dirname,
  "../../../../sql/transcom_historical_events/load_transcom_event_type_classifications.sql"
);

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

const inputStream = createReadStream(
  join(__dirname, "./data/transcom_event_type_classifications.csv"),
  {
    encoding: "utf8",
  }
);

inputStream.on("open", () => {
  const stdio = execSync(`psql -f '${sqlPath}'`, {
    stdio: [inputStream],
    env: { ...process.env, ...pgCreds },
    encoding: "utf8",
  });

  console.log(JSON.stringify({ stdio }, null, 4));
});
