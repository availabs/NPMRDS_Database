export type PGEnv = "development" | "production";

export type TranscomEventID = string;

export type TranscomEventTimestamp = string; // "MM/DD/YYYY hh:mm:ss aa"

export enum TranscomEventCategory {
  ACCIDENT = "accident",
  CONSTRUCTION = "construction",
  OTHER = "other",
}

export enum TransomEventDirection {
  ALL_DIRECTIONS = "all directions",
  BOTH_DIRECTIONS = "both directions",
  EASTBOUND = "eastbound",
  NEGATIVE_DIRECTION = "negative direction",
  NORTHBOUND = "northbound",
  NOT_DIRECTIONAL = "not directional",
  POSITIVE_DIRECTION = "positive direction",
  SOUTHBOUND = "southbound",
  UNKNOWN = "unknown",
  WESTBOUND = "westbound",
}

export enum TranscomEventStatus {
  CLOSED = "Closed",
  "NEW" = "New",
  "UPDATED" = "Updated",
}

export type TranscomEvent = {
  id: string;

  facility?: string;
  eventType?: "Other";
  summaryDescription?: string;
  state?: string;
  county?: string;
  city?: string;
  lastUpdate?: TranscomEventTimestamp;
  eventDuration?: string;
  startDateTime?: TranscomEventTimestamp;
  manualCloseDate?: TranscomEventTimestamp;

  linkCount?: number;
  ToCity?: string;

  pointLAT?: number;
  pointLON?: number;

  PrimaryMarker?: number;
  secondaryMarker?: number;
  FromCity?: string;
  eventTypeDescId?: number;
  eventCategory?: string;
  reportingOrgId?: number;

  direction?: TransomEventDirection | null;
  eventstatus?: string;
  year?: number;
  dataSource?: "Y" | null;
  dataSourceValue?: string; // Always null in the data seen so far.
  tmclist?: string;
  recoverytime?: number;
  RecoveryTimeInFormate?: string;
  recoverydatetime?: TranscomEventTimestamp;

  isHighway?: number;
};

// We want the TranscomEventDatabaseRow to have null if a property is undefined.
type Complete<T> = {
  [P in keyof Required<T>]: T[P];
};

type TranscomEventComplete = Complete<TranscomEvent>;

export type TranscomEventDatabaseRow = {
  event_id: TranscomEventComplete["id"];
  event_type: TranscomEventComplete["eventType"] | null;
  facility: TranscomEventComplete["facility"] | null;
  creation: TranscomEventComplete["startDateTime"] | null;
  open_time: TranscomEventComplete["lastUpdate"] | null;
  close_time: TranscomEventComplete["manualCloseDate"] | null;
  duration: TranscomEventComplete["eventDuration"] | null;
  description: TranscomEventComplete["summaryDescription"] | null;
  from_city: TranscomEventComplete["FromCity"] | null;
  from_count: TranscomEventComplete["county"] | null;
  to_city: TranscomEventComplete["ToCity"] | null;
  state: TranscomEventComplete["state"] | null;
  from_mile_marker: TranscomEventComplete["PrimaryMarker"] | null;
  to_mile_marker: TranscomEventComplete["secondaryMarker"] | null;
  latitude: TranscomEventComplete["pointLAT"] | null;
  longitude: TranscomEventComplete["pointLON"] | null;
  direction: TranscomEventComplete["direction"] | null;
  recovery_time: TranscomEventComplete["RecoveryTimeInFormate"] | null;
  recovery_date_time: TranscomEventComplete["recoverydatetime"] | null;
  event_category: TranscomEventCategory;
};
