#!/bin/bash

#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

cd ..

make db/drop-tmc-ranking-type
make db/create-tmc-ranking-type

make db/drop-final-rule-measure-type
make db/create-final-rule-measure-type

make db/drop-final-rule-measure-sort-column-type
make db/create-final-rule-measure-sort-column-type



# npmrds_local=# drop type tmc_ranking_type ;
# ERROR:  cannot drop type tmc_ranking_type because other objects depend on it
# DETAIL:  function tmc_lexographic_rankings_for_geography_fn(character varying[],geography_level_type,text,text,integer,integer) depends on type tmc_ranking_type
# function final_rule_measure_rankings_for_geography_fn(character varying[],geography_level_type,text,final_rule_measure_sort_column_type,text,integer,integer,integer,integer) depends on type tmc_ranking_type
# HINT:  Use DROP ... CASCADE to drop the dependent objects too.
# npmrds_local=# drop type final_rule_measure_
# final_rule_measure_sort_column_type  final_rule_measure_type
# npmrds_local=# drop type final_rule_measure_type ;
# DROP TYPE
# npmrds_local=# drop type final_rule_measure_sort_column_type ;
# ERROR:  cannot drop type final_rule_measure_sort_column_type because other objects depend on it
# DETAIL:  function final_rule_measure_rankings_for_geography_fn(character varying[],geography_level_type,text,final_rule_measure_sort_column_type,text,integer,integer,integer,integer) depends on type final_rule_measure_sort_column_type
# function paginated_final_rule_measures_for_geography_fn(character varying[],geography_level_type,text,final_rule_measure_sort_column_type,text,integer,integer,integer,integer) depends on type final_rule_measure_sort_column_type
# function tmcs_in_final_rule_measure_rank_range_for_geography_fn(character varying[],geography_level_type,text,final_rule_measure_sort_column_type,text,integer,integer,integer,integer) depends on type final_rule_measure_sort_column_type
# 
