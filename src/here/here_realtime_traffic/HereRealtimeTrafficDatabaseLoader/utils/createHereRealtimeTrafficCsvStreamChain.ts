import { Stream } from "stream";
import { createReadStream } from "fs";
import { createGunzip } from "zlib";

import JSONStream from "JSONStream";
import through from "through2";
import { format as csvFormat, CsvFormatterStream } from "fast-csv";
import _ from "lodash";

import hereRealtimeTrafficDatabaseTableColumns from "./hereRealtimeTrafficDatabaseTableColumns";

import {
  HereRealtimeTrafficEntry,
  HereRealtimeTrafficDatabaseRow,
} from "../../types";

export type HereRealtimeTrafficCsvStream = CsvFormatterStream<
  HereRealtimeTrafficDatabaseRow,
  any // comma-separated-list
>;

export function transformHereRealtimeTrafficResponse(
  d: HereRealtimeTrafficEntry
): HereRealtimeTrafficDatabaseRow {
  if (!d.tmc) {
    return null;
  }

  const row = {
    tmc: d.tmc,
    travel_time: d.tt,
    confidence: d.cf,
    speed: d.spd,
    jam_factor: d.jf,
  };

  // Any undefined or empty strings to null
  Object.keys(row).forEach((col) => {
    if (col === "tmc") {
      return;
    }

    if (row[col] === "") {
      row[col] = null;
      return;
    }

    row[col] = +row[col];

    if (Number.isNaN(row[col])) {
      row[col] = null;
    }
  });

  return row;
}

export default function createHereRealtimeTrafficCsvStreamChain(
  hereRealtimeTrafficJsonGzipPath: string
): Stream[] {
  const csvStream = csvFormat({
    headers: hereRealtimeTrafficDatabaseTableColumns,
    quoteHeaders: false,
    quoteColumns: false,
  });

  const gzipReadStream = createReadStream(hereRealtimeTrafficJsonGzipPath);
  const gunzip = createGunzip();

  const parser = JSONStream.parse(".");

  const transformer = through.obj(async function f(
    d: HereRealtimeTrafficEntry,
    _$,
    cb
  ) {
    const row = transformHereRealtimeTrafficResponse(d);
    // console.error(row?.tmc);

    if (!row?.tmc || !Number.isFinite(row?.travel_time)) {
      console.error("empty row");
      return cb();
    }

    // console.error(row.tmc);

    const good = this.push(row);

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

  return [gzipReadStream, gunzip, parser, transformer, csvStream];
}
