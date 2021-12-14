# 2020 Transposed Truck AADT Patch

RITIS TMC_Identification.csv seemed to has transposed the aadt_singl and aadt_combi columns.

Before patching

```sql
-- nj as-is are closer in value
npmrds_production=# select count(1) from nj.tmc_metadata_2019 as a inner join nj.tmc_metadata_2020 as b using (tmc) where (abs(a.aadt_singl - b.aadt_singl) + abs(a.aadt_combi - b.aadt_combi)) < (abs(a.aadt_singl - b.aadt_combi) + abs(a.aadt_combi - b.aadt_singl));
;
 count
-------
    64
(1 row)

-- nj transposed are closer in value
npmrds_production=# select count(1) from nj.tmc_metadata_2019 as a inner join nj.tmc_metadata_2020 as b using (tmc) where (abs(a.aadt_singl - b.aadt_singl) + abs(a.aadt_combi - b.aadt_combi)) > (abs(a.aadt_singl - b.aadt_combi) + abs(a.aadt_combi - b.aadt_singl));
;
 count
-------
  9267
(1 row)

-- ny as-is are closer in value
npmrds_production=# select count(1) from ny.tmc_metadata_2019 as a inner join ny.tmc_metadata_2020 as b using (tmc) where (abs(a.aadt_singl - b.aadt_singl) + abs(a.aadt_combi - b.aadt_combi)) < (abs(a.aadt_singl - b.aadt_combi) + abs(a.aadt_combi - b.aadt_singl));
;
 count
-------
   232
(1 row)

-- ny transposed are closer in value
npmrds_production=# select count(1) from ny.tmc_metadata_2019 as a inner join ny.tmc_metadata_2020 as b using (tmc) where (abs(a.aadt_singl - b.aadt_singl) + abs(a.aadt_combi - b.aadt_combi)) > (abs(a.aadt_singl - b.aadt_combi) + abs(a.aadt_combi - b.aadt_singl));
;
 count
-------
 19704
(1 row)
```
