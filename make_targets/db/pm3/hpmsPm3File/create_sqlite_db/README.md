# Create a SQLite Database for the HPMS PM3 CSVs

```sh
rm -f hpms_pm3.FHWA-2021-1_2_1.sqlite3
cat ../FHWA_2021-1.2.1.ny.20220418T133607.csv | ./create_database FHWA-2021-1_2_1
cat ../FHWA_2021-1.2.1.nj.20220418T134329.csv | ./create_database FHWA-2021-1_2_1
```
