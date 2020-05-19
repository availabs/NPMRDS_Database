1. Put the zip archive in base_data_weekly and extract it.

```
$ ll base_data_weekly 
total 44K
drwxr-xr-x 2 paul paul 4.0K Apr 30 11:11 Class_Data_Selected_Sites_032620
drwxr-xr-x 2 paul paul 4.0K Apr 30 11:11 Class_Data_Selected_Sites_033020
drwxr-xr-x 2 paul paul 4.0K Apr 30 11:11 Class_Data_Selected_Sites_040220
drwxr-xr-x 2 paul paul 4.0K Apr 30 11:11 Class_Data_Selected_Sites_040920
drwxr-xr-x 2 paul paul 4.0K Apr 30 11:11 Class_Data_Selected_Sites_041320
drwxr-xr-x 2 paul paul 4.0K Apr 30 11:11 Class_Data_Selected_Sites_042320
drwxr-xr-x 2 paul paul 4.0K Apr 30 11:47 Class_Data_Selected_Sites_043020
drwxr-xr-x 2 paul paul 4.0K May 14 13:29 Class_Data_Selected_Sites_050420
drwxr-xr-x 2 paul paul 4.0K May 14 13:29 Class_Data_Selected_Sites_050720
drwxr-xr-x 2 paul paul 4.0K May 14 13:29 Class_Data_Selected_Sites_051120
drwxr-xr-x 2 paul paul 4.0K May 14 13:29 Class_Data_Selected_Sites_051420

$ tree base_data_weekly/Class_Data_Selected_Sites_032620 
base_data_weekly/Class_Data_Selected_Sites_032620
├── 020011.extended
├── CAD_020011_03012020.CSV
├── CAD_150578_03012020.CSV
├── CAD_180395_03012020.CSV
├── CAD_410131_03012020.CSV
├── CAD_520076_03012020.CSV
├── CAD_630001_03012020.CSV
├── CAD_730041_03012020.CSV
├── CAD_840008_03012020.CSV
├── CAD_910108_03012020.CSV
├── Class_Data_Selected_Sites_032620.zip
├── Field Definitions_SC Formats.pdf
└── Freight_Samples_Locations.xlsx

0 directories, 13 files
```

2. Load the data

```
./load_weekly_veh_class
```
