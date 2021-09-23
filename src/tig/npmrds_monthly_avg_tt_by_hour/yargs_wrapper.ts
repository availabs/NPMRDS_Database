import NpmrdsMonthlyAvgTravelTimesLoader from "./NpmrdsMonthlyAvgTravelTimesLoader";

const command = "download_transcom_historical_events";

const builder = {
  pg_env: {
    desc: "PostgreSQL environment. Only required if start_timestamp is not provided.",
    type: "string",
    demand: false,
    choices: ["production", "development"],
    describe:
      "The database used to check for the latest transcom_historical_events timestamp.",
    default: "development",
  },
};

const handler = async (argv: { pg_env: "development" | "production" }) => {
  const loader = new NpmrdsMonthlyAvgTravelTimesLoader(argv.pg_env);

  loader.run();
};

export const loadMissingNpmrdsMonthlyAvgTravelTimes = {
  desc: "Create and load missing NPMRDS monthly avg travel times tables.",
  command,
  builder,
  handler,
};
