import { Client } from "pg";
import pgFormat from "pg-format";

import { getConnectedPgClient } from "../../utils/PostgreSQL";

export default async function main({
  table_schema,
  table_name,
  pg_env = "development",
  db,
}: {
  table_schema: string;
  table_name: string;
  pg_env: "development" | "production";
  db?: Client;
}) {
  console.log(
    "==> npmrds/npmrds_travel_times/publish-npmrds-state-yrmo: TODO IMPLEMENT"
  );

  return {
    table_schema,
    table_name,
  };
}
