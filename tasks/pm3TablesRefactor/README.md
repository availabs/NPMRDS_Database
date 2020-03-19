# PM3 Database Tables Design

## Supporting versions of each Measure

Measures support multiple configuation options.
It is not plausible to serialize the options into an encoded measure name.

The number of measures and potential configuations should be expected
to grow as AVAIL moves further into modeling. 

The database design must therefore be able to support this.
The calculator can run configurable measure variations,
but they are inaccessible to the API server and client.
Only authoritative cananonical runs
are accessible to the API server and, thus, the client.

Measures must be queryable by their configuation metadata

For example:
* peak period definitions
  * e.g.: PHED PM Peak as 3pm-7pm or 4pm-8pm
* time_bin_size
  * { 5, 15, 60 } minute
* traffic distribution time bin size
  * { 5, 15, 60 } minute
* NPMRDS data year
* pm3 calculator run 
  * run id
  * timestamp
    * Calculator source code state
    * NPMRDS Data version (RITIS changes underlying data)
      * What version of the NPMRDS Data was used?
* geography level
  * To declare a measure run as the authoritative, canonical, run for a state,
    we must guarantee that all of that state's TMCs were included in the run.
  * Because of the large number of possible configuration combinations,
    it seems preferable to offer measure runs for geographic levels smaller than
    an entire state.
* tmc_metadata version
  * TMC metadata is versioned, and it is a dependency of the calculator.
* is_canonical
  * A special set of config options
    * For LOTTR, TTTR, and PHED the canonical are the OCR 43 specs
* is_authoritative
  * Admins declare a measure run as the sole authoritative version for a configuration
  * Calculator MUST have been run for an entire state.
  * Not only does this need to be queryable, we MUST enforce the rule
    of one authoritative version of a measure per configuration.
    Database constraints enforce this constraint at the database level.
* Conflation version
* Previously discussed potential future calculation configurations:
  * outlier filtering percentiles
  * traffic modeling simulations
    * which will certainly include their own large variety of options

This full set of queryable options will be available to the API server, and thus the client,
  to support client-side measure selection.

## Metadata-Queryable Measures Implementation

The configuration metadata of a measure can be quite large.

Including this metadata in each calculator output table, for each row,
  greatly slows down any query by increasing the number of disk accesses
  required to read the result set of the query.

By keeping the measure calculation metadata in one table,
  and the per-TMC calculation output in another table
  partitioned by the measure calculation id,
  the measures remain queryable by configuration options
  and the response time remains fast.

## TMC Metadata and RIS Metadata

Measure calculations and the associated TMC/RIS Metadata must remain coupled
  based on the calculator run.

Trying to set an authoritative metadata version across calculator runs would
* make become an admin brain-teaser
* inevitably result in human error
* result in inconsistent attribute/calculation pairings
  would become a logic puzzle. Also, consistency of attribure calculation.
  Also, provenance.

Examples:
  * TMC Metadata based measure derivatives
    * *per_mile* measure variants
  * TMC Metadata Measure Components
    * PHED average_vehicle_occupancy
    * PHED congestion level

## Flattening out the EAV

EAV resulted in multiple rows per TMC.

One row per TMC allows PRIMARY KEY index,
  and INDEX based JOINs.

Will allow us to get rid of the pivot table disaster in the client,
  which is MASSIVE tech debt.

## Partitioning and JOINS

Can't use JOINs to reduce the number of tables scanned.
