-- SELECT base, child
--   FROM public.tmc_adjs WHERE base='120N08098';
-- SELECT * from tmc_terminals WHERE tmc='120P11204'
--SELECT distinct tmc, array_agg(dir) FROM "npmrds_tmc_lut_2016Q2" GROUP BY tmc limit 100
CREATE TABLE tmc_origins AS (
WITH dist_table as (
SELECT ST_DISTANCE(
ST_PointFromText(concat('POINT(', to_char(longitude,'999D99999') ,' ', to_char(latitude,'999D99999') ,')'),4326) ,
verts.the_geom) AS d, verts.id, tmc
 from static_file_data 
 JOIN tmc_terminals USING (tmc)
 JOIN "npmrds_shapefile_2016Q2_vertices_pgr" as verts USING (id)
 
 )
 SELECT tmc, id as origin FROM dist_table 
 INNER JOIN ( SELECT min(d) AS min_d, tmc FROM dist_table GROUP BY tmc ) as aggt USING (tmc)
 WHERE aggt.min_d = d

 )