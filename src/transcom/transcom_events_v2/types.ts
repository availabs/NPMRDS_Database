export type PGEnv = "development" | "production";

export type TranscomEventID = string;
export type TranscomEventTimestamp = string;

export enum TranscomEventCategory {
  ACCIDENT = "accident",
  CONSTRUCTION = "construction",
  OTHER = "other",
}

export type TranscomEvent = {
  EventID: TranscomEventID;
  EventState: number;
  IconFile: string;
  EventType: string;
  Facility: string;
  PlaybackText: string;
  Latitude: number;
  Longitude: number;
  FullText: string;
  SortOrder: number;
  State: string;
  County: string;
  EventImpact: string;
  Relationship: string;
  MileMarker: string;
  EventsLayer: string;
  LastUpdateDate: TranscomEventTimestamp;
  Direction: string;
  Notes: string;
  ClassName: string;
  ImageName: string;
  ShowRouteNo: number;
  RouteNo: string;
  OverlapEventsWithLength: string;
  LastUpdateDate_String: TranscomEventTimestamp;
  EndDate: null;
  EndDate_String: string;
  StartDateTime: TranscomEventTimestamp;
  CategoryName: string;
  IsLatestEvent: boolean;
  IsHighway: boolean;
  ToLatitude: number;
  ToLongitude: number;
  EventMsg: string | null;
  ToState: string;
  ToCity: string;
  ToFacility: string;
  ToDirection: string;
  IsOverlapping: number;
};

export type TranscomEventDatabaseRow = {
  event_id: TranscomEvent["EventID"];
  event_state: TranscomEvent["EventState"] | null;
  icon_file: TranscomEvent["IconFile"] | null;
  event_type: TranscomEvent["EventType"] | null;
  facility: TranscomEvent["Facility"] | null;
  playback_text: TranscomEvent["PlaybackText"] | null;
  latitude: TranscomEvent["Latitude"] | null;
  longitude: TranscomEvent["Longitude"] | null;
  full_text: TranscomEvent["FullText"] | null;
  sort_order: TranscomEvent["SortOrder"] | null;
  state: TranscomEvent["State"] | null;
  county: TranscomEvent["County"] | null;
  event_impact: TranscomEvent["EventImpact"] | null;
  relationship: TranscomEvent["Relationship"] | null;
  mile_marker: TranscomEvent["MileMarker"] | null;
  events_layer: TranscomEvent["EventsLayer"] | null;
  last_update_date: TranscomEvent["LastUpdateDate"] | null;
  direction: TranscomEvent["Direction"] | null;
  notes: TranscomEvent["Notes"] | null;
  class_name: TranscomEvent["ClassName"] | null;
  image_name: TranscomEvent["ImageName"] | null;
  show_route_no: TranscomEvent["ShowRouteNo"] | null;
  route_no: TranscomEvent["RouteNo"] | null;
  overlap_events_with_length: TranscomEvent["OverlapEventsWithLength"] | null;
  last_update_date_string: TranscomEvent["LastUpdateDate_String"] | null;
  end_date: TranscomEvent["EndDate"] | null;
  end_date_string: TranscomEvent["EndDate_String"] | null;
  start_date_time: TranscomEvent["StartDateTime"] | null;
  category_name: TranscomEvent["CategoryName"] | null;
  is_latest_event: TranscomEvent["IsLatestEvent"] | null;
  is_highway: TranscomEvent["IsHighway"] | null;
  to_latitude: TranscomEvent["ToLatitude"] | null;
  to_longitude: TranscomEvent["ToLongitude"] | null;
  event_msg: TranscomEvent["EventMsg"] | null;
  to_state: TranscomEvent["ToState"] | null;
  to_city: TranscomEvent["ToCity"] | null;
  to_facility: TranscomEvent["ToFacility"] | null;
  to_direction: TranscomEvent["ToDirection"] | null;
  is_overlapping: TranscomEvent["IsOverlapping"] | null;

  event_category: TranscomEventCategory;
};
