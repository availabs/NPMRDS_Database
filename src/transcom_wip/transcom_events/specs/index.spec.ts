/* eslint-disable no-restricted-syntax */

import { join } from "path";

import test from "tape";

import _ from "lodash";
import split from "split2";

import { Client } from "pg";
import pgFormat from "pg-format";

import { getConnectedPgClient } from "../../../utils/PostgreSQL";

import { getTranscomRequestFormattedTimestamp } from "../utils/dates";
import {
  makeRawTranscomEventIterator,
  makeRawTranscomEventIteratorFromApiScrapeFile,
  transformRawTranscomEventIteratorToProtoTranscomEventIterator,
  protoTranscomEventIteratorToCsvStream,
  loadProtoTranscomEventsIntoDatabase,
} from "../";

import { apiResponsePropsToDbCols, dbCols } from "../data_schema";

const NUM_LINES_IN_TEST_FILE = 100;

const testNdjsonPath = join(
  __dirname,
  "./test_data/raw-transcom-events.test-sample.ndjson.gz"
);

const expectedApiResProps = Object.keys(apiResponsePropsToDbCols).sort();

const startTimestamp = getTranscomRequestFormattedTimestamp(
  new Date("2022-04-30:23:30")
);

const endTimestamp = getTranscomRequestFormattedTimestamp(
  new Date("2022-05-01T00:30")
);

// Skip this one so hitting TRANSCOM's API isn't part of normal testing.
test.skip("makeRawTranscomEventIterator yields events", async (t) => {
  const iter = makeRawTranscomEventIterator(startTimestamp, endTimestamp);

  let count = 0;
  let hasExpectedProps = true;
  for await (const event of iter) {
    if (!hasExpectedProps) {
      break;
    }

    ++count;
    hasExpectedProps =
      hasExpectedProps &&
      _.isEqual(Object.keys(event).sort(), expectedApiResProps);
  }

  t.true(count > 0, "Received TRANSCOM events");
  t.true(hasExpectedProps, "TRANSCOM events have expected properties");

  t.end();
});

test("createDownloadedTranscomEventsCsvStream", async (t) => {
  const rawIter = makeRawTranscomEventIteratorFromApiScrapeFile(testNdjsonPath);
  const protoIter =
    transformRawTranscomEventIteratorToProtoTranscomEventIterator(rawIter);
  const stream = protoTranscomEventIteratorToCsvStream(protoIter).pipe(split());

  let count = 0;
  for await (const row of stream) {
    if (!count) {
      t.equal(row, `${dbCols}`, "CSV head === dbCols");
    }

    ++count;
  }

  t.equals(
    count,
    NUM_LINES_IN_TEST_FILE + 1, // +1 for header
    "Stream has expected number of rows"
  );

  t.end();
});

test.skip("loadApiScrapeFileIntoDatabase", async (t) => {
  let db: Client;

  try {
    db = await getConnectedPgClient("development");

    const rawIter =
      makeRawTranscomEventIteratorFromApiScrapeFile(testNdjsonPath);

    const protoIter =
      transformRawTranscomEventIteratorToProtoTranscomEventIterator(rawIter);

    await db.query("BEGIN;");

    const tablename = "tmp_transcom_events";

    const sql = pgFormat(
      `
        CREATE TEMPORARY TABLE IF NOT EXISTS %I (
          LIKE _transcom_admin.transcom_events
            INCLUDING DEFAULTS
            EXCLUDING CONSTRAINTS
        ) ON COMMIT DROP ;
      `,
      tablename
    );

    await db.query(sql);

    const {
      rows: [{ schemaname }],
    } = await db.query(
      `
        SELECT schemaname
          FROM pg_tables
          WHERE tablename = $1
      `,
      [tablename]
    );

    await loadProtoTranscomEventsIntoDatabase(
      protoIter,
      schemaname,
      tablename,
      db
    );

    const {
      rows: [{ num_rows }],
    } = await db.query(
      pgFormat(
        `
          SELECT
              COUNT(1)::SMALLINT AS num_rows
            FROM %I.%I
        `,
        schemaname,
        tablename
      )
    );

    /*
    const { rows } = await db.query(
      pgFormat(
        `
          SELECT
              *
            FROM %I.%I
            LIMIT 1
        `,
        schemaname,
        tablename
      )
    );

    console.log(JSON.stringify({ rows }, null, 4));
    */

    t.equal(
      num_rows,
      NUM_LINES_IN_TEST_FILE,
      "Expected number of rows in database table."
    );

    await db.query("COMMIT;");

    await db.end();
  } catch (err) {
    t.fail(err.message);
  }

  t.end();
});
