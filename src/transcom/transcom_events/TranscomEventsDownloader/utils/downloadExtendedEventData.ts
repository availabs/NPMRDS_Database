import got from "got";

import _ from "lodash";

const TRANSCOM_URL =
  "https://eventsearch.xcmdata.org/HistoricalEventSearch/xcmEvent/getEventById";

export default async function downloadExtendedEventData(
  transcomEventIds: string[]
) {
  const url = `${TRANSCOM_URL}?id=${transcomEventIds.join("&id=")}`;

  const { data } = await got.get(url).json();

  return data;
}
