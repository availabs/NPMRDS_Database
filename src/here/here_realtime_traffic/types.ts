export type PGEnv = "development" | "production";
export type HereRealtimeTrafficDataDir = "string";

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

export type HereRealtimeTrafficRequestTimestamp = Date;
export type HereRealtimeTrafficJsonGzipPath = string;

// Data representing either successful or unsuccessful API request.
//   If successful, hereRealtimeTrafficJsonGzipPath is not null.
export type HereRealtimeTrafficDownloaderResponseMetadata = {
  hereRealtimeTrafficRequestTimestamp: HereRealtimeTrafficRequestTimestamp;
  hereRealtimeTrafficJsonGzipPath: HereRealtimeTrafficJsonGzipPath | null;
};

export type HereRealtimeTrafficDownloadTimeObj = {
  year: string;
  month: string;
  day: string;
  hour: string;
  minute: string;
  second: string;
};
