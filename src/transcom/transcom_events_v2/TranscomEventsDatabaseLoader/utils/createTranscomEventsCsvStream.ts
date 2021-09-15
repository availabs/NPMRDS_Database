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
  TranscomEventProperties,
  TranscomEventDatabaseRow,
} from "../../types";

export type TranscomEventsCsvStream = CsvFormatterStream<
  TranscomEventDatabaseRow,
  any // comma-separated-list
>;

export function transformEventSchema(
  props: TranscomEventProperties
): TranscomEventDatabaseRow {
  const row = {
    event_id: props.EventID,
    event_state: props.EventState,
    icon_file: props.IconFile,
    event_type: props.EventType,
    facility: props.Facility,
    playback_text: props.PlaybackText,
    latitude: props.Latitude,
    longitude: props.Longitude,
    full_text: props.FullText,
    sort_order: props.SortOrder,
    state: props.State,
    county: props.County,
    event_impact: props.EventImpact,
    relationship: props.Relationship,
    mile_marker: props.MileMarker,
    events_layer: props.EventsLayer,
    last_update_date: props.LastUpdateDate,
    direction: props.Direction,
    notes: props.Notes,
    class_name: props.ClassName,
    image_name: props.ImageName,
    show_route_no: props.ShowRouteNo,
    route_no: props.RouteNo,
    overlap_events_with_length: props.OverlapEventsWithLength,
    last_update_date_string: props.LastUpdateDate_String,
    end_date: props.EndDate,
    end_date_string: props.EndDate_String,
    start_date_time: props.StartDateTime,
    category_name: props.CategoryName,
    is_latest_event: props.IsLatestEvent,
    is_highway: props.IsHighway,
    to_latitude: props.ToLatitude,
    to_longitude: props.ToLongitude,
    event_msg: props.EventMsg,
    to_state: props.ToState,
    to_city: props.ToCity,
    to_facility: props.ToFacility,
    to_direction: props.ToDirection,
    is_overlapping: props.IsOverlapping,

    event_category:
      (props.EventType &&
        eventTypes2Categories[props.EventType.toLowerCase()]) ||
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
  transcomEventsGeoJsonlGzipPath: string
): TranscomEventsCsvStream {
  const csvStream = csvFormat({
    headers: transcomEventsDatabaseTableColumns,
    quoteHeaders: false,
    quoteColumns: true,
  });

  return pipeline(
    createReadStream(transcomEventsGeoJsonlGzipPath),
    createGunzip(),
    split(JSON.parse),
    through.obj(function f(transcomEvent: TranscomEvent, _$, cb) {
      const { properties } = transcomEvent;

      this.push(transformEventSchema(properties));

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
