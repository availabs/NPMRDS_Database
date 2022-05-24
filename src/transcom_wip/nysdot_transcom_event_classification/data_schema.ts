import _ from "lodash";

export const csvColsToDbCols = {
  event_type: "event_type",
  "Display in Incident Dashboard": "display_in_incident_dashboard",
  "General Category": "general_category",
  SubCategory: "sub_category",
  "Detailed Category": "detailed_category",
  "WAZE Category": "waze_category",
  "Display if Lane Closure": "display_if_lane_closure",
  "Duration Accurate": "duration_accurate",
};

const caseInsensistiveCsvColsToDbCols = _.mapKeys(
  csvColsToDbCols,
  (_v: any, k: string) => k.toLowerCase()
);

export const dbColsToCsvCols = _.invert(csvColsToDbCols);

export const dbCols = Object.keys(dbColsToCsvCols);

export function csvColToDbColMapper(cols: string[]) {
  let unsupportedCols = 0;
  const includedDbCols = cols.map((col) => {
    const c = col.trim().toLowerCase();

    const dbCol = caseInsensistiveCsvColsToDbCols[c];

    if (!dbCol) {
      return `_unsupported_${++unsupportedCols}_`;
    }

    return dbCol;
  });

  const missingDbCols = _.difference(dbCols, includedDbCols);

  if (missingDbCols.length > 0) {
    const missingCsvCols = missingDbCols.map((c) => dbColsToCsvCols[c]);

    throw new Error(
      `The following required columns are missing from the CSV: ${missingCsvCols}`
    );
  }

  return includedDbCols;
}
