BEGIN;

CREATE SCHEMA IF NOT EXISTS "ct" ;
CREATE SCHEMA IF NOT EXISTS "nj" ;
CREATE SCHEMA IF NOT EXISTS "ny" ;


      CREATE TABLE IF NOT EXISTS "ct".npmrds_monthly_avg_tt_y2021m01 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ct'),
        CHECK (year   =   2021),
        CHECK (month  =   1)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ct".npmrds_monthly_avg_tt_y2021m01 using npmrds_monthly_avg_tt_y2021m01_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ct".npmrds_monthly_avg_tt_y2021m02 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ct'),
        CHECK (year   =   2021),
        CHECK (month  =   2)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ct".npmrds_monthly_avg_tt_y2021m02 using npmrds_monthly_avg_tt_y2021m02_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ct".npmrds_monthly_avg_tt_y2021m03 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ct'),
        CHECK (year   =   2021),
        CHECK (month  =   3)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ct".npmrds_monthly_avg_tt_y2021m03 using npmrds_monthly_avg_tt_y2021m03_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ct".npmrds_monthly_avg_tt_y2021m04 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ct'),
        CHECK (year   =   2021),
        CHECK (month  =   4)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ct".npmrds_monthly_avg_tt_y2021m04 using npmrds_monthly_avg_tt_y2021m04_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ct".npmrds_monthly_avg_tt_y2021m05 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ct'),
        CHECK (year   =   2021),
        CHECK (month  =   5)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ct".npmrds_monthly_avg_tt_y2021m05 using npmrds_monthly_avg_tt_y2021m05_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ct".npmrds_monthly_avg_tt_y2021m06 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ct'),
        CHECK (year   =   2021),
        CHECK (month  =   6)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ct".npmrds_monthly_avg_tt_y2021m06 using npmrds_monthly_avg_tt_y2021m06_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ct".npmrds_monthly_avg_tt_y2021m07 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ct'),
        CHECK (year   =   2021),
        CHECK (month  =   7)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ct".npmrds_monthly_avg_tt_y2021m07 using npmrds_monthly_avg_tt_y2021m07_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ct".npmrds_monthly_avg_tt_y2021m08 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ct'),
        CHECK (year   =   2021),
        CHECK (month  =   8)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ct".npmrds_monthly_avg_tt_y2021m08 using npmrds_monthly_avg_tt_y2021m08_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ct".npmrds_monthly_avg_tt_y2021m09 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ct'),
        CHECK (year   =   2021),
        CHECK (month  =   9)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ct".npmrds_monthly_avg_tt_y2021m09 using npmrds_monthly_avg_tt_y2021m09_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ct".npmrds_monthly_avg_tt_y2021m10 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ct'),
        CHECK (year   =   2021),
        CHECK (month  =   10)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ct".npmrds_monthly_avg_tt_y2021m10 using npmrds_monthly_avg_tt_y2021m10_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ct".npmrds_monthly_avg_tt_y2021m11 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ct'),
        CHECK (year   =   2021),
        CHECK (month  =   11)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ct".npmrds_monthly_avg_tt_y2021m11 using npmrds_monthly_avg_tt_y2021m11_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ct".npmrds_monthly_avg_tt_y2021m12 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ct'),
        CHECK (year   =   2021),
        CHECK (month  =   12)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ct".npmrds_monthly_avg_tt_y2021m12 using npmrds_monthly_avg_tt_y2021m12_pkey ;
    

      CREATE TABLE IF NOT EXISTS "nj".npmrds_monthly_avg_tt_y2021m12 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'nj'),
        CHECK (year   =   2021),
        CHECK (month  =   12)
      ) WITH (fillfactor = 100) ;

      CLUSTER "nj".npmrds_monthly_avg_tt_y2021m12 using npmrds_monthly_avg_tt_y2021m12_pkey ;
    

      CREATE TABLE IF NOT EXISTS "nj".npmrds_monthly_avg_tt_y2022m01 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'nj'),
        CHECK (year   =   2022),
        CHECK (month  =   1)
      ) WITH (fillfactor = 100) ;

      CLUSTER "nj".npmrds_monthly_avg_tt_y2022m01 using npmrds_monthly_avg_tt_y2022m01_pkey ;
    

      CREATE TABLE IF NOT EXISTS "nj".npmrds_monthly_avg_tt_y2022m02 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'nj'),
        CHECK (year   =   2022),
        CHECK (month  =   2)
      ) WITH (fillfactor = 100) ;

      CLUSTER "nj".npmrds_monthly_avg_tt_y2022m02 using npmrds_monthly_avg_tt_y2022m02_pkey ;
    

      CREATE TABLE IF NOT EXISTS "nj".npmrds_monthly_avg_tt_y2022m03 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'nj'),
        CHECK (year   =   2022),
        CHECK (month  =   3)
      ) WITH (fillfactor = 100) ;

      CLUSTER "nj".npmrds_monthly_avg_tt_y2022m03 using npmrds_monthly_avg_tt_y2022m03_pkey ;
    

      CREATE TABLE IF NOT EXISTS "nj".npmrds_monthly_avg_tt_y2022m04 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'nj'),
        CHECK (year   =   2022),
        CHECK (month  =   4)
      ) WITH (fillfactor = 100) ;

      CLUSTER "nj".npmrds_monthly_avg_tt_y2022m04 using npmrds_monthly_avg_tt_y2022m04_pkey ;
    

      CREATE TABLE IF NOT EXISTS "nj".npmrds_monthly_avg_tt_y2022m05 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'nj'),
        CHECK (year   =   2022),
        CHECK (month  =   5)
      ) WITH (fillfactor = 100) ;

      CLUSTER "nj".npmrds_monthly_avg_tt_y2022m05 using npmrds_monthly_avg_tt_y2022m05_pkey ;
    

      CREATE TABLE IF NOT EXISTS "nj".npmrds_monthly_avg_tt_y2022m06 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'nj'),
        CHECK (year   =   2022),
        CHECK (month  =   6)
      ) WITH (fillfactor = 100) ;

      CLUSTER "nj".npmrds_monthly_avg_tt_y2022m06 using npmrds_monthly_avg_tt_y2022m06_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ny".npmrds_monthly_avg_tt_y2021m12 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ny'),
        CHECK (year   =   2021),
        CHECK (month  =   12)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ny".npmrds_monthly_avg_tt_y2021m12 using npmrds_monthly_avg_tt_y2021m12_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ny".npmrds_monthly_avg_tt_y2022m01 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ny'),
        CHECK (year   =   2022),
        CHECK (month  =   1)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ny".npmrds_monthly_avg_tt_y2022m01 using npmrds_monthly_avg_tt_y2022m01_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ny".npmrds_monthly_avg_tt_y2022m02 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ny'),
        CHECK (year   =   2022),
        CHECK (month  =   2)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ny".npmrds_monthly_avg_tt_y2022m02 using npmrds_monthly_avg_tt_y2022m02_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ny".npmrds_monthly_avg_tt_y2022m03 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ny'),
        CHECK (year   =   2022),
        CHECK (month  =   3)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ny".npmrds_monthly_avg_tt_y2022m03 using npmrds_monthly_avg_tt_y2022m03_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ny".npmrds_monthly_avg_tt_y2022m04 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ny'),
        CHECK (year   =   2022),
        CHECK (month  =   4)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ny".npmrds_monthly_avg_tt_y2022m04 using npmrds_monthly_avg_tt_y2022m04_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ny".npmrds_monthly_avg_tt_y2022m05 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ny'),
        CHECK (year   =   2022),
        CHECK (month  =   5)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ny".npmrds_monthly_avg_tt_y2022m05 using npmrds_monthly_avg_tt_y2022m05_pkey ;
    

      CREATE TABLE IF NOT EXISTS "ny".npmrds_monthly_avg_tt_y2022m06 (
        LIKE public.npmrds_monthly_avg_tt,

        PRIMARY KEY(tmc),

        CHECK (state  =   'ny'),
        CHECK (year   =   2022),
        CHECK (month  =   6)
      ) WITH (fillfactor = 100) ;

      CLUSTER "ny".npmrds_monthly_avg_tt_y2022m06 using npmrds_monthly_avg_tt_y2022m06_pkey ;
    

COMMIT;
