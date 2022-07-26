import { readdirSync, readFileSync } from "fs";
import { join } from "path";

import _ from "lodash";
import pgFormat from "pg-format";

import { Client } from "pg";

import { getConnectedPgClient } from "../../src/utils/PostgreSQL";

const dataDir = join(__dirname, "data");

// npmrds_travel_time_stats.ct.201701.20220722T171844195Z.json
const statFileRE =
  /^npmrds_travel_time_stats\.[a-z]{2}.\d{6}\.\d{8}T\d{9}Z\.json$/;

const collectStats = () =>
  readdirSync(dataDir)
    .filter((f) => statFileRE.test(f))
    .sort()
    .reduce((acc, f) => {
      const stats = JSON.parse(
        readFileSync(join(dataDir, f), { encoding: "utf8" })
      );

      Object.keys(stats).forEach((frc) => {
        Object.keys(stats[frc]).forEach((stat) => {
          if (stat === "quartiles_pct_epochs_reporting") {
            stats[frc][stat] = stats[frc][stat].map((n: number) =>
              _.round(n, 3)
            );
          } else {
            stats[frc][stat] = _.round(stats[frc][stat], 3);
          }
        });
      });

      const [, state, yrmo] = f.split(/\./);
      const yearMonth = `${yrmo.slice(0, 4)}-${yrmo.slice(4, 6)}`;

      acc[state] = acc[state] || {};
      acc[state][yearMonth] = stats;
      return acc;
    }, {});

async function loadStatsForSource(db: Client, stats: object) {
  const sql = `
    UPDATE data_manager.sources
      SET statistics = $1
      WHERE name = 'USDOT/FHWA/NPMRDS/TRAVEL_TIME_DATA'
    ;
  `;

  await db.query(sql, [stats]);
}

async function main() {
  const stats = collectStats();

  const db = await getConnectedPgClient("production");

  await loadStatsForSource(db, stats);

  await db.end();
}

main();
