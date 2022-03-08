netcdf_ini_end_read <- function(filename) 
{
#### Loading netcdf output ####
nc_data <- nc_open(filename)

#### Working with the netcdf variables ####
lon_ini <- ncvar_get(nc_data, "ini_lon")
lat_ini <- ncvar_get(nc_data, "ini_lat")

lon_end <- ncvar_get(nc_data, "end_lon")
lat_end <- ncvar_get(nc_data, "end_lat")

data_from <- as.data.frame(cbind(lon_ini, lat_ini))
data_to <- as.data.frame(cbind(lon_end, lat_end))

data_points <- as.data.frame(cbind(data_from, data_to))

min_lat_ppp <- floor(min(c(min(data_points$lat_ini, na.rm = TRUE), min(data_points$lat_end, na.rm = TRUE))))
max_lat_ppp <- ceiling(max(c(min(data_points$lat_ini, na.rm = TRUE), max(data_points$lat_end, na.rm = TRUE))))

min_lon_ppp <- floor(min(c(min(data_points$lon_ini, na.rm = TRUE), min(data_points$lon_end, na.rm = TRUE))))
max_lon_ppp <- ceiling(max(c(min(data_points$lon_ini, na.rm = TRUE), max(data_points$lon_end, na.rm = TRUE))))

newList <- list("data_from" = data_from,
                "data_to" = data_to,
                "min_lat_ppp" = min_lat_ppp,
                "max_lat_ppp" = max_lat_ppp,
                "min_lon_ppp" = min_lon_ppp,
                "max_lon_ppp" = max_lon_ppp)
}
