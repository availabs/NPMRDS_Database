BEGIN;

CREATE TEMPORARY TABLE tmp_normaltable
  ON COMMIT DROP
  AS
    SELECT
        tmc,
        ST_LineMerge(wkb_geometry) AS wkb_geometry,
        ST_LineInterpolatePoint(
          ST_LineMerge(wkb_geometry),
          ST_LineLocatePoint(
            ST_LineMerge(wkb_geometry),
            ST_SetSRID(
              ST_MakePoint(
                startlong,
                startlat
              ),
              4326
            )
          )
        ) AS startp,
        ST_LineInterpolatePoint(
          ST_LineMerge(wkb_geometry),
          ST_LineLocatePoint(
            ST_LineMerge(wkb_geometry),
            ST_SetSRID(
              ST_MakePoint(
                endlong,
                endlat
              ),
              4326
            )
          )
        ) AS endp
      FROM npmrds_shapefile___YEAR__
      WHERE (
        ST_NumGeometries(wkb_geometry) = 1
      )
;

CREATE INDEX tmp_normaltable_gix
  ON tmp_normaltable
  USING GIST (wkb_geometry)
;

CREATE TEMPORARY TABLE tmc_normalintersects
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
      FROM tmp_normaltable AS p1
        JOIN tmp_normaltable AS p2
          ON (p1.wkb_geometry && p2.wkb_geometry)
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
  ON tmc_normalintersects
  USING GIST (geom);

DROP TABLE IF EXISTS tmc_children___YEAR__;

CREATE TABLE tmc_children___YEAR__
  AS
    SELECT DISTINCT
        p1.tmc AS base,
        p2.tmc AS child,
        p2.startp
      FROM tmp_normaltable AS p1
        JOIN tmp_normaltable AS p2
          ON (p1.wkb_geometry && p2.wkb_geometry) -- geometries in same bbox
        LEFT OUTER JOIN tmc_normalintersects AS p3
          ON (
            (p1.tmc = tmc1)
            AND
            (p2.tmc = tmc2)
          )
      WHERE (
        -- differnet tmcs
        (p1.tmc != p2.tmc)
        AND
        -- The starting point of the child tmc must originate within the parent tmc
        --   OR the end point of the parent tmc must land within the child tmc
        (
          (
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
          OR
          (
            ST_DWITHIN(
              GEOGRAPHY(
                ST_Transform(p1.endp, 4326)
              ),
              GEOGRAPHY(
                ST_Transform(p2.wkb_geometry, 4326)
              ),
              10
            )
          )
        )
      )
      AND
      (
        -- and if they intersected more than pointwise
        CASE
          WHEN p3.geom is NULL THEN true -- didn't intersect
          ELSE --the intersections flow the same way along both geometries (correct orientation)
            SIGN(
              ST_LineLocatePoint(
                ST_LineMerge(p1.wkb_geometry),
                ST_EndPoint(p3.geom)
              )
              -
              ST_LineLocatePoint(
                ST_LineMerge(p1.wkb_geometry),
                ST_StartPoint(p3.geom)
              )
            )
            =
            SIGN(
              ST_LineLocatePoint(
                ST_LineMerge(p2.wkb_geometry),
                ST_EndPoint(p3.geom)
              )
              -
              ST_LineLocatePoint(
                ST_LineMerge(p2.wkb_geometry),
                ST_StartPoint(p3.geom)
              )
            )
        END
    )
;

CREATE TEMPORARY TABLE tmp_tmc_touching_terminals
  ON COMMIT DROP
  AS
    SELECT
        p1.tmc,
        ST_LineLocatePoint(p1.wkb_geometry, p2.startp) AS dalong
      FROM tmp_normaltable AS p1
        JOIN tmp_normaltable AS p2
          ON (p1.wkb_geometry && p2.wkb_geometry)
      WHERE (
        (p1.tmc != p2.tmc)
        AND
        (
          ST_DWITHIN(
            GEOGRAPHY(
              ST_Transform(p2.startp,4326)
            ),
            GEOGRAPHY(
              ST_Transform(p1.wkb_geometry, 4326)
            ),
            20
          )
        )
      )
    UNION
    SELECT
        p1.tmc,
        ST_LineLocatePoint(p1.wkb_geometry, p2.startp) AS dalong
      FROM tmp_normaltable AS p1
        JOIN tmp_normaltable AS p2
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
              ST_Transform(p1.wkb_geometry, 4326)
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
    FROM tmp_normaltable AS tnt
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
  FROM tmp_normaltable AS p1
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

DROP TABLE IF EXISTS tmc_routable_vertices___YEAR___pgr;
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
        FROM tmc_routable_vertices_pgr AS pgr
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
                t.seq + lastsq,
                t.id2,
                tss.tmc
              FROM (
                SELECT
                    pgr.seq,
                    pgr.id2
                  FROM (
                    SELECT
                        t1.id AS st,
                        t2.id AS en
                      FROM get_closest_id___YEAR__(waypoints[ix], waypoints[ix+1]) AS t1
                        CROSS JOIN get_closest_id___YEAR__(waypoints[ix+2], waypoints[ix+3]) AS t2
                  ) AS t
                    CROSS JOIN pgr_dijkstra(
                      'SELECT id, source, target, cost FROM tmc_routable___YEAR__',
                      t.st::int4,
                      t.en::int4,
                      true,
                      false
                    ) AS pgr
              ) AS t
              JOIN tmc_routable___YEAR__ AS tss
                ON (t.id2 = tss.id)
          )
          SELECT * FROM cte_t;

        ix := ix + 2;

      END LOOP;

    END;
  $$ LANGUAGE plpgsql;

COMMIT;
