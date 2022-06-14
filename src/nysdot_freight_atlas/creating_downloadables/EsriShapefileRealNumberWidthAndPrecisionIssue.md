# Esri Shapefile Real Number Width And Precision Issue

## Warning 1: Value ... of field ... of feature ... not successfully written

TL;DR: Doesn't seem to be a real issue.

Got similar messages to the following for multiple NYSDOT FREIGHT_ATLAS layers while
dumping the database tables to ESRI Shapefile format:

```console
Warning 1: Value 118144714.537324995 of field shape_area of feature 1691 not successfully written.
Possibly due to too larger number with respect to field width
```

Specifically, for these (layer,fields):

```json
{"layer":"border_states","fields":["shape_area"]}
{"layer":"canada","fields":["shape_area"]}
{"layer":"cities_pop_over_20k_anno","fields":["shape_area"]}
{"layer":"city_town","fields":["shape_area"]}
{"layer":"county","fields":["aland","awater"]}
{"layer":"highway_corridors","fields":["origid"]}
{"layer":"highway_trans_2012","fields":["e_trkvalue","n_trkvalue","s_trkvalue","trktons","truckvalue","w_trkvalue"]}
{"layer":"highway_trans_2040","fields":["e_40_tv","e_trkvl","n_40_tv","n_trkvl","s_40_tv","s_trkvl","truckvl","w_40_tv","w_trkvl"]}
{"layer":"interstate_anno_4","fields":["shape_area"]}
{"layer":"interstate","fields":["origid"]}
{"layer":"major_ports","fields":["total"]}
{"layer":"mpo_boundaries","fields":["shape_area"]}
{"layer":"nhd24kwb_a_ny","fields":["shape_area"]}
{"layer":"nhpn","fields":["origid"]}
{"layer":"nhs","fields":["origid"]}
{"layer":"ntad_2014_ny_area","fields":["origid"]}
{"layer":"nys_canal_system","fields":["shape_area"]}
{"layer":"nysdot_regions","fields":["aland","awater"]}
{"layer":"pop_20k_cities_resize","fields":["shape_area"]}
{"layer":"primary_freight_network","fields":["origid"]}
{"layer":"select_cities_pop_over_20k","fields":["shape_area"]}
{"layer":"state","fields":["shape_area"]}
```

This is a known issue with the ogr2ogr ESRI Shapefile driver. See:

- [r-spatial/sf ISSUE: Misleading warning #306](https://github.com/r-spatial/sf/issues/306#issuecomment-296431138)
- [ogr2ogr complains possibly due to too larger number](https://trac.osgeo.org/gdal/ticket/6803)

The same error messages occurred when creating an ESRI Shapefile directly from the
original GeoDatabase submitted by NYSDOT. _It is not an issue of using the PostgreSQL
database as an intermediary._

## PostgreSQL/PostGIS

- [S.O.](https://gis.stackexchange.com/a/191846)
- [ogr2ogr PostgreSQL / PostGIS Layer Creation Options](https://gdal.org/drivers/vector/pg.html#layer-creation-options)
- [ogr2ogr -unsetFieldWidth](https://gdal.org/programs/ogr2ogr.html#cmdoption-ogr2ogr-unsetFieldWidth)

Notice that the width/precision of City_Town SHAPE_Area is (0.0):

```console
$ ogrinfo -so Map_Data.gdb City_Town
INFO: Open of `Map_Data.gdb'
      using driver `OpenFileGDB' successful.

Layer name: City_Town
Geometry: Multi Polygon
Feature Count: 994
Extent: (105571.420678, 4480951.235681) - (779932.062662, 4985476.422251)
Layer SRS WKT:
PROJCS["NAD83 / UTM zone 18N",
    GEOGCS["NAD83",
        DATUM["North_American_Datum_1983",
            SPHEROID["GRS 1980",6378137,298.257222101,
                AUTHORITY["EPSG","7019"]],
            TOWGS84[0,0,0,0,0,0,0],
            AUTHORITY["EPSG","6269"]],
        PRIMEM["Greenwich",0,
            AUTHORITY["EPSG","8901"]],
        UNIT["degree",0.0174532925199433,
            AUTHORITY["EPSG","9122"]],
        AUTHORITY["EPSG","4269"]],
    PROJECTION["Transverse_Mercator"],
    PARAMETER["latitude_of_origin",0],
    PARAMETER["central_meridian",-75],
    PARAMETER["scale_factor",0.9996],
    PARAMETER["false_easting",500000],
    PARAMETER["false_northing",0],
    UNIT["metre",1,
        AUTHORITY["EPSG","9001"]],
    AXIS["Easting",EAST],
    AXIS["Northing",NORTH],
    AUTHORITY["EPSG","26918"]]
FID Column = OBJECTID
Geometry Column = SHAPE
NAME: String (40.0)
MUNI_TYPE: String (4.0)
GNIS_ID: String (9.0)
POP1990: Integer (0.0)
POP2000: Integer (0.0)
POP2010: Integer (0.0)
DOS_LL: String (7.0)
DOS_LL_DATE: DateTime (0.0)
MAP_SYMBOL: String (1.0)
DATEMOD: DateTime (0.0)
SHAPE_Length: Real (0.0)
SHAPE_Area: Real (0.0)
```

This means that the ogr2ogr PostgreSQL/PostGIS driver will use a default of data type
of FLOAT8 [double precision](https://www.postgresql.org/docs/11/datatype-numeric.html).

```console
npmrds_production=# \d nysdot_freight_atlas.city_town_v2016
                                                Table "nysdot_freight_atlas.city_town_v2016"
    Column    |            Type
--------------+-----------------------------
 objectid     | integer
 name         | character varying(40)
 muni_type    | character varying(4)
 gnis_id      | character varying(9)
 pop1990      | integer
 pop2000      | integer
 pop2010      | integer
 dos_ll       | character varying(7)
 dos_ll_date  | timestamp with time zone
 map_symbol   | character varying(1)
 datemod      | timestamp with time zone
 shape_length | double precision
 shape_area   | double precision
 wkb_geometry | geometry(MultiPolygon,4326)
```

And the ogr2ogr 'ESRI Shapefile' driver will use the
[default](https://gdal.org/drivers/vector/shapefile.html#creation-issues)
width of 24 and precision of 15.

```sh
$ ogrinfo -so city_town city_town
INFO: Open of `city_town'
      using driver `ESRI Shapefile' successful.

Layer name: city_town
Metadata:
  DBF_DATE_LAST_UPDATE=2022-06-14
Geometry: Polygon
Feature Count: 994
Extent: (105571.420678, 4480951.235681) - (779932.062662, 4985476.422251)
Layer SRS WKT:
PROJCS["NAD83 / UTM zone 18N",
    GEOGCS["NAD83",
        DATUM["North_American_Datum_1983",
            SPHEROID["GRS 1980",6378137,298.257222101,
                AUTHORITY["EPSG","7019"]],
            TOWGS84[0,0,0,0,0,0,0],
            AUTHORITY["EPSG","6269"]],
        PRIMEM["Greenwich",0,
            AUTHORITY["EPSG","8901"]],
        UNIT["degree",0.0174532925199433,
            AUTHORITY["EPSG","9122"]],
        AUTHORITY["EPSG","4269"]],
    PROJECTION["Transverse_Mercator"],
    PARAMETER["latitude_of_origin",0],
    PARAMETER["central_meridian",-75],
    PARAMETER["scale_factor",0.9996],
    PARAMETER["false_easting",500000],
    PARAMETER["false_northing",0],
    UNIT["metre",1,
        AUTHORITY["EPSG","9001"]],
    AXIS["Easting",EAST],
    AXIS["Northing",NORTH],
    AUTHORITY["EPSG","26918"]]
NAME: String (40.0)
MUNI_TYPE: String (4.0)
GNIS_ID: String (9.0)
POP1990: Integer (9.0)
POP2000: Integer (9.0)
POP2010: Integer (9.0)
DOS_LL: String (7.0)
DOS_LL_DAT: Date (10.0)
MAP_SYMBOL: String (1.0)
DATEMOD: Date (10.0)
SHAPE_Leng: Real (24.15)
SHAPE_Area: Real (24.15)
```

## Non-Issue?

Note: Map_Data.gdb is the original GeoDatabase submitted by NYSDOT.

When creating and 'ESRI Shapefile' of the City_Town layer in the original GeoDatabase,
the following warning was logged to the console:

```sh
$ ogr2ogr -F 'ESRI Shapefile' city_town  Map_Data.gdb city_town
...
Warning 1: Value 113200159.508792341 of field SHAPE_Area of feature 993 not successfully written. Possibly due to too larger number with respect to field width
```

```sh
$ ogr2ogr -F CSV /vsistdout/  city_town -dialect 'sqlite' -sql "SELECT gnis_id, shape_area FROM city_town WHERE cast(shape_area as text) LIKE '113200159.50%' "
GNIS_ID,SHAPE_Area
"979079",113200159.508792
```

```sh
$ ogr2ogr -F CSV /vsistdout/  Map_Data.gdb -dialect 'sqlite' -sql "SELECT gnis_id, shape_area FROM city_town WHERE cast(shape_area as text) LIKE '113200159.50%' "
GNIS_ID,SHAPE_Area
"979079",113200159.508792
```

## Future Work

If we wanted to dig deeper, we could use the NDJSON above to

- for each problematic layer
  - for both the original NSYDOT submitted GeoDatabase and the downloadable ESRI Shapefile
    - use the NDJSON above to create CSVs with only the problematic columns
    - diff those CSVs
