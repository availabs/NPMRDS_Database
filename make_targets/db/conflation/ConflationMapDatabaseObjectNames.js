const conflationSchema = 'conflation';
const conflationMapTablePrefix = 'conflation_map_v'

const getConflationSchema = () => conflationSchema;

const validateConflationMapVersion = conflationMapVersion => {
  // Note: Separator can be either '.' or '_'
  //       E.G.: Both 1.2.3 and 1_2_3 will pass validation
  if (!/^\d{1,}[._]\d{1,}[._]\d{1,}$/.test(conflationMapVersion)) {
    throw new Error(
      'ERROR: conflationMapVersion should be of the format x.y.z'
    );
  }
};

// Cannot use '.' in PostgreSQL table names (without quoting table names).
const getConflationMapTableVersionSuffix = conflationMapVersion =>
  conflationMapVersion.replace(/\./g, '_');

const getConflationMapTableName = conflationMapVersion =>
  `${conflationMapTablePrefix}${getConflationMapTableVersionSuffix(conflationMapVersion)}`;

const getConflationMapTableFullName = conflationMapVersion =>
  `${getConflationSchema()}.${getConflationMapTableName(conflationMapVersion)}`;

const getConflationMapTablePrimaryKeyIdxName = conflationMapVersion =>
  `${getConflationMapTableName(conflationMapVersion)}_pkey`;

const getConflationMapToTranscomEventsTableName = conflationMapVersion =>
  `${getConflationMapTableName(
    conflationMapVersion
  )}_to_transcom_historical_events`;

const getConflationMapToTranscomEventsTableFullName = conflationMapVersion =>
  `${getConflationSchema()}.${getConflationMapToTranscomEventsTableName(
    conflationMapVersion
  )}`;

const getConflationMapToTranscomEventsTablePrimaryKeyIdxName = conflationMapVersion =>
  `${getConflationMapToTranscomEventsTableName(conflationMapVersion)}_pkey`;

class ConflationMapDatabaseObjectNames {
  constructor(conflationMapVersion) {
    validateConflationMapVersion(conflationMapVersion);

    this.conflationMapVersion = conflationMapVersion;
  }

  get conflationMapTableVersionSuffix() {
    return getConflationMapTableVersionSuffix(this.conflationMapVersion);
  }

  get conflationMapTableName() {
    return getConflationMapTableName(this.conflationMapVersion);
  }

  get conflationMapTableFullName() {
    return getConflationMapTableFullName(this.conflationMapVersion);
  }

  get conflationMapTablePrimaryKeyIdxName() {
    return getConflationMapTablePrimaryKeyIdxName(this.conflationMapVersion);
  }

  get conflationMapToTranscomEventsTableName() {
    return getConflationMapToTranscomEventsTableName(this.conflationMapVersion);
  }

  get conflationMapToTranscomEventsTableFullName() {
    return getConflationMapToTranscomEventsTableFullName(
      this.conflationMapVersion
    );
  }

  get conflationMapToTranscomEventsTablePrimaryKeyIdxName() {
    return getConflationMapToTranscomEventsTablePrimaryKeyIdxName(
      this.conflationMapVersion
    );
  }
}

ConflationMapDatabaseObjectNames.conflationSchema = conflationSchema
ConflationMapDatabaseObjectNames.conflationMapTablePrefix = conflationMapTablePrefix

module.exports = ConflationMapDatabaseObjectNames;
