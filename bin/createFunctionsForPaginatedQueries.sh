#!/bin/bash

#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

cd ..

# tmcs_within_geography_fn
make db/drop-tmcs-within-geography-fn
make db/create-tmcs-within-geography-fn

# tmc_lexographic_rankings_for_geography_fn
make db/drop-tmc-lexographic-rankings-for-geography-fn
make db/create-tmc-lexographic-rankings-for-geography-fn

# final_rule_measure_rankings_for_geography_fn
make db/drop-final-rule-measure-rankings-for-geography-fn
make db/create-final-rule-measure-rankings-for-geography-fn

# tmcs_in_final_rule_measure_rank_range_for_geography_fn
make db/drop-tmcs-in-final-rule-measure-rank-range-for-geography-fn
make db/create-tmcs-in-final-rule-measure-rank-range-for-geography-fn
