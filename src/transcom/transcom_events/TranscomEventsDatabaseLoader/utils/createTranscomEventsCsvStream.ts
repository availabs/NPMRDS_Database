import { pipeline } from "stream";
import { createReadStream } from "fs";

import { createGunzip } from "zlib";
import through from "through2";
import split from "split2";
import { format as csvFormat, CsvFormatterStream } from "fast-csv";
import _ from "lodash";

import eventTypes2Categories from "./eventTypes2Categories";
import transcomEventsDatabaseTableColumns from "./transcomEventsDatabaseTableColumns";

import {
  TranscomEvent,
  TranscomEventCategory,
  TranscomEventDatabaseRow,
} from "../../types";

export type TranscomEventsCsvStream = CsvFormatterStream<
  TranscomEventDatabaseRow,
  any // comma-separated-list
>;

export function transformEventSchema(
  e: TranscomEvent
): TranscomEventDatabaseRow {
  const row = {
    event_id: e.id,
    event_type: e.eventType,
    facility: e.facility,
    creation: e.startDateTime,
    open_time: e.lastUpdate,
    close_time: e.manualCloseDate,
    duration: e.eventDuration,
    description: e.summaryDescription,
    from_city: e.FromCity,
    from_count: e.county,
    to_city: e.ToCity,
    state: e.state,
    from_mile_marker: e.PrimaryMarker,
    to_mile_marker: e.secondaryMarker,
    latitude: e.pointLAT,
    longitude: e.pointLON,
    direction: e.direction,
    recovery_time: e.RecoveryTimeInFormate,
    recovery_date_time: e.recoverydatetime,

    event_category:
      (e.eventType && eventTypes2Categories[e.eventType.toLowerCase()]) ||
      TranscomEventCategory.OTHER,
  };

  console.log("==> event_id", row.event_id);

  // Any undefined or empty strings to null
  Object.keys(row).forEach((col) => {
    if (row[col] === undefined || row[col] === "") {
      row[col] = null;
    }
  });

  return row;
}

export default function createTranscomEventsCsvStream(
  transcomEventsNdjsonGzipPath: string
): TranscomEventsCsvStream {
  const csvStream = csvFormat({
    headers: transcomEventsDatabaseTableColumns,
    quoteHeaders: false,
    quoteColumns: true,
  });

  const gzipReadStream = createReadStream(transcomEventsNdjsonGzipPath);

  const transformer = through.obj(async function f(
    transcomEvent: TranscomEvent,
    _$,
    cb
  ) {
    const good = this.push(transformEventSchema(transcomEvent));

    if (!good) {
      gzipReadStream.pause();
      csvStream.once("drain", () => {
        gzipReadStream.resume();
        cb();
      });
    } else {
      cb();
    }
  });

  return pipeline(
    gzipReadStream,
    createGunzip(),
    split(JSON.parse),
    transformer,
    csvStream,
    (err) => {
      if (err) {
        throw err;
      }
    }
  );
}
