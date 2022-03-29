// const getConflationMapToTranscomEventsTableName = conflationMapVersion =>
//   `${getConflationMapTableName(
//     conflationMapVersion
//   )}_to_transcom_historical_events`;
//
// const getConflationMapToTranscomEventsTableFullName = conflationMapVersion =>
//   `${getConflationSchema()}.${getConflationMapToTranscomEventsTableName(
//     conflationMapVersion
//   )}`;
//
// const getConflationMapToTranscomEventsTablePrimaryKeyIdxName = conflationMapVersion =>
//   `${getConflationMapToTranscomEventsTableName(conflationMapVersion)}_pkey`;

class ConflationMapDatabaseObjectNames {
  // Cannot use '.' in PostgreSQL table names (without quoting table names).
  static validateConflationMapVersion(conflationMapVersion) {
    // Note: Separator can be either '.' or '_'
    //       E.G.: Both 1.2.3 and 1_2_3 will pass validation
    if (!/^\d{1,}[._]\d{1,}[._]\d{1,}$/.test(conflationMapVersion)) {
      throw new Error(
        "ERROR: conflationMapVersion should be of the format x.y.z"
      );
    }
  }

  constructor(year, conflationMapVersion) {
    ConflationMapDatabaseObjectNames.validateConflationMapVersion(
      conflationMapVersion
    );

    this.conflationSchema = "conflation";

    this.year = year;
    this.conflationMapVersion = conflationMapVersion;
  }

  get conflationMapTableVersionSuffix() {
    return this.conflationMapVersion.replace(/\./g, "_");
  }

  get conflationMapTableName() {
    return `conflation_map_${this.year}_v${
      this.conflationMapTableVersionSuffix
    }`;
  }

  get conflationMapTableFullName() {
    return `${this.conflationSchema}.${this.conflationMapTableName}`;
  }

  get conflationMapTablePrimaryKeyIdxName() {
    return `${this.conflationMapTableName}_pkey`;
  }

  get conflationMapTablePrimaryKeyIdxFullName() {
    return `${this.conflationSchema}.${
      this.conflationMapTablePrimaryKeyIdxName
    }`;
  }

  get conflationMapTableOsmIdxName() {
    return `${this.conflationMapTableName}_osm_idx`;
  }

  get conflationMapTableRisIdxName() {
    return `${this.conflationMapTableName}_ris_idx`;
  }

  get conflationMapTableTmcIdxName() {
    return `${this.conflationMapTableName}_tmc_idx`;
  }

  get conflationMapTableGeometryIdxName() {
    return `${this.conflationMapTableName}_gix`;
  }

  // get conflationMapToTranscomEventsTableName() {
  //   return getConflationMapToTranscomEventsTableName(this.conflationMapVersion);
  // }

  // get conflationMapToTranscomEventsTableFullName() {
  //   return getConflationMapToTranscomEventsTableFullName(
  //     this.conflationMapVersion
  //   );
  // }

  // get conflationMapToTranscomEventsTablePrimaryKeyIdxName() {
  //   return getConflationMapToTranscomEventsTablePrimaryKeyIdxName(
  //     this.conflationMapVersion
  //   );
  // }
}

module.exports = ConflationMapDatabaseObjectNames;
