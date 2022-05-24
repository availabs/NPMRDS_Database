/* eslint-disable no-restricted-syntax */

import { join } from "path";
import test from "tape";

import _ from "lodash";
import split from "split2";

import {
  makeNysdotTranscomEventClassificationsIterator,
  nysdotTranscomEventClassifcationsToCsvStream,
} from "..";

import { dbCols } from "../data_schema";

const csvPath = join(
  __dirname,
  "./test_data/transcom_event_types_by_region_2021Categoriesver2.0.csv"
);

const expectedProps = dbCols.slice().sort();

test("makeNysdotTranscomEventClassificationsIterator yields classifictions", async (t) => {
  const iter = makeNysdotTranscomEventClassificationsIterator(csvPath);

  let count = 0;
  let hasExpectedProps = true;
  for await (const event of iter) {
    ++count;

    if (!_.isEqual(Object.keys(event).sort(), expectedProps)) {
      hasExpectedProps = false;
      break;
    }
  }

  t.true(count > 0, "Received TRANSCOM events");
  t.true(hasExpectedProps, "TRANSCOM events have expected properties");

  t.end();
});

test("normalized nysdotTranscomEventClassifcationsStream", async (t) => {
  const iter = makeNysdotTranscomEventClassificationsIterator(csvPath);

  const stream = nysdotTranscomEventClassifcationsToCsvStream(iter).pipe(
    split()
  );

  let count = 0;
  for await (const row of stream) {
    if (!count) {
      t.equal(row, `${dbCols}`, "CSV head === dbCols");
    }

    ++count;
  }

  t.true(count > 2, "Stream has expected number of rows");

  t.end();
});
