UPDATE "__STATE__".npmrds_y__YEAR__m__MONTH__
  SET travel_time_all_vehicles = COALESCE(travel_time_passenger_vehicles, travel_time_freight_trucks)
  WHERE (travel_time_all_vehicles IS NULL);                                                                                   
