-- From meta table, get tmcs
-- From shapefile, get geom
-- if geom.midPoint in MPO, add that value to meta table
-- finds midpoint:
-- SELECT ST_Asgeojson(geom) :: json -> 'coordinates' as tmcGeom,
-- 	ST_AsGeojson(ST_ClosestPoint(geom, ST_Centroid(geom))) :: json -> 'coordinates' as midPoint
-- from tmc_geom

-- input: 1.table to change: tmc_metadata_2016 2.table to use: npmrds_extended_shapefile_2017

BEGIN;
-- step 1
CREATE TEMPORARY TABLE tmp_tmc_geom 
ON commit drop
as (
SELECT tmc, wkb_geometry as geom
  FROM public.npmrds_extended_shapefile_2019 --change here
);
-- step 2
CREATE TEMPORARY TABLE tmp_mpo_data 
ON commit drop
as (
SELECT *
FROM public.mpo_boundaries
WHERE state = 'NY'
);
-- step 3
CREATE TEMPORARY TABLE tmp_final_mpo_data_2019
ON commit drop
as (
SELECT tmc, mpo_id, mpo_name, geom as tmc_geom
FROM tmp_mpo_data join tmp_tmc_geom
on ST_contains(wkb_geometry, ST_ClosestPoint(geom, ST_Centroid(geom)))
);

-- final
UPDATE tmc_metadata_2019 --change here
SET mpo_code = t.mpo_id,
	mpo_name = t.mpo_name
FROM tmp_final_mpo_data_2019 t --change here
WHERE tmc_metadata_2019.tmc = t.tmc;
commit;