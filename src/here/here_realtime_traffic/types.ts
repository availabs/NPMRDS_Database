export type PGEnv = "development" | "production";

export type TranscomEventID = string;

export type TranscomEventTimestamp = string; // "MM/DD/YYYY hh:mm:ss aa"

export type HereRealtimeTrafficEntry = {
  tmc: string;
  tt: number;
  cf?: number;
  spd?: number;
  state?: string;
  jf?: number | string;
};

// We want the TranscomEventDatabaseRow to have null if a property is undefined.
type Complete<T> = {
  [P in keyof Required<T>]: T[P];
};

type HereRealtimeTrafficEntryComplete = Complete<HereRealtimeTrafficEntry>;

export type HereRealtimeTrafficDatabaseRow = {
  tmc: HereRealtimeTrafficEntryComplete["tmc"];
  travel_time: HereRealtimeTrafficEntryComplete["tt"];
  confidence: HereRealtimeTrafficEntryComplete["cf"] | null;
  speed: HereRealtimeTrafficEntryComplete["spd"] | null;
  jam_factor: HereRealtimeTrafficEntryComplete["jf"] | null;
};
