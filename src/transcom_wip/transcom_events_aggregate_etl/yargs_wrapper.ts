import { cliArgsSpec as pgCliArgsSpec } from "../../utils/PostgreSQL";

import TranscomEventsAggregateEtlControl from "./TranscomEventsAggregateEtlControl";

const builder = {
  start_timestamp: Object.assign({
    desc: "Start timestamp for Transcom Events.",
    demand: false,
    type: "string",
    describe:
      "If not provided, the latest timestamp in the transcom_historical_events table is used.",
  }),

  end_timestamp: {
    desc: "End timestamp for Transcom Events.",
    demand: false,
    type: "string",
    describe: "If not provided, the current time is used.",
  },

  ...pgCliArgsSpec,
};

export const runTranscomEventsAggregateETL = {
  desc: "Load the TRANSCOM Events and perform and integrate into the database tables.",
  command: "run_transcom_events_aggregate_etl",
  builder,
  async handler({ pg_env, start_timestamp = null, end_timestamp = null }) {
    const control = new TranscomEventsAggregateEtlControl(
      pg_env,
      start_timestamp,
      end_timestamp
    );

    await control.run();
  },
};
