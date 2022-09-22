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
  console.log("==> npmrds/tmc_identification/publish-tmc-identification");

  table_schema = table_schema.toLowerCase();
  table_name = table_name.toLowerCase();

  const passedDb = !!db;

  if (!passedDb) {
    db = await getConnectedPgClient(pg_env);
  }

  const parent_table_name = table_name.replace(/_v[0-9]{8}t[0-9]{6}$/, "");

  if (table_name === parent_table_name) {
    throw new Error(
      `INVARIANT BROKEN: table_name = ${table_name}; parent_table_name = ${parent_table_name}`
    );
  }

  const q = `
    SELECT
        c.relname AS previous_child_table_name
      FROM pg_inherits 
        INNER JOIN pg_class AS c
          ON (inhrelid=c.oid)
        INNER JOIN pg_class as p
          ON (inhparent=p.oid)
        INNER JOIN pg_namespace pn
          ON pn.oid = p.relnamespace
        INNER JOIN pg_namespace cn
          ON cn.oid = c.relnamespace
      WHERE (
        ( pn.nspname = $1 )
        AND
        ( p.relname = $2 )
      )
  `;

  const { rows } = await db.query(q, [table_schema, parent_table_name]);

  console.log(
    JSON.stringify(
      { table_schema, table_name, parent_table_name, rows },
      null,
      4
    )
  );

  const stmts = passedDb ? [] : ["BEGIN;"];

  let previous_child_table_name: string = null;

  if (rows.length > 0) {
    if (rows.length > 1) {
      throw new Error(
        `INVARIANT BROKEN: "${table_schema}".${table_name} has more than one child table.`
      );
    }

    [{ previous_child_table_name }] = rows;

    const noInheritStmt = pgFormat(
      "ALTER TABLE %I.%I NO INHERIT %I.%I ;",
      table_schema,
      previous_child_table_name,
      table_schema,
      parent_table_name
    );

    stmts.push(noInheritStmt);
  }

  const inheritStmt = pgFormat(
    "ALTER TABLE %I.%I INHERIT %I.%I ;",
    table_schema,
    table_name,
    table_schema,
    parent_table_name
  );

  stmts.push(inheritStmt);

  if (!passedDb) {
    stmts.push("COMMIT;");
  }

  for (const stmt of stmts) {
    await db.query(stmt);
  }

  return {
    table_schema,
    table_name,
    parent_table_name,
    previous_child_table_name,
  };
}
