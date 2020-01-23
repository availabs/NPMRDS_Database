const ConflationMapDatabaseObjectNames = require('./ConflationMapDatabaseObjectNames');

const getCreateConflationMapToTranscomEventsTableStmnt = conflationMapVersion => {
  const {
    conflationMapToTranscomEventsTableFullName
  } = new ConflationMapDatabaseObjectNames(conflationMapVersion);

  // NOTE: This MUST be idempotent.
  return `
    -- create the join table for this conflation map version
    CREATE TABLE IF NOT EXISTS ${conflationMapToTranscomEventsTableFullName} (
      event_id           TEXT PRIMARY KEY,
      conflation_map_id  INTEGER
    ) WITH (fillfactor=100) ; `;
};

module.exports = getCreateConflationMapToTranscomEventsTableStmnt;
