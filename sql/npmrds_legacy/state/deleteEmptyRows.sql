DELETE FROM "__STATE__".npmrds_y__YEAR__m__MONTH__
  WHERE (COALESCE(travel_time_all_vehicles, travel_time_passenger_vehicles, travel_time_freight_trucks) IS NULL);
