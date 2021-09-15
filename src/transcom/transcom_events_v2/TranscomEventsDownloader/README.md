# TranscomEventsDownloader

## Usage

```sh
./run --help
```

## Convert download GeoJSONL GZIP file to GeoPackage

Note: Requires ogr2ogr version >= 2.4

```sh
ogr2ogr \
  -F GPKG \
  transcom.gpkg \
  /vsigzip/20210914T120000-20210914T140242.20210914T140245.geojsonl.gz \
  -nln transcom_events
```

See: ogr2ogr [manual](https://gdal.org/drivers/vector/geojsonseq.html)
