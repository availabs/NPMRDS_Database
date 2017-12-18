	CREATE VIEW public.mpo_boundaries_view AS
    SELECT *
      FROM mpo_boundaries
        LEFT OUTER JOIN us.mpo_acronyms
        USING (mpo_id)
;
