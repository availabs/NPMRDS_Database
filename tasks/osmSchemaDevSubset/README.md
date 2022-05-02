# Local Development OSM Database

## Left off

SQL script 14.load_roadway_metadata_table.sql

```txt
* Need to add Routes metadata to the roadway metadata table.

    * For each route name/number
      * get the root route for that name/number (should be own view)
          * get the metadata for that route
              * bearing
              * Note: still need to solve the problem of assigning a direction
                      to a Way that may be a one way street in a bi-directional
                      route. Which of the directions applies to the Way?
                      Cannot use local bearing due to sinuosity.
                      (Consider a road with cutbacks, detours around natural structures.)

* Add network connectivity data.
    * Intersections
    * Street Lights
    * Junctions

* Normalizing Road/Route Names/Numbers
    * Probably best to use JS rather than SQL
    * PL/Python is another option
        * https://www.postgresql.org/docs/current/plpython.html
```

## Load an OSM Subset

```sh
./get_data_subset
./initialize_dev_db
```

## Start the Database

```sh
./startDevDatabase
```

## Connect to the Database

```sh
./connectToDatabase
```

## Run SQL scripts

```sh
npmrds_dev=# \set OSM_VERSION 210101
npmrds_dev=# \cd /sql/create_admin_road_routes_metadata_view/
npmrds_dev=# \i main.sql
```
