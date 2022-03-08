zone_assign <- function(amerbs_points, data_from, data_to, treshold_km, min_lon_ppp, max_lon_ppp, min_lat_ppp, max_lat_ppp) 
{ require(spatstat)
  require(plyr)
  require(dplyr)
  points_amerbs <- as.ppp(amerbs_points, c(min_lon_ppp, max_lon_ppp, min_lat_ppp, max_lat_ppp))
  points_ibm_ini <- as.ppp(data_from, c(min_lon_ppp, max_lon_ppp, min_lat_ppp, max_lat_ppp))
  points_ibm_end <- as.ppp(data_to, c(min_lon_ppp, max_lon_ppp, min_lat_ppp, max_lat_ppp))
  
  nn_ini <- nncross(points_ibm_ini, points_amerbs)
  nn_end <- nncross(points_ibm_end, points_amerbs)
  
  # L = π * R * a / 180
  # L - arc length [km]
  # R - radius of a circle [km]
  # a - angle [degrees]
  
  nn_ini$dist_km <- (pi * 6371 * nn_ini$dist)/180
  nn_end$dist_km <- (pi * 6371 * nn_end$dist)/180
  
  data_from_to_zones <- data.frame(from = nn_ini$which, to = nn_end$which, dist_to_nearest_zone_at_recruitment = nn_end$dist_km)
  
  data = filter(data_from_to_zones, dist_to_nearest_zone_at_recruitment <= treshold_km)
  data$super_particle_size <- 1

return(data)
}
