#!/bin/bash

# Projects the requested columns from the CSV.
#
# usage:
#   ./project < input_file
#
# Based On: https://unix.stackexchange.com/a/25144


awk -F, \
	-v cols=tmc,date,epoch,travel_time_all_vehicles,travel_time_passenger_vehicles,travel_time_freight_trucks \
	-v OFS=',' \
'BEGIN {
    split(cols,out,",")
}
NR==1 {
    for (i=1; i<=NF; i++)
        ix[$i] = i
		print cols
}
NR>1 {
    for(i=1; i <= (length(out) - 1); i++)
        printf "%s%s",$ix[out[i]],OFS
    printf "%s",$ix[out[i]]
    print ""
}' -

