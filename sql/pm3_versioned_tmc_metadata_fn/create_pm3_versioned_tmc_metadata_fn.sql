BEGIN;

DROP FUNCTION IF EXISTS pm3.pm3_versioned_tmc_metadata_fn (TEXT);

CREATE FUNCTION pm3.pm3_versioned_tmc_metadata_fn (p_version_id TEXT)
  RETURNS TABLE (
    tmc                      CHARACTER VARYING,
    roadnumber               CHARACTER VARYING,
    roadname                 CHARACTER VARYING,
    firstname                CHARACTER VARYING,
    tmclinear                INTEGER,
    country                  CHARACTER VARYING,
    state_name               CHARACTER VARYING,
    county_name              CHARACTER VARYING,
    zip                      CHARACTER VARYING,
    direction                CHARACTER VARYING,
    startlat                 DOUBLE PRECISION,
    startlong                DOUBLE PRECISION,
    endlat                   DOUBLE PRECISION,
    endlong                  DOUBLE PRECISION,
    miles                    DOUBLE PRECISION,
    frc                      SMALLINT,
    border_set               CHARACTER VARYING,
    f_system                 SMALLINT,
    faciltype                SMALLINT,
    structype                SMALLINT,
    thrulanes                SMALLINT,
    route_numb               INTEGER,
    route_sign               SMALLINT,
    route_qual               SMALLINT,
    altrtename               CHARACTER VARYING,
    aadt                     INTEGER,
    aadt_singl               INTEGER,
    aadt_combi               INTEGER,
    nhs                      SMALLINT,
    nhs_pct                  SMALLINT,
    strhnt_typ               SMALLINT,
    strhnt_pct               SMALLINT,
    truck                    SMALLINT,
    state                    CHARACTER(2),
    is_interstate            BOOLEAN,
    is_controlled_access     BOOLEAN,
    avg_speedlimit           REAL,
    mpo_code                 CHARACTER VARYING,
    mpo_acrony               CHARACTER VARYING,
    mpo_name                 CHARACTER VARYING,
    ua_code                  CHARACTER VARYING,
    ua_name                  CHARACTER VARYING,
    congestion_level         TRAFFIC_DIST_CONGESTION_LEVEL_TYPE,
    directionality           TRAFFIC_DIST_DIRECTIONALITY_TYPE,
    bounding_box             BOX2D,
    avg_vehicle_occupancy    REAL,
    state_code               CHARACTER(2),
    county_code              CHARACTER(5),
    --  type                     CHARACTER VARYING,
    --  road_order               REAL,
    isprimary                SMALLINT,
    pm3_is_nhs_interstate    BOOLEAN,
    pm3_is_nhs_noninterstate BOOLEAN
  )
AS $pm3_versioned_tmc_metadata_fn$

DECLARE p_pm3_version_minor_number INTEGER;

BEGIN
  SELECT minor_version
    INTO p_pm3_version_minor_number
    FROM pm3.pm3_calculation_versions_view AS a
    WHERE ( a.version_id = p_version_id );

  IF NOT FOUND THEN
    RAISE EXCEPTION 'ERROR: Invalid version_id';
  END IF;

  -- Create a snapshot of the tmc_metadata tables that were in use during the pm3 calculator run.
  RETURN QUERY EXECUTE
      string_agg('
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
              isprimary,
              CASE
                WHEN (' || p_pm3_version_minor_number || ' = 1)
                  THEN COALESCE(f_system = 1, false )
                ELSE
                  COALESCE(
                    ( f_system = 1 )
                    AND
                    ( faciltype IN (1, 2, 6) )
                    AND
                    ( nhs IN (1,2,3,4,5,6,7,8,9) ),
                    false
                  )
                END AS pm3_is_nhs_interstate,
                CASE
                  WHEN (' || p_pm3_version_minor_number || ' = 1)
                    THEN COALESCE(f_system <> 1, false )
                  ELSE
                    COALESCE(
                      ( f_system IN (2,3,4,5,6,7) )
                      AND
                      ( faciltype IN (1, 2, 6) )
                      AND
                      ( nhs IN (1,2,3,4,5,6,7,8,9) ),
                      false
                    )
                END AS pm3_is_nhs_noninterstate


          FROM "' || t.state || '"' || '.tmc_metadata_' || t.year || '_v' || t.tmc_metadata_table_name, '
          UNION ALL')
      FROM (
        SELECT DISTINCT
            year,
            (meta).key AS state,
            REGEXP_REPLACE(
              (meta).value->>'tmc_metadata_version_timestamp',
              '[^0-9]',
              '',
              'ig'
            ) AS tmc_metadata_table_name
          FROM (
            SELECT
                year,
                jsonb_each(data_provenance_metadata) AS meta
              FROM pm3.pm3_calculator_data_provenances AS a
                INNER JOIN pm3.pm3_calculation_versions_view AS b
                  ON ( a.id = ANY(b.pm3calc_ids) )
              WHERE ( b.version_id = p_version_id )
          ) AS t
          ORDER BY 1,2,3
      ) AS t ;

END;
$pm3_versioned_tmc_metadata_fn$ LANGUAGE plpgsql;

COMMIT;
