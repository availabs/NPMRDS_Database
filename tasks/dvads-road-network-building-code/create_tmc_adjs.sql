--DROP TABLE IF EXISTS tmc_adjs_dest;
CREATE VIEW tmc_120p11204_child as (

WITH baseverts AS (
WITH ibase AS(
SELECT distinct shp.source, shp.target
	FROM public."npmrds_shapefile_2016Q2" AS shp
	JOIN public."npmrds_tmc_lut_2016Q2" AS lut USING (link_id)
	WHERE lut.tmc='120P11204'
)
 SELECT ibase.source from ibase
 UNION
 SELECT ibase.target from ibase
)

SELECT '120P11204', term.tmc as child--, CAST( ST_MULTI(ST_UNION(array_agg(shp.wkb_geometry))) as geometry(MultiLineString,4326) )
  FROM public.tmc_terminals as terms
  LEFT JOIN public.tmc_origins as origin USING (tmc)
  WHERE origin is NULL and terms.id in baseverts
  

  
  WHERE term.tmc <> lut.tmc and term.id = origin.origin
  GROUP BY lut.tmc, term.tmc
);