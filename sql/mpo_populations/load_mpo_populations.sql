BEGIN;

INSERT INTO us.mpo_populations (
  mpo_name,
  mpo_acrony,
  state,
  major_city,
  area,
  population,
  designation_year
) VALUES 
  ('Adirondack/Glens Falls Transportation Council','A/GFTC','NY','Glens Falls',1818,143664,1982),
  ('Binghamton Metropolitan Transportation Study','BMTS','NY','Binghamton',770,222338,1974),
  ('Capital District Transportation Committee','CDTC','NY','Albany',2204,823239,1973),
  ('Dutchess County Transportation Council','DCTC','NY','Poughkeepsie',824,297508,1982),
  ('Elmira-Chemung Transportation Council','ECTC','NY','Elmira',410,88831,1975),
  ('Genesee Transportation Council','GTC','NY','Rochester',1312,878672,1977),
  ('Greater Buffalo-Niagara Regional Transportation Council','GBNRTC','NY','Buffalo',1576,1135511,1974),
  ('Herkimer-Oneida Counties Transportation Study','HOCTS','NY','Utica',2710,299541,1972),
  ('Ithaca-Tompkins County Transportation Council','ITCTC','NY','Ithaca',491,101566,1992),
  ('New York Metropolitan Transportation Council','NYMTC','NY','New York',2726,12367508,1982),
  ('Orange County Transportation Council','OCTC','NY','Goshen',837,372815,1982),
  ('Syracuse Metropolitan Transportation Council','SMTC','NY','Syracuse',820,476845,1965),
  ('Ulster County Transportation Council','UCTC','NY','Kingston',1159,182491,2003),
  ('Watertown-Jefferson County Transportation Council',NULL,'NY',NULL,125,66322,2014)
;

COMMIT;
