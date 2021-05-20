# NYS Roadway Inventory System Processing and Analysis Toolkit

The NYS RIS comes in various formats with various schemas.
This causes problems for the multiple AVAIL projects depend on this dataset.

This repository is intended to centralize the processing,
  versioning, standardizing, and analysis the RIS dataset,
  thus providing cross-project consistency and
  simplified data provenance archiving.

## Building OSGeo with FileGDB support

### Resources

* [ESRI File Geodatabase (FileGDB)](https://gdal.org/drivers/vector/filegdb.html)
* [ESRI File Geodatabase (OpenFileGDB)](https://gdal.org/drivers/vector/openfilegdb.html)
* [GDAL Docker images](https://github.com/OSGeo/gdal/tree/master/gdal/docker)
  * [Docker/ubuntu-full: Add support for FileGDB and MDB drivers](https://github.com/OSGeo/gdal/pull/2974)
* [How to deal with GCC >= 5.1 C++11 ABI on Linux](https://trac.osgeo.org/gdal/wiki/FileGDB#HowtodealwithGCC5.1C11ABIonLinux)
* [ESRI File Geodatabase API 1.4](https://appsforms.esri.com/products/download/#File_Geodatabase_API_1.4)
