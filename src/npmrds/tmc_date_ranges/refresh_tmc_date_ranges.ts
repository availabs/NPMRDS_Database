import { execSync } from "child_process";

import { getPsqlCredentials } from "../../utils/PostgreSQL";

export default function main(
  state: string,
  pgEnv: "development" | "production"
) {
  const pgCreds = getPsqlCredentials(pgEnv);

  execSync(
    `
      psql \
        --single-transaction \
        -v ON_ERROR_STOP=1 \
        -v STATE=${state} \
        -f ./sql/createRootTMCDateRangeTable.sql \
        -f ./sql/createStateTMCDateRangeTable.sql \
        -f ./sql/refreshStateTMCDateRangeTable.sql
    `,
    { cwd: __dirname, env: { ...process.env, ...pgCreds }, encoding: "utf8" }
  );
}
