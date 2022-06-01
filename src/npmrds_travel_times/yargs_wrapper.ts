import main from "./load-npmrds-state-yrmo";

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

export const loadNpmrdsExport = {
  desc: "Load the NPMRDS travel times data from the downloader-created SQLite DB.",
  command: "load_npmrds_export",
  builder,
  async handler({ npmrds_export_sqlite_db_path, pg_env }) {
    await main({ npmrds_export_sqlite_db_path, pg_env });
  },
};
