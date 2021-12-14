DO
  LANGUAGE plpgsql
  $$
    DECLARE
      new_tablename TEXT :=  'tmc_metadata_2020_v' || to_char(now(), 'YYYYMMDDHH24MISS') ;
      state         TEXT;

    BEGIN
      RAISE NOTICE '%', new_tablename ;

      FOR state IN 
        SELECT
            schemaname AS state
          FROM pg_catalog.pg_tables
          WHERE (
            ( schemaname <> 'public' )
            AND
            ( tablename = 'tmc_metadata_2020' )
          )
      LOOP

        EXECUTE FORMAT('
          CREATE TABLE %I.%I (
            LIKE %I.tmc_metadata_2020 INCLUDING ALL
          ) WITH (fillfactor=100) ;
        ', state, new_tablename, state) ;

        EXECUTE FORMAT('
          INSERT INTO %I.%I (
            tmc,
            roadnumber,
            roadname,
            firstname,
            tmclinear,
            country,
            state_name,
            county_name,
            zip,
            direction,
            startlat,
            startlong,
            endlat,
            endlong,
            miles,
            frc,
            border_set,
            f_system,
            faciltype,
            structype,
            thrulanes,
            route_numb,
            route_sign,
            route_qual,
            altrtename,
            aadt,
            aadt_singl,
            aadt_combi,
            nhs,
            nhs_pct,
            strhnt_typ,
            strhnt_pct,
            truck,
            state,
            is_interstate,
            is_controlled_access,
            avg_speedlimit,
            mpo_code,
            mpo_acrony,
            mpo_name,
            ua_code,
            ua_name,
            congestion_level,
            directionality,
            bounding_box,
            avg_vehicle_occupancy,
            state_code,
            county_code,
            type,
            road_order,
            isprimary,
            timezone_name,
            active_start_date,
            active_end_date,
            region_code
          )
            SELECT
                tmc,
                roadnumber,
                roadname,
                firstname,
                tmclinear,
                country,
                state_name,
                county_name,
                zip,
                direction,
                startlat,
                startlong,
                endlat,
                endlong,
                miles,
                frc,
                border_set,
                f_system,
                faciltype,
                structype,
                thrulanes,
                route_numb,
                route_sign,
                route_qual,
                altrtename,
                aadt,
                aadt_combi,  -- NOTE: swapped with aadt_singl
                aadt_singl,  --       swapped with aadt_combi
                nhs,
                nhs_pct,
                strhnt_typ,
                strhnt_pct,
                truck,
                state,
                is_interstate,
                is_controlled_access,
                avg_speedlimit,
                mpo_code,
                mpo_acrony,
                mpo_name,
                ua_code,
                ua_name,
                congestion_level,
                directionality,
                bounding_box,
                avg_vehicle_occupancy,
                state_code,
                county_code,
                type,
                road_order,
                isprimary,
                timezone_name,
                active_start_date,
                active_end_date,
                region_code
              FROM %I.tmc_metadata_2020
          ;
        ', state, new_tablename, state) ;

      EXECUTE FORMAT('
        COMMENT ON TABLE %I.%I IS ''NOTE:
  This tmc_metadata_2020 TABLE was created with the official RITIS
    TMC_Identification TMC truck AADT (aadt_singl and aadt_combi)
    values transposed.

  AVAIL decided to do this after discovering anomalies between
    the 2020 RITIS TMC_Identification truck AADT values and
      * the truck AADT values in the 2019 RITIS TMC_Identification files
      * earlier (unofficial) 2020 RIS TMC_Identification versions
      * the 2019 NYSDOT Roadway Inventory System truck AADT values

  If, for any reason, the tmc_metadata_2020 tables must be re-created,
    and AVAIL has not loaded corrected TMC_Identification data,
    the aadt_singl and aadt_combi MUST again be transposed.''
      ', state, new_tablename) ;

      END LOOP;

    COMMIT ;

    END ;
  $$
