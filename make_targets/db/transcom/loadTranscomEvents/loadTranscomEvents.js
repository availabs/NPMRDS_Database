#!/usr/bin/env node

// Need to create a TEMP table when loading with a COPY FROM stream
//   to handle PRIMARY KEY conflicts
// https://stackoverflow.com/a/13949654/3970755

const { pipe } = require('mississippi');
const copyFrom = require('pg-copy-streams').from;

const tableColumns = require('./tableColumns');

const createTempTable = (client, tmpTableName) =>
  client.query(`
    BEGIN;
    DROP TABLE IF EXISTS ${tmpTableName};

    -- CREATE TEMP TABLE ${tmpTableName} (
    --   LIKE transcom.transcom_historical_events
    -- ) ;

    CREATE TEMP TABLE ${tmpTableName}
      AS
        SELECT *
          FROM transcom.transcom_historical_events
          WITH NO DATA;


    COMMIT;
  `);

const populateTempTable = (client, tmpTableName, transcomEventsCsvStream) =>
  new Promise((resolve, reject) => {
    const pgCopyStream = client.query(
      copyFrom(
        `COPY ${tmpTableName} (${tableColumns})
          FROM STDIN WITH (
            FORMAT CSV,
            HEADER,
            DELIMITER (','),
            FORCE_NULL(
              'event_type',
              'facility',
              'creation',
              'open_time',
              'close_time',
              'duration',
              'description',
              'from_city',
              'from_count',
              'to_city',
              'state',
              'from_mile_marker',
              'to_mile_marker',
              'latitude',
              'longitude',
              'event_category',
              'point_geom'
            )
          );`
      )
    );

    pipe(
      transcomEventsCsvStream,
      pgCopyStream,
      err => {
        if (err) {
          return reject(err);
        }
        return resolve();
      }
    );
  });

const setPointGeomInTmpTable = (client, tmpTableName) =>
  client.query(`
      UPDATE ${tmpTableName}
        SET point_geom = ST_MakePoint(longitude, latitude)::geography::geometry
    `);

const copyFromTempIntoTransconEventTable = (client, tmpTableName) =>
  client.query(`
    INSERT INTO transcom.transcom_historical_events
      SELECT DISTINCT ON (event_id) *
          FROM ${tmpTableName}
      ON CONFLICT ON CONSTRAINT transcom_historical_events_pkey DO UPDATE
        SET
          event_id = EXCLUDED.event_id,
          event_type = EXCLUDED.event_type,
          facility = EXCLUDED.facility,
          creation = EXCLUDED.creation,
          open_time = EXCLUDED.open_time,
          close_time = EXCLUDED.close_time,
          duration = EXCLUDED.duration,
          description = EXCLUDED.description,
          from_city = EXCLUDED.from_city,
          from_count = EXCLUDED.from_count,
          to_city = EXCLUDED.to_city,
          state = EXCLUDED.state,
          from_mile_marker = EXCLUDED.from_mile_marker,
          to_mile_marker = EXCLUDED.to_mile_marker,
          latitude = EXCLUDED.latitude,
          longitude = EXCLUDED.longitude,
          event_category = EXCLUDED.event_category,
          point_geom = EXCLUDED.point_geom 
    ;
  `);

const dropTempTable = (client, tmpTableName) =>
  client.query(`DROP TABLE IF EXISTS ${tmpTableName};`);

const finishUp = client =>
  client.query('VACUUM ANALYZE transcom.transcom_historical_events;');

const loadTranscomEvents = async (client, transcomEventsCsvStream) => {
  const tmpTableName = `tmp_transcom_${new Date().getTime()}`;
  try {
    await createTempTable(client, tmpTableName);
    await populateTempTable(client, tmpTableName, transcomEventsCsvStream);
    await setPointGeomInTmpTable(client, tmpTableName);
    await copyFromTempIntoTransconEventTable(client, tmpTableName);
    await finishUp(client);
  } catch (err) {
    console.error(err);
    throw err;
  } finally {
    await dropTempTable(client, tmpTableName);
  }
};

module.exports = loadTranscomEvents;
