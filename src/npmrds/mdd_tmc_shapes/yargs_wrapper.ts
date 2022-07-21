import main from "./load-massive-data-downloader-tmc-shapes";

const builder = {
  tmc_shapes_geojsonl_gzip_path: {
    desc: "The GeoJSONL file.",
    type: "string",
    demand: true,
  },
  state: {
    desc: "The state.",
    type: "string",
    demand: true,
  },
  year: {
    desc: "The year.",
    type: "number",
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

export const loadMDDTmcShapes = {
  desc: "Load the GeoJSONL file of TMC shapes downloaded from the RITIS Massive Data Downloader",
  command: "load_mdd_tmc_shapes",
  builder,
  async handler({ tmc_shapes_geojsonl_gzip_path, state, year, pg_env }) {
    // @ts-ignore
    await main({ tmc_shapes_geojsonl_gzip_path, state, year, pg_env });
  },
};
