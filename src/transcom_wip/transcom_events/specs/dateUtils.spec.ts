/* eslint-disable no-restricted-syntax */

import test from "tape";

import * as datesUtils from "../../utils/dates";

test("datesUtils getTranscomRequestFormattedTimestamp", (t) => {
  const date = new Date("2022-05-17T17:30:15");
  const transcomTstamp = datesUtils.getTranscomRequestFormattedTimestamp(date);

  // Date format 'YYYY-MM-DD HH:MI:SS'
  t.match(transcomTstamp, /^2022-05-17 17:30:15$/);
  t.end();
});
