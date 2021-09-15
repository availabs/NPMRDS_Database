import { pipeline } from "stream";
import { createReadStream } from "fs";

import { createGunzip } from "zlib";
import through from "through2";
import split from "split2";
import { format as csvFormat, CsvFormatterStream } from "fast-csv";
import _ from "lodash";

import eventTypes2Categories from "./eventTypes2Categories";
import transcomEventsDatabaseTableColumns from "./transcomEventsDatabaseTableColumns";

import { TranscomEvent, TranscomEventDatabaseRow } from "../../types";

export type TranscomEventsCsvStream = CsvFormatterStream<
  TranscomEventDatabaseRow,
  any // comma-separated-list
>;

export function transformEventSchema(
  e: TranscomEvent
): TranscomEventDatabaseRow {
  const row = {
    event_id: e.EventID,
    event_state: e.EventState,
    icon_file: e.IconFile,
    event_type: e.EventType,
    facility: e.Facility,
    playback_text: e.PlaybackText,
    latitude: e.Latitude,
    longitude: e.Longitude,
    full_text: e.FullText,
    sort_order: e.SortOrder,
    state: e.State,
    county: e.County,
    event_impact: e.EventImpact,
    relationship: e.Relationship,
    mile_marker: e.MileMarker,
    events_layer: e.EventsLayer,
    last_update_date: e.LastUpdateDate,
    direction: e.Direction,
    notes: e.Notes,
    class_name: e.ClassName,
    image_name: e.ImageName,
    show_route_no: e.ShowRouteNo,
    route_no: e.RouteNo,
    overlap_events_with_length: e.OverlapEventsWithLength,
    last_update_date_string: e.LastUpdateDate_String,
    end_date: e.EndDate,
    end_date_string: e.EndDate_String,
    start_date_time: e.StartDateTime,
    category_name: e.CategoryName,
    is_latest_event: e.IsLatestEvent,
    is_highway: e.IsHighway,
    to_latitude: e.ToLatitude,
    to_longitude: e.ToLongitude,
    event_msg: e.EventMsg,
    to_state: e.ToState,
    to_city: e.ToCity,
    to_facility: e.ToFacility,
    to_direction: e.ToDirection,
    is_overlapping: e.IsOverlapping,

    event_category:
      (e.EventType && eventTypes2Categories[e.EventType.toLowerCase()]) ||
      "other",
  };

  Object.keys(row).forEach((col) => {
    if (_.isNil(row[col]) || row[col] === "") {
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

  return pipeline(
    createReadStream(transcomEventsNdjsonGzipPath),
    createGunzip(),
    split(JSON.parse),
    through.obj(function f(transcomEvent: TranscomEvent, _$, cb) {
      this.push(transformEventSchema(transcomEvent));

      cb();
    }),
    csvStream,
    (err) => {
      if (err) {
        throw err;
      }
    }
  );
}
