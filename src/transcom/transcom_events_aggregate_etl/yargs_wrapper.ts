import { cliArgsSpec as pgCliArgsSpec } from "../../utils/PostgreSQL";

import TranscomEventsAggregateEtlController from "./TranscomEventsAggregateEtlController";
import TranscomEventsAggregateUpdateController from "./TranscomEventsAggregateUpdateController";
import TranscomEventsAggregateNightlyUpdateController from "./TranscomEventsAggregateNightlyUpdateController";

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

export const load = {
  desc: "Load the TRANSCOM Events and integrate into the database tables.",
  command: "transcom_events_aggregate_load",
  builder,
  async handler({ pg_env, start_timestamp = null, end_timestamp = null }) {
    const control = new TranscomEventsAggregateEtlController(
      pg_env,
      start_timestamp,
      end_timestamp
    );

    try {
      await control.run();
    } catch (err) {
      console.error(err);
    }
  },
};

export const update = {
  desc: "Update the TRANSCOM Events and integrate into the database tables.",
  command: "transcom_events_aggregate_update",
  builder,
  async handler({ pg_env, start_timestamp = null, end_timestamp = null }) {
    const control = new TranscomEventsAggregateUpdateController(
      pg_env,
      start_timestamp,
      end_timestamp
    );

    try {
      await control.run();
    } catch (err) {
      console.error(err);
    }
  },
};

export const nightly = {
  desc: "Nighly update the TRANSCOM Events and integrate into the database tables.",
  command: "transcom_events_aggregate_nightly_update",
  builder: pgCliArgsSpec,
  async handler({ pg_env }) {
    const control = new TranscomEventsAggregateNightlyUpdateController(pg_env);

    try {
      await control.run();
    } catch (err) {
      console.error(err);
    }
  },
};
