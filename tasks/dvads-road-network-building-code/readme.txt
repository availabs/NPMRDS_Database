# This assumes npmrds_shapefile_2016Q2 has been loaded
# This assumes npmrds_tmc_lut_2016Q2   has been loaded
# This assumes static_file_data        has been loaded



createTopology.sql -> create_tmc_terminals.sql
-> create_tmc_origins.sql -> tmc_child_builder.sql
