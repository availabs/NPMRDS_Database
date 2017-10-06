https://developer.here.com/documentation/routing/topics/resource-type-private-transport-link.html

> SpeedLimit	
> Legal speed limit in m/s (based on link only, unrelated to vehicle type). Contains the following reserved values:
> 
> 999: indicates that there is no speed restriction for link
> 998:
> United States: marked on ramps as from/toward reference speed limit
> Europe: marked on ramps as from/toward reference speed limit, if no posted speed limit or motorway symbol exists
> 0: no speed limit available, value will be hidden in the response.SpeedLimit


## Scraped Speedlimits Storage Structure

Scraped data is stored by state/county/tmc.

Within each tmc's file, there is the response from here.
  It may contain a list of links.

This structure allows us to re-scrape without repeating requests for those TMCs where we have data.
