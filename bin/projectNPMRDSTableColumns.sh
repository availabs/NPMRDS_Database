#!/bin/bash

# Projects the requested columns from the CSV.
#
# usage:
#   ./project < input_file
#
# Based On: https://unix.stackexchange.com/a/25144


awk -F, \
  -v OFS=',' \
'
NR==1 {
  for (i=1; i<=NF; i++)
    ix[$i] = i
  print "tmc,date,epoch,travel_time_all_vehicles,travel_time_passenger_vehicles,travel_time_freight_trucks"
}
NR>1 {
  printf "%s,",$ix["tmc"]
  printf "%s,",$ix["date"]
  printf "%s,",$ix["epoch"]
  printf "%s,",$ix["travel_time_all_vehicles"]
  printf "%s,",$ix["travel_time_passenger_vehicles"]
  printf "%s\n",$ix["travel_time_freight_trucks"]
}' -

