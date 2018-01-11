As of 2018-01-09

  Dependents of tmc_attributes.

  ```
  npmrds_local=# drop materialized view tmc_attributes ;
  ERROR:  cannot drop materialized view tmc_attributes because other objects depend on it
  DETAIL:  materialized view geography_level_to_states depends on materialized view tmc_attributes
  materialized view ny.pm_bottlenecks_summary depends on materialized view tmc_attributes
  materialized view geography_level_attributes_view depends on materialized view tmc_attributes
  HINT:  Use DROP ... CASCADE to drop the dependent objects too.
  ```
