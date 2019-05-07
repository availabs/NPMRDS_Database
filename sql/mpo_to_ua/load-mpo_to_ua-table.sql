BEGIN;

DELETE FROM mpo_to_ua;

INSERT INTO mpo_to_ua (mpo_code, ua_code)
  SELECT
      mpo_code::VARCHAR,  -- zero-padded
      ua_code::VARCHAR    -- zero-padded
    FROM (
      SELECT
          ROW_NUMBER() OVER (
            PARTITION BY mpo_code ORDER BY intersection_area DESC, ua_code
          ) AS row_num,
          sub_mpo_to_ua_intersection_areas.*
        FROM (
          SELECT
              m.mpo_id AS mpo_code,
              LOWER(m.state) AS state,
              u.geoid10 AS ua_code,
              u.name10 AS ua_name,
              ST_Area(
                ST_Intersection(
                  m.wkb_geometry,
                  u.wkb_geometry
                )
              ) AS intersection_area
          FROM mpo_boundaries AS m
            INNER JOIN urban_area_boundaries AS u
            ON (ST_Intersects(m.wkb_geometry , u.wkb_geometry))
        ) as sub_mpo_to_ua_intersection_areas
    ) AS sub_ranked_mpo_to_ua
    WHERE row_num = 1
;

CLUSTER mpo_to_ua USING mpo_to_ua_pkey;

COMMIT;

ANALYZE mpo_to_ua;
