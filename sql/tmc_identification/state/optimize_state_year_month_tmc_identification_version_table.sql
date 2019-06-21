\set tbl_name :"STATE"'.tmc_identification_':YEAR'_v':DOWNLOAD_TIMESTAMP
\set idx_name 'tmc_identification_':YEAR'_v':DOWNLOAD_TIMESTAMP'_pkey'

CLUSTER :tbl_name
  USING :idx_name;
