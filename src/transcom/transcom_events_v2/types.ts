import * as turf from "@turf/turf";

export type PGEnv = "development" | "production";

export type TranscomEventID = string;
export type TranscomEventTimestamp = string;

export enum TranscomEventCategory {
  ACCIDENT = "accident",
  CONSTRUCTION = "construction",
  OTHER = "other",
}

export type TranscomEventProperties = {
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

export interface TranscomEvent extends turf.Feature<turf.Point> {
  properties: TranscomEventProperties;
}

export type TranscomEventDatabaseRow = {
  event_id: TranscomEventProperties["EventID"];
  event_state: TranscomEventProperties["EventState"] | null;
  icon_file: TranscomEventProperties["IconFile"] | null;
  event_type: TranscomEventProperties["EventType"] | null;
  facility: TranscomEventProperties["Facility"] | null;
  playback_text: TranscomEventProperties["PlaybackText"] | null;
  latitude: TranscomEventProperties["Latitude"] | null;
  longitude: TranscomEventProperties["Longitude"] | null;
  full_text: TranscomEventProperties["FullText"] | null;
  sort_order: TranscomEventProperties["SortOrder"] | null;
  state: TranscomEventProperties["State"] | null;
  county: TranscomEventProperties["County"] | null;
  event_impact: TranscomEventProperties["EventImpact"] | null;
  relationship: TranscomEventProperties["Relationship"] | null;
  mile_marker: TranscomEventProperties["MileMarker"] | null;
  events_layer: TranscomEventProperties["EventsLayer"] | null;
  last_update_date: TranscomEventProperties["LastUpdateDate"] | null;
  direction: TranscomEventProperties["Direction"] | null;
  notes: TranscomEventProperties["Notes"] | null;
  class_name: TranscomEventProperties["ClassName"] | null;
  image_name: TranscomEventProperties["ImageName"] | null;
  show_route_no: TranscomEventProperties["ShowRouteNo"] | null;
  route_no: TranscomEventProperties["RouteNo"] | null;
  overlap_events_with_length:
    | TranscomEventProperties["OverlapEventsWithLength"]
    | null;
  last_update_date_string:
    | TranscomEventProperties["LastUpdateDate_String"]
    | null;
  end_date: TranscomEventProperties["EndDate"] | null;
  end_date_string: TranscomEventProperties["EndDate_String"] | null;
  start_date_time: TranscomEventProperties["StartDateTime"] | null;
  category_name: TranscomEventProperties["CategoryName"] | null;
  is_latest_event: TranscomEventProperties["IsLatestEvent"] | null;
  is_highway: TranscomEventProperties["IsHighway"] | null;
  to_latitude: TranscomEventProperties["ToLatitude"] | null;
  to_longitude: TranscomEventProperties["ToLongitude"] | null;
  event_msg: TranscomEventProperties["EventMsg"] | null;
  to_state: TranscomEventProperties["ToState"] | null;
  to_city: TranscomEventProperties["ToCity"] | null;
  to_facility: TranscomEventProperties["ToFacility"] | null;
  to_direction: TranscomEventProperties["ToDirection"] | null;
  is_overlapping: TranscomEventProperties["IsOverlapping"] | null;

  event_category: TranscomEventCategory;
};
