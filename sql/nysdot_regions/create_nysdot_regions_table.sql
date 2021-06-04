/*
  npmrds_production=# select distinct region, region_co, '36' || lpad(fips_co::TEXT, 3, '0'), county_name from road_inventory_system_2019 order by 1,2,3;
   region | region_co | ?column? | county_name
  --------+-----------+----------+-------------
        1 |        11 | 36001    | ALBANY
        1 |        12 | 36031    | ESSEX
        1 |        13 | 36039    | GREENE
        1 |        14 | 36083    | RENSSELAER
        1 |        15 | 36091    | SARATOGA
        1 |        16 | 36093    | SCHENECTADY
        1 |        17 | 36113    | WARREN
        1 |        18 | 36115    | WASHINGTON
        2 |        21 | 36035    | FULTON
        2 |        22 | 36041    | HAMILTON
        2 |        23 | 36043    | HERKIMER
        2 |        24 | 36053    | MADISON
        2 |        25 | 36057    | MONTGOMERY
        2 |        26 | 36065    | ONEIDA
        3 |        31 | 36011    | CAYUGA
        3 |        32 | 36023    | CORTLAND
        3 |        33 | 36067    | ONONDAGA
        3 |        34 | 36075    | OSWEGO
        3 |        35 | 36099    | SENECA
        3 |        36 | 36109    | TOMPKINS
        4 |        41 | 36037    | GENESEE
        4 |        42 | 36051    | LIVINGSTON
        4 |        43 | 36055    | MONROE
        4 |        44 | 36069    | ONTARIO
        4 |        45 | 36073    | ORLEANS
        4 |        46 | 36121    | WYOMING
        4 |        47 | 36117    | WAYNE
        5 |        51 | 36009    | CATTARAUGUS
        5 |        52 | 36013    | CHAUTAUQUA
        5 |        53 | 36029    | ERIE
        5 |        54 | 36063    | NIAGARA
        6 |        61 | 36003    | ALLEGANY
        6 |        62 | 36015    | CHEMUNG
        6 |        63 | 36097    | SCHUYLER
        6 |        64 | 36101    | STEUBEN
        6 |        66 | 36123    | YATES
        7 |        71 | 36019    | CLINTON
        7 |        72 | 36033    | FRANKLIN
        7 |        73 | 36045    | JEFFERSON
        7 |        74 | 36049    | LEWIS
        7 |        75 | 36089    | ST LAWRENCE
        8 |        81 | 36021    | COLUMBIA
        8 |        82 | 36027    | DUTCHESS
        8 |        83 | 36071    | ORANGE
        8 |        84 | 36079    | PUTNAM
        8 |        85 | 36087    | ROCKLAND
        8 |        86 | 36111    | ULSTER
        8 |        87 | 36119    | WESTCHESTER
        9 |        91 | 36007    | BROOME
        9 |        92 | 36017    | CHENANGO
        9 |        93 | 36025    | DELAWARE
        9 |        94 | 36077    | OTSEGO
        9 |        95 | 36095    | SCHOHARIE
        9 |        96 | 36105    | SULLIVAN
        9 |        97 | 36107    | TIOGA
       10 |         3 | 36059    | NASSAU
       10 |         7 | 36103    | SUFFOLK
       11 |         1 | 36005    | BRONX
       11 |         2 | 36047    | KINGS
       11 |         4 | 36061    | NEW YORK
       11 |         5 | 36081    | QUEENS
       11 |         6 | 36085    | RICHMOND
  (62 rows)
*/

BEGIN;

CREATE SCHEMA IF NOT EXISTS ny;

DROP TABLE IF EXISTS ny.nysdot_regions;

CREATE TABLE ny.nysdot_regions (
  region       SMALLINT  NOT  NULL,
  region_co    SMALLINT  NOT  NULL,
  fips_code    TEXT      NOT  NULL,
  county_name  TEXT      NOT  NULL,

  PRIMARY KEY (region, region_co)
) WITH (fillfactor=100, autovacuum_enabled=false);

INSERT INTO ny.nysdot_regions (
  region,
  region_co,
  fips_code,
  county_name
) VALUES
  (  1, 11, '36001', 'ALBANY' ),
  (  1, 12, '36031', 'ESSEX' ),
  (  1, 13, '36039', 'GREENE' ),
  (  1, 14, '36083', 'RENSSELAER' ),
  (  1, 15, '36091', 'SARATOGA' ),
  (  1, 16, '36093', 'SCHENECTADY' ),
  (  1, 17, '36113', 'WARREN' ),
  (  1, 18, '36115', 'WASHINGTON' ),
  (  2, 21, '36035', 'FULTON' ),
  (  2, 22, '36041', 'HAMILTON' ),
  (  2, 23, '36043', 'HERKIMER' ),
  (  2, 24, '36053', 'MADISON' ),
  (  2, 25, '36057', 'MONTGOMERY' ),
  (  2, 26, '36065', 'ONEIDA' ),
  (  3, 31, '36011', 'CAYUGA' ),
  (  3, 32, '36023', 'CORTLAND' ),
  (  3, 33, '36067', 'ONONDAGA' ),
  (  3, 34, '36075', 'OSWEGO' ),
  (  3, 35, '36099', 'SENECA' ),
  (  3, 36, '36109', 'TOMPKINS' ),
  (  4, 41, '36037', 'GENESEE' ),
  (  4, 42, '36051', 'LIVINGSTON' ),
  (  4, 43, '36055', 'MONROE' ),
  (  4, 44, '36069', 'ONTARIO' ),
  (  4, 45, '36073', 'ORLEANS' ),
  (  4, 46, '36121', 'WYOMING' ),
  (  4, 47, '36117', 'WAYNE' ),
  (  5, 51, '36009', 'CATTARAUGUS' ),
  (  5, 52, '36013', 'CHAUTAUQUA' ),
  (  5, 53, '36029', 'ERIE' ),
  (  5, 54, '36063', 'NIAGARA' ),
  (  6, 61, '36003', 'ALLEGANY' ),
  (  6, 62, '36015', 'CHEMUNG' ),
  (  6, 63, '36097', 'SCHUYLER' ),
  (  6, 64, '36101', 'STEUBEN' ),
  (  6, 66, '36123', 'YATES' ),
  (  7, 71, '36019', 'CLINTON' ),
  (  7, 72, '36033', 'FRANKLIN' ),
  (  7, 73, '36045', 'JEFFERSON' ),
  (  7, 74, '36049', 'LEWIS' ),
  (  7, 75, '36089', 'ST LAWRENCE' ),
  (  8, 81, '36021', 'COLUMBIA' ),
  (  8, 82, '36027', 'DUTCHESS' ),
  (  8, 83, '36071', 'ORANGE' ),
  (  8, 84, '36079', 'PUTNAM' ),
  (  8, 85, '36087', 'ROCKLAND' ),
  (  8, 86, '36111', 'ULSTER' ),
  (  8, 87, '36119', 'WESTCHESTER' ),
  (  9, 91, '36007', 'BROOME' ),
  (  9, 92, '36017', 'CHENANGO' ),
  (  9, 93, '36025', 'DELAWARE' ),
  (  9, 94, '36077', 'OTSEGO' ),
  (  9, 95, '36095', 'SCHOHARIE' ),
  (  9, 96, '36105', 'SULLIVAN' ),
  (  9, 97, '36107', 'TIOGA' ),
  ( 10,  3, '36059', 'NASSAU' ),
  ( 10,  7, '36103', 'SUFFOLK' ),
  ( 11,  1, '36005', 'BRONX' ),
  ( 11,  2, '36047', 'KINGS' ),
  ( 11,  4, '36061', 'NEW YORK' ),
  ( 11,  5, '36081', 'QUEENS' ),
  ( 11,  6, '36085', 'RICHMOND' )
;

COMMIT;
