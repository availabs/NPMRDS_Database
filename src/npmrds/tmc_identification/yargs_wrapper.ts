import main from "./load-tmc-identification-file";

const builder = {
  npmrds_export_sqlite_db_path: {
    desc: "The NPMRDS TravelTimes Export SQLite database created by the NPMRDS data downloader.",
    type: "string",
    demand: true,
  },

  pg_env: {
    desc: "The database into which to load data.",
    type: "string",
    demand: false,
    choices: ["production", "development"],
    default: "development",
  },
};

export const loadTmcIdentification = {
  desc: "Load the NPMRDS TMC_Identification data from the downloader-created SQLite DB.",
  command: "load_tmc_identification",
  builder,
  async handler({ npmrds_export_sqlite_db_path, pg_env }) {
    await main({ npmrds_export_sqlite_db_path, pg_env });
  },
};
