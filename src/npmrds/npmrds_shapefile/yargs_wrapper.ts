import { execSync } from "child_process";
import { join } from "path";

const builder = {
  state: {
    desc: "The state whose tmc_date_ranges to refresh.",
    type: "string",
    demand: true,
  },

  year: {
    desc: "The shapefile year.",
    type: "number",
    demand: true,
  },

  shp_zip_path: {
    desc: "The path to the NPMRDS shapefile ZIP archive.",
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

export const load = {
  desc: "Upload a NPMRDS shapefile ZIP archive.",
  command: "upload-zipped-npmrds-shapefile",
  builder,
  handler({ state, year, shp_zip_path, pg_env }) {
    const scriptPath = join(__dirname, "./upload-zipped-npmrds-shapefile");

    execSync(scriptPath, {
      cwd: process.cwd(),
      env: {
        ...process.env,
        STATE: state,
        YEAR: year,
        SHP_ZIP_PATH: shp_zip_path,
        PG_ENV: pg_env,
      },
      encoding: "utf8",
    });
  },
};
