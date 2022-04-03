\set tbl_name :"STATE"'.npmrds_y':YEAR'm':MONTH
\set idx_name 'npmrds_y':YEAR'm':MONTH'_pkey'

CLUSTER :tbl_name
  USING :idx_name
;
