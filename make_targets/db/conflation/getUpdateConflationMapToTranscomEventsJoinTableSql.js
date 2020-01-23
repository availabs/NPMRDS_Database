const ConflationMapDatabaseObjectNames = require('./ConflationMapDatabaseObjectNames');
const getCreateConflationMapToTranscomEventsTableStmnt = require('./getCreateConflationMapToTranscomEventsTableStmnt');

// Creates JOIN table between transcom_historical_events & the provided table
const getUpdateConflationMapToTranscomEventsJoinTableSql = (
  conflationMapVersion,
  clearExisting = false
) => {
  const {
    conflationMapTableFullName,
    conflationMapToTranscomEventsTableFullName,
    conflationMapTableVersionSuffix,
    conflationMapToTranscomEventsTablePrimaryKeyIdxName
  } = new ConflationMapDatabaseObjectNames(conflationMapVersion);

  const tmpBufferedEventTableName = `tmp_buffered_event_pts_${conflationMapTableVersionSuffix}`;
  const geoIdxName = `${tmpBufferedEventTableName}_idx`;

  const createConflationMapToTranscomEventsTableStmnt = getCreateConflationMapToTranscomEventsTableStmnt(
    conflationMapVersion
  );

  const onlyUnmatchedEventsWhereClause = clearExisting
    ? ''
    : `     LEFT OUTER JOIN ${conflationMapToTranscomEventsTableFullName} c
            USING (event_id)
          WHERE ( c.conflation_map_id IS NULL )`;

  const clearExistingConflationMapToTranscomEventsTableStmnt = clearExisting
    ? `DELETE FROM ${conflationMapToTranscomEventsTableFullName} ;`
    : '';

  // NOTE: Caller should have control over transaction start and finish.
  //       Therefore, we cannot issue BEGIN/COMMIT or ANALYZE.
  const sql = `
    -- NOTE: The below DDL MUST be idempotent.
    ${createConflationMapToTranscomEventsTableStmnt}

    CREATE TEMPORARY TABLE ${tmpBufferedEventTableName}
      ON COMMIT DROP
      AS
        SELECT
            event_id,
            point_geom,
            ST_Buffer(GEOGRAPHY(point_geom), 50) AS buffered_pt
          FROM transcom.transcom_historical_events
          ${onlyUnmatchedEventsWhereClause}
    ;

    CREATE INDEX ${geoIdxName}
      ON ${tmpBufferedEventTableName} USING GIST (buffered_pt);

    CLUSTER ${tmpBufferedEventTableName} USING ${geoIdxName};

    ${clearExistingConflationMapToTranscomEventsTableStmnt}

    INSERT INTO ${conflationMapToTranscomEventsTableFullName} (event_id, conflation_map_id)
      SELECT DISTINCT ON (event_id)
          event_id,
          conflation_map_id
        FROM
        (
            SELECT 
                t.event_id,
                c.id AS conflation_map_id,
                ST_Distance(c.wkb_geometry, t.point_geom) AS dist
              FROM ${tmpBufferedEventTableName} AS t
                INNER JOIN ${conflationMapTableFullName} AS c
                ON ( t.buffered_pt && c.wkb_geometry )
              ORDER BY event_id, dist
        ) AS sub ;

    CLUSTER ${conflationMapToTranscomEventsTableFullName}
      USING ${conflationMapToTranscomEventsTablePrimaryKeyIdxName} ;
  `;

  return sql;
};

module.exports = getUpdateConflationMapToTranscomEventsJoinTableSql;
