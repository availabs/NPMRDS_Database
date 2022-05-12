import { createWriteStream, mkdirSync } from "fs";

import { createGzip } from "zlib";
import { join } from "path";

// NOTE: Using pg-native because it allows synchonous DB queries
//   https://github.com/brianc/node-pg-native/blob/8de48133dcc8c5587686084cab0402ccfe109d65/README.md#sync
import { Client } from "pg";

import _ from "lodash";

import { getNodePgCredentials } from "../../../../utils/PostgreSQL";

import downloadExtendedEventData from "./downloadExtendedEventData";

const dataDir = join(
  __dirname,
  "../../../../../data/transcom-extended-events-data"
);

mkdirSync(dataDir, { recursive: true });

const PG_ENV = "production";
const LATEST = "2022-05-08"; // For resuming after where previous scrape left off
const BATCH_SIZE = 50;

async function main() {
  const creds = getNodePgCredentials(PG_ENV);

  const client = new Client(creds);
  await client.connect();

  try {
    const {
      rows: [{ earliest, latest }],
    } = await client.query(`
        SELECT
            to_char(MIN(creation), 'YYYY-MM-DD') AS earliest,
            to_char(MAX(creation), 'YYYY-MM-DD') AS latest
          FROM transcom.transcom_historical_events;
      `);

    const [startYear, startMonth, startDay] = (LATEST || latest)
      .split(/-/)
      .map((n: string) => +n);

    const [endYear, endMonth, endDay] = earliest
      .split(/-/)
      .map((n: string) => +n);

    const startDate = new Date(startYear, startMonth - 1, startDay);
    const endDate = new Date(endYear, endMonth - 1, endDay);

    let curDate = new Date(startDate);

    let i = 0;
    while (curDate >= endDate) {
      if (i++ >= 2) {
        break;
      }

      const dateString = curDate.toISOString().replace(/T.*/, "");

      console.log(dateString);

      const timestamp = Math.floor(Date.now() / 1000);

      const fileName = `transcom-extended-event-data.${dateString}.${timestamp}.ndjson.gz`;
      const filePath = join(dataDir, fileName);

      const ws = createWriteStream(filePath);
      const gzip = createGzip({ level: 9 });

      gzip.pipe(ws);

      const done = new Promise((resolve) => ws.once("finish", resolve));

      const {
        rows: [{ event_ids }],
      } = await client.query(`
        SELECT
            json_agg(event_id) AS event_ids
          FROM transcom.transcom_historical_events
          WHERE ( open_time::DATE = '${curDate.toISOString()}'::DATE )
      `);

      console.log("  num events:", event_ids.length);

      const batches = _.chunk(event_ids, BATCH_SIZE);

      let wrote = 0;
      console.time(dateString);
      for (let i = 0; i < batches.length; ++i) {
        console.log("  batch:", i, "; wrote:", wrote);
        const batch = batches[i];
        const eventsData = await downloadExtendedEventData(<string[]>batch);

        for (const event of eventsData) {
          let good = gzip.write(`${JSON.stringify(event)}\n`);
          ++wrote;

          if (!good) {
            console.log("    awaiting drain; wrote:", wrote);
            await new Promise<void>((resolve) => {
              let drained = false;

              gzip.once("drain", () => {
                drained = true;
                resolve();
              });

              setTimeout(() => {
                if (!drained) {
                  console.log("  did not get drain event");
                  resolve();
                }
              }, 5000);
            });
          }
        }
        await new Promise((resolve) => setTimeout(resolve, 1000 * 10));
      }

      // console.log("gzip.end");
      gzip.end();

      // console.log("await done");
      await done;
      console.timeEnd(dateString);
      console.log();

      curDate.setDate(curDate.getDate() - 1);
    }
  } catch (err) {
    console.error(err);
  } finally {
    client.end();
  }
}

main();
