CREATE MATERIALIZED VIEW ny.pm_bottlenecks_summary AS (
            SELECT pm.tmc, pm.year, pm.month, pm.phed, pm.tttr, pm.lottr, att.mpo_code as mpo_id,
            row_number() OVER (PARTITION BY pm.year, pm.month ORDER BY pm.phed DESC) as phedrank,
            row_number() OVER (PARTITION BY pm.year, pm.month ORDER BY pm.tttr DESC) as tttrrank,
            row_number() OVER (PARTITION BY pm.year, pm.month ORDER BY pm.lottr DESC) as lottrrank,
            row_number() OVER (PARTITION BY att.mpo_code, pm.year, pm.month ORDER BY pm.phed DESC) as mpophedrank,
            row_number() OVER (PARTITION BY att.mpo_code, pm.year, pm.month ORDER BY pm.tttr DESC) as mpotttrrank,
            row_number() OVER (PARTITION BY att.mpo_code, pm.year, pm.month ORDER BY pm.lottr DESC) as mpolottrrank
            FROM ny.pm_bottlenecks as pm
            JOIN tmc_attributes as att USING (tmc)
);

CREATE INDEX year_month_lottr_ix on ny.pm_bottlenecks_summary (year,month, lottrrank);
CREATE INDEX year_month_tttr_ix on ny.pm_bottlenecks_summary (year,month, tttrrank);
CREATE INDEX year_month_phed_ix on ny.pm_bottlenecks_summary (year,month, phedrank);
