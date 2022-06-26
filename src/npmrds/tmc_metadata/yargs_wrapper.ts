import main from "./load-state-year-tmc-metadata";

const builder = {
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
    desc: "The database.",
    type: "string",
    demand: false,
    choices: ["production", "development"],
    default: "development",
  },
};

export const loadStateYearTmcMetadata = {
  desc: "Load a new version of the state/year tmc_metadata table.",
  command: "load_tmc_metadata",
  builder,
  handler({ state, year, pg_env }) {
    main(state, year, pg_env);
  },
};
