## Dependencies

```
sudo apt-get install unzip p7zip-full
```

---

## Download NPMRDS Shapefiles from RITIS

### Example 1: USA shapefile for conflation year 2017
```
COUNTRY=usa YEAR=2017 make etl/download-and-partition-npmrds-shapefile
```

Produces tar file `etl/USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445.tar` with the following structure:
```
$ tar tf etl/USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445.tar
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/DOWNLOAD_TIMESTAMP
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/USA.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/ma.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/hi.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/va.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/or.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/ms.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/wv.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/az.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/ky.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/ga.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/al.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/nd.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/dc.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/wa.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/tx.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/fl.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/me.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/nj.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/mo.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/wi.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/ut.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/mi.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/ks.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/tn.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/vt.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/ne.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/nm.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/co.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/ar.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/ny.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/de.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/md.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/ak.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/ca.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/oh.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/il.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/ia.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/in.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/mt.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/mn.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/id.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/wy.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/ok.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/sd.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/sc.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/ct.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/pa.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/ri.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/nc.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/la.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/nv.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/pr.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/states/nh.zip
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/COUNTRY
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/NPMRDS_SHAPEFILE_VERSION
USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445/USA/2017/CONFLATION_YEAR
```

NOTE: In the above example, `20171108` is the `DBF_DATE_LAST_UPDATE` value in the downloaded shapefile. If RITIS updates the US's shapefile for conflation year 2017, that value will reflect the update.

To archive on RIT storage:
```
scp etl/USA_conflationYear2017_shpVersion20171108_downloadTS20190204T202445.tar avail@lor.availabs.org:/mnt/RIT.samba/BACKUPS/INRIX-NPMRDS/inrix_shapefile
```

### Example 2: Canada shapefile for conflation year 2018
```
COUNTRY=canada YEAR=2018 make etl/download-and-partition-npmrds-shapefile
```

Produces tar file `etl/CANADA_conflationYear2018_shpVersion20181011_downloadTS20190204T202224.tar` with the following structure:
```
$ tar tf etl/CANADA_conflationYear2018_shpVersion20181011_downloadTS20190204T202224.tar
CANADA_conflationYear2018_shpVersion20181011_downloadTS20190204T202224/
CANADA_conflationYear2018_shpVersion20181011_downloadTS20190204T202224/CANADA/
CANADA_conflationYear2018_shpVersion20181011_downloadTS20190204T202224/CANADA/2018/
CANADA_conflationYear2018_shpVersion20181011_downloadTS20190204T202224/CANADA/2018/DOWNLOAD_TIMESTAMP
CANADA_conflationYear2018_shpVersion20181011_downloadTS20190204T202224/CANADA/2018/states/
CANADA_conflationYear2018_shpVersion20181011_downloadTS20190204T202224/CANADA/2018/states/cn.zip
CANADA_conflationYear2018_shpVersion20181011_downloadTS20190204T202224/CANADA/2018/COUNTRY
CANADA_conflationYear2018_shpVersion20181011_downloadTS20190204T202224/CANADA/2018/NPMRDS_SHAPEFILE_VERSION
CANADA_conflationYear2018_shpVersion20181011_downloadTS20190204T202224/CANADA/2018/Canada.zip
CANADA_conflationYear2018_shpVersion20181011_downloadTS20190204T202224/CANADA/2018/CONFLATION_YEAR
```

NOTE: In the above example, `20181011` is the `DBF_DATE_LAST_UPDATE` value in the downloaded shapefile. If RITIS updates the Canada's shapefile for conflation year 2018, that value will reflect the update.

To archive on RIT storage:
```
scp etl/CANADA_conflationYear2018_shpVersion20181011_downloadTS20190204T202224.tar avail@lor.availabs.org:/mnt/RIT.samba/BACKUPS/INRIX-NPMRDS/inrix_shapefile
```

---

## Load a state NPMRDS shapefile into the database

### Example 1: NY shapefile for conflation year 2017 into the production database.
```
PG_ENV=production STATE=ny TAR_ARCHIVE_PATH=./etl/USA_conflationYear2017_shpVersion20171108_downloadTS20190205T002219.tar make db/upload-state-npmrds-shapefile-from-country-tar.sh
```

NOTE: To use the above make target, the tar archive must be the output of the `etl/download-and-partition-npmrds-shapefile` make target. To load other shapefiles, see the [upload-npmrds-shapefile-for-state-year.sh](make_targets/db/upload-npmrds-shapefile-for-state-year.sh) script. In the above make target example, an intermediary script extracts information from the tar archive, sets environment variables, then calls upload-npmrds-shapefile-for-state-year.sh.

---

## Create and load the tmc_metadata table

```
PG_ENV=production STATE=ny YEAR=2018 make db/load-state-year-tmc-metadata
```

NOTE: After the above make target completes, you must manually set the new *tmc_metadata* table as the default. The following code is an example of this process.

```
BEGIN;
alter table ny.tmc_metadata_2018_shpver20181011_v20190206215514 no inherit ny.tmc_metadata_2018;
alter table ny.tmc_metadata_2018_shpver20181011_v20190206235438 inherit ny.tmc_metadata_2018;
COMMIT;
```

---

## Create mapbox tileset from npmrds_shapefile

```
PG_ENV=production YEAR=2018 make mapbox/create-tileset-for-year
```

The above created a file named *tmc_metadata_2018_shpver20181011_20190207T011826.mbtiles*

NOTE: This code is not finished. See [make_targets/mapbox/create-tileset-for-year.sh](make_targets/mapbox/create-tileset-for-year.sh) for the current tippecanoe configuration.

