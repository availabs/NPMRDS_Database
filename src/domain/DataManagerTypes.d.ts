export interface SourceMetadata {
  name: string;
  update_interval?: string | null;
  category?: string[] | null;
  description?: string | null;
  statistics?: string[] | null;
  metadata?: Record | null;
}

export type SourceMetadataPartial = Partial<SourceMetadata>;

export type DataManagerDataType = "TABULAR" | "SPATIAL";

export interface ViewMetadata {
  source_id: integer;
  data_type?: DataManagerDataType | null;
  interval_version: string;
  geography_version?: string | null;
  version: string | integer;
  source_url?: string | null;
  publisher?: string | null;
  data_table?: string | null;
  download_url?: string | null;
  tiles_url?: string | null;
  start_date?: Date | null;
  end_date?: Date | null;
  last_updated?: string | null;
  statistics?: Record | null;
  metadata?: Record | null;
}

export type ViewMetadataPartial = Partial<ViewMetadata>;

export type StateAbbreviation = string;
export type Year = number;
export type TimestampString = string;

export enum PreviousVersionComparisonResult {
  INITIAL_VERSION = "INITIAL_VERSION",
  UNCHANGED = "UNCHANGED",
  SCHEMA_CHANGED = "SCHEMA_CHANGED",
  DATA_CHANGED = "DATA_CHANGED",
}
