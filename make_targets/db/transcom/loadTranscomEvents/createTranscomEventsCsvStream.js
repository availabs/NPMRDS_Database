#!/usr/bin/env node

/* eslint no-console: 0 */

const { createReadStream } = require('fs');

const { createGunzip } = require('zlib');
const { pipe, through } = require('mississippi');
const split = require('split2');
const csv = require('fast-csv');

const tableColumns = require('./tableColumns');
const eventTypes2Categories = require('./eventTypes2Categories');

const transformEventSchema = transcomEvent => ({
  event_id: transcomEvent.id,
  event_type: transcomEvent.eventType,
  facility: transcomEvent.facility,
  creation: transcomEvent.startDateTime,
  open_time: transcomEvent.lastUpdate,
  close_time: transcomEvent.manualCloseDate,
  duration: transcomEvent.eventDuration,
  description: transcomEvent.summaryDescription,
  from_city: transcomEvent.FromCity,
  from_count: transcomEvent.county,
  to_city: transcomEvent.ToCity,
  state: transcomEvent.state,
  from_mile_marker: transcomEvent.PrimaryMarker,
  to_mile_marker: transcomEvent.secondaryMarker,
  latitude: transcomEvent.pointLAT,
  longitude: transcomEvent.pointLON,
  event_category:
    eventTypes2Categories[transcomEvent.eventType.toLowerCase()] || 'other',
  point_geom: ''
});

const createTranscomEventsCsvStream = transcomEventsNdjsonGzipPath => {
  const csvStream = csv.format({
    headers: tableColumns,
    quoteHeaders: false,
    quoteColumns: true
  });

  pipe(
    createReadStream(transcomEventsNdjsonGzipPath),
    createGunzip(),
    split(JSON.parse),
    through.obj(function f(transcomEvent, $, cb) {
      this.push(transformEventSchema(transcomEvent));

      cb();
    }),
    csvStream
  );

  return csvStream;
};

module.exports = createTranscomEventsCsvStream;
