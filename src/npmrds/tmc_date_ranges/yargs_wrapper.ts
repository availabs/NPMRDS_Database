import main from "./refresh_tmc_date_ranges";

const builder = {
  state: {
    desc: "The state whose tmc_date_ranges to refresh.",
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

export const refreshStateTMCDateRangeTable = {
  desc: "Refresh the TMC date ranges for the specified state.",
  command: "refresh_state_tmc_date_ranges",
  builder,
  handler({ state, pg_env }) {
    main(state, pg_env);
  },
};
