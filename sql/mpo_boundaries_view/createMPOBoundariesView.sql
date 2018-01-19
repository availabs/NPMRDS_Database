	CREATE VIEW public.mpo_boundaries_view AS
    SELECT
        mpo_id,
        ogc_fid,
        wkb_geometry,
        area,
        mpo_name,
        LOWER(state) AS state,
        mpo_acrony
      FROM mpo_boundaries
        LEFT OUTER JOIN us.mpo_acronyms USING (mpo_id)
;
