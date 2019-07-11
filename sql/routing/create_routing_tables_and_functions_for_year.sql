BEGIN;

-- Get the start and end points of each TMC
CREATE TEMPORARY TABLE tmp_tmc_cleaned_geometries_with_terminal_points
  ON COMMIT DROP
  AS
    SELECT
        tmc,
        ST_Buffer(
          GEOGRAPHY(
            wkb_geometry
          ),
          15--meters
        ) AS line_buffer,
        ST_LineMerge(wkb_geometry) AS wkb_geometry,
        ST_SetSRID(
          ST_PointN(
            ST_LineMerge(
              wkb_geometry
            ),
            1
          ), 4326
        ) AS startp,
        ST_SetSRID(
          ST_PointN(
            ST_LineMerge(
              wkb_geometry
            ),
            -1
          ), 4326
        ) AS endp
      FROM npmrds_shapefile___YEAR__ AS shp
      WHERE (
        (ST_NumGeometries(wkb_geometry) = 1)
      )
;

CREATE INDEX tmp_normaltable_gix
  ON tmp_tmc_cleaned_geometries_with_terminal_points
  USING GIST (line_buffer)
;

-- Get the geometries of TMCs intersection.
CREATE TEMPORARY TABLE tmp_tmc_intersection_geometries
  ON COMMIT DROP
  AS
    SELECT
        p1.tmc AS tmc1,
        p2.tmc AS tmc2,
        (
          ST_Dump(
            ST_Intersection(
              p1.wkb_geometry,
              p2.wkb_geometry
            )
          )
        ).geom
      FROM tmp_tmc_cleaned_geometries_with_terminal_points AS p1
        JOIN tmp_tmc_cleaned_geometries_with_terminal_points AS p2
          ON (p1.line_buffer && p2.line_buffer)
      WHERE (
        (
          ST_NumGeometries(
            ST_LineMerge(
              ST_Intersection(
                p1.wkb_geometry,
                p2.wkb_geometry
              )
            )
          ) > 0
        )
        AND
        (p1.tmc != p2.tmc)
     )
  ;

CREATE INDEX normalintersects_gix
  ON tmp_tmc_intersection_geometries
  USING GIST (geom);

DROP TABLE IF EXISTS tmc_children___YEAR__;

CREATE TABLE tmc_children___YEAR__
  AS
    SELECT DISTINCT
        p1.tmc AS base,
        p2.tmc AS child,
        p2.startp
      FROM tmp_tmc_cleaned_geometries_with_terminal_points AS p1
        JOIN tmp_tmc_cleaned_geometries_with_terminal_points AS p2
          ON (p1.line_buffer && p2.line_buffer) -- geometries in same bbox
        LEFT OUTER JOIN tmp_tmc_intersection_geometries AS p3
          ON (
            (p1.tmc = p3.tmc1)
            AND
            (p2.tmc = p3.tmc2)
          )
      WHERE (
        -- differnet tmcs
        (p1.tmc != p2.tmc)
        AND
        (
          ( -- BEGIN parentTail->childHead
            (
              ST_Buffer(
                GEOGRAPHY(
                  ST_Transform(
                    p2.startp,
                    4326
                  )
                ),
                10
              )
              &&
              ST_Buffer(
                GEOGRAPHY(
                  ST_Transform(
                    p1.endp,
                    4326
                  )
                ),
                10
              )
            )
            AND
            (
              (
                ABS(
                  ST_Azimuth(
                    ST_SetSRID(
                      ST_PointN(
                        p2.wkb_geometry,
                        1
                      ),
                      4326
                    ),
                    ST_SetSRID(
                      ST_PointN(
                        p2.wkb_geometry,
                        2
                      ), 4326
                    )
                  )
                  -
                  ST_Azimuth(
                    ST_SetSRID(
                      ST_PointN(
                        p1.wkb_geometry,
                        -2
                      ), 4326
                    ),
                    ST_SetSRID(
                      ST_PointN(
                        p1.wkb_geometry,
                        -1
                      ), 4326
                    )
                  )
                ) / ( 2* pi() ) * 360
              ) NOT BETWEEN 160 and 200
            )
          ) -- END parentTail->childHead
          OR
          ( -- BEGIN: child oringinates within parent, flowing in same direction
           ( -- child startpoint is within 10meters of any point along the parent
             ST_DWithin(
               GEOGRAPHY(
                 ST_Transform(
                   p2.startp,
                   4326
                 )
               ),
               GEOGRAPHY(
                 ST_Transform(
                   p1.wkb_geometry,
                   4326
                 )
               ),
               10
             )
           )
           AND
           ( p3.geom IS NOT NULL ) -- The two lines intersected, more than pointwise
           AND
           (  --the intersections flow the same way along both geometries (correct orientation)
             SIGN(
               -- The ratio of the intersection's end point along the parent
               ST_LineLocatePoint( 
                 ST_LineMerge(p1.wkb_geometry),
                 ST_EndPoint(p3.geom)
               )
               -
               -- The ratio of the intersection's start point along the parent
               ST_LineLocatePoint(
                 ST_LineMerge(p1.wkb_geometry),
                 ST_StartPoint(p3.geom)
               )
             )
             =
             SIGN(
               -- The ratio of the intersection's end point along the child
               ST_LineLocatePoint(
                 ST_LineMerge(p2.wkb_geometry),
                 ST_EndPoint(p3.geom)
               )
               -
               -- The ratio of the intersection's start point along the child
               ST_LineLocatePoint(
                 ST_LineMerge(p2.wkb_geometry),
                 ST_StartPoint(p3.geom)
               )
             )
           )
          )
        ) 
    )
;

CREATE TEMPORARY TABLE tmp_tmc_touching_terminals
  ON COMMIT DROP
  AS
    SELECT
        p1.tmc,
        ST_LineLocatePoint(p1.wkb_geometry, p2.startp) AS dalong
      FROM tmp_tmc_cleaned_geometries_with_terminal_points AS p1
        JOIN tmp_tmc_cleaned_geometries_with_terminal_points AS p2
          ON (p1.line_buffer && p2.line_buffer)
      WHERE (
        (p1.tmc != p2.tmc)
        AND
        (
          ST_DWITHIN(
            GEOGRAPHY(
              ST_Transform(p2.startp,4326)
            ),
            GEOGRAPHY(
              ST_Transform(p1.endp, 4326)
            ),
            20
          )
        )
      )
    UNION
    SELECT
        p1.tmc,
        ST_LineLocatePoint(p1.wkb_geometry, p2.startp) AS dalong
      FROM tmp_tmc_cleaned_geometries_with_terminal_points AS p1
        JOIN tmp_tmc_cleaned_geometries_with_terminal_points AS p2
          ON (p1.wkb_geometry && p2.wkb_geometry)
      WHERE (
        (p1.tmc != p2.tmc)
        AND
        (
          ST_DWITHIN(
            GEOGRAPHY(
              ST_Transform(p2.endp,4326)
            ),
            GEOGRAPHY(
              ST_Transform(p1.startp, 4326)
            ),
            20
          )
        )
      )
;

DROP TABLE IF EXISTS tmc_routable___YEAR__ CASCADE;

CREATE TABLE tmc_routable___YEAR__
AS
  WITH cte_juncts AS (
    SELECT
        tmc,
        array_length(ds, 1) AS njuncts,
        ds
      FROM (
        SELECT
            tmc,
            CASE
              WHEN (
                (NOT 0 = ANY(ds))
                AND
                (NOT 1 = ANY(ds))
              ) THEN CAST(0 AS DOUBLE PRECISION) || ds || cast(1 AS DOUBLE PRECISION)
              WHEN (
                NOT 0 = ANY(ds)
              ) THEN CAST(0 AS DOUBLE PRECISION) || ds
              WHEN (
                NOT 1 = ANY(ds)
              ) THEN ds || CAST(1.0 AS DOUBLE PRECISION)
              ELSE ds
            END AS ds
        FROM (
          SELECT
              tmc,
              COUNT(1) AS njuncts,
              array_agg(dalong ORDER BY dalong ASC) AS ds
            FROM tmp_tmc_touching_terminals
            GROUP BY tmc
        ) AS t
      ) AS k
  ), cte_indxs AS (
    SELECT
        tnt.tmc,
        generate_series(1, cte_juncts.njuncts-1) AS st,
        generate_series(1, cte_juncts.njuncts-1)+1 AS en,
        cte_juncts.ds AS locs
    FROM tmp_tmc_cleaned_geometries_with_terminal_points AS tnt
      JOIN cte_juncts
      USING (tmc)
  )
  SELECT
      p1.tmc,
      CASE
        WHEN (i.st IS NOT NULL)
          THEN ST_LineSubstring(
            p1.wkb_geometry,
            i.locs[i.st],
            i.locs[i.en]
          )
        ELSE p1.wkb_geometry
      END AS the_geom
  FROM tmp_tmc_cleaned_geometries_with_terminal_points AS p1
    LEFT OUTER JOIN cte_indxs AS i
    USING (tmc)
  WHERE (
    (i.st IS NULL)
    OR
    (
      ST_NumPoints(
        ST_LineSubstring(
          p1.wkb_geometry,
          i.locs[i.st],
          i.locs[i.en]
        )
      )
      >
      1
    )
  )
;

CREATE INDEX tmc_routable___YEAR___gix
  ON tmc_routable___YEAR__
  USING GIST (the_geom)
;

ALTER TABLE tmc_routable___YEAR__
  ADD COLUMN id serial,
  ADD COLUMN source int4,
  ADD COLUMN target int4;

DROP TABLE IF EXISTS tmc_routable___YEAR___vertices_pgr;
SELECT pgr_createTopology('tmc_routable___YEAR__', 0.0000001);

--play with tolerance till the vertices all touch their tmcs at least relatively
ALTER TABLE tmc_routable___YEAR__ ADD COLUMN cost float8;

UPDATE tmc_routable___YEAR__
  SET cost = ST_Length(the_geom);

-- TODO: move to own SQL script file
CREATE OR REPLACE FUNCTION get_closest_id___YEAR__(p1 float8, p2 float8)
  RETURNS Table (id int4) 
  AS $$
    BEGIN

    RETURN QUERY
      WITH cte_tmppnt AS (
        SELECT ST_SetSRID(
          ST_MakePoint(p1,p2),
          4326
        ) AS pnt
      ), cte_tmp AS (
        SELECT
            tmc,
            ST_ClosestPoint(
              wkb_geometry,
              cte_tmppnt.pnt
            ) AS cp,
            ST_Distance(
              wkb_geometry,
              cte_tmppnt.pnt
            ) AS d
          FROM npmrds_shapefile___YEAR__
            CROSS JOIN cte_tmppnt
          ORDER BY (wkb_geometry <-> cte_tmppnt.pnt)
          LIMIT 10
      ), the_tmc AS (
        SELECT
            *
          FROM cte_tmp
          ORDER BY d ASC
          LIMIT 1
      ), cte_tmp_tmcvertices AS (
        SELECT
            source AS id
          FROM tmc_routable___YEAR__
          WHERE (
            tmc IN (SELECT the_tmc.tmc FROM the_tmc)
          )
        UNION
        SELECT
            target AS id
          FROM tmc_routable___YEAR__
          WHERE (
            tmc IN (SELECT the_tmc.tmc FROM the_tmc)
          )
      )
      SELECT
          pgr.id::int4
        FROM tmc_routable___YEAR___vertices_pgr AS pgr
          JOIN cte_tmp_tmcvertices
            USING(id)
          CROSS JOIN the_tmc AS tt
        ORDER BY (pgr.the_geom <-> tt.cp) ASC limit 1
  ;

  END;
  $$ LANGUAGE plpgsql;


-- TODO: move to own SQL script file
CREATE OR REPLACE FUNCTION route_from_tmc___YEAR__ (waypoints float8[])
  RETURNS Table(seq int4, nid int4, tmc character varying)
  AS $$
    DECLARE
      ix int4;
      lastsq int4 = 0;
    BEGIN

      ix := 1;

      WHILE ix <= (array_upper(waypoints,1) -3) -- Assumes minumum of 2 coor pairs
      LOOP
        RAISE NOTICE
          '1row=%, 2row=%, 3row=%, 4row=%',
          waypoints[ix],
          waypoints[ix+1],
          waypoints[ix+2],
          waypoints[ix+3]
        ;

        RETURN QUERY
          WITH cte_t AS (
            SELECT
                sub_route.seq + lastsq,
                sub_route.id2,
                tss.tmc
              FROM (
                SELECT
                    pgr.seq,
                    pgr.id2
                  FROM (
                    SELECT
                        t1.id AS start_pt,
                        t2.id AS end_pt
                      FROM get_closest_id___YEAR__(waypoints[ix], waypoints[ix+1]) AS t1
                        CROSS JOIN get_closest_id___YEAR__(waypoints[ix+2], waypoints[ix+3]) AS t2
                  ) AS sub_path
                    CROSS JOIN pgr_dijkstra(
                      'SELECT id, source, target, cost FROM tmc_routable___YEAR__',
                      sub_path.start_pt::int4,
                      sub_path.end_pt::int4,
                      true,
                      false
                    ) AS pgr
              ) AS sub_route
              JOIN tmc_routable___YEAR__ AS tss
                ON (sub_route.id2 = tss.id)
          )
          SELECT * FROM cte_t;

        ix := ix + 2;

      END LOOP;

    END;
  $$ LANGUAGE plpgsql;

COMMIT;
