# Transcom Event Categories

NOTE: The default eventCategoryIds requested in the
[Transcom Historical Event Search Tool](https://xcmdfe.xcmdata.org/SSO/#!/home/app/HistoricalEventSearch)
are 1, 2, 3, 4, and 13. We replicate that request in the TranscomEventsDownloader.

The following API calls show the descriptions

```sh
$ curl \
    --silent \
    'https://eventsearch2.xcmdata.org/HistoricalEventSearch/xcmEvent/getEventCategory?eventClass=Highway' \
  | jq
{
  "data": [
    {
      "ID": 1,
      "Description": "Highway Incident",
      "DisplayOrder": 1
    },
    {
      "ID": 13,
      "Description": "Highway Weather Related",
      "DisplayOrder": 2
    },
    {
      "ID": 4,
      "Description": "Highway Congestion",
      "DisplayOrder": 3
    },
    {
      "ID": 2,
      "Description": "Active Highway Construction",
      "DisplayOrder": 4
    },
    {
      "ID": 3,
      "Description": "Active Highway Special Events",
      "DisplayOrder": 5
    },
    {
      "ID": 5,
      "Description": "Scheduled Highway Construction",
      "DisplayOrder": 6
    },
    {
      "ID": 6,
      "Description": "Scheduled Highway Special Event",
      "DisplayOrder": 7
    }
  ],
  "success": true
}
```

```sh
$ curl \
    --silent \
    'https://eventsearch2.xcmdata.org/HistoricalEventSearch/xcmEvent/getEventCategory?eventClass=Transit' \
  | jq
{
  "data": [
    {
      "ID": 7,
      "Description": "Transit Incident",
      "DisplayOrder": 1
    },
    {
      "ID": 14,
      "Description": "Transit Weather Related",
      "DisplayOrder": 2
    },
    {
      "ID": 10,
      "Description": "Transit Congestion",
      "DisplayOrder": 3
    },
    {
      "ID": 8,
      "Description": "Active Transit Construction",
      "DisplayOrder": 4
    },
    {
      "ID": 9,
      "Description": "Active Transit Special Events",
      "DisplayOrder": 5
    },
    {
      "ID": 11,
      "Description": "Scheduled Transit Construction",
      "DisplayOrder": 6
    },
    {
      "ID": 12,
      "Description": "Scheduled Transit Special Event",
      "DisplayOrder": 7
    }
  ],
  "success": true
}
```
