export type NysdotTranscomEventClassification = {
  event_type: TranscomEventType;
  display_in_incident_dashboard: boolean | null;
  general_category: string | null;
  sub_category: string | null;
  detailed_category: string | null;
  waze_category: string | null;
  display_if_lane_closure: boolean | null;
  duration_accurate: string | null;
};
