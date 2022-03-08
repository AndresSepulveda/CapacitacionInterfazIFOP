opendrift_read <- function(filename, metadata = TRUE) 
{
#### Loading netcdf output ####
nc_data <- nc_open(filename)

if(metadata == TRUE){
# Save the print(nc) dump to a text file
{
  sink('netcdf_metadata.txt')
  print(nc_data)
  sink()
}
  }

#### Working with the netcdf variables ####
status <- t(ncvar_get(nc_data, "status"))

nb_particles <- dim(status)[1]

status <- replace(status, status == -2147483647, 2147483647)

ini_time <- matrix(c(1:nb_particles, max.col(status == 0, "first")), nrow = nb_particles, ncol = 2) # NOTA PARA ANDRES SEPULVEDA: Parece ser que las partículas no se liberan al mismo tiempo (inicio) del modelo. Aquí busco el tiempo inicial en el cual empieza a aparecer como activa = 0.
end_time <- matrix(c(1:nb_particles, max.col(status <= 1, "last")), nrow = nb_particles, ncol = 2)


part_lon <- t(ncvar_get(nc_data, "lon")) # This matrix has been transposed so that the first column corresponds to the initial positions.
part_lat <- t(ncvar_get(nc_data, "lat", verbose = F)) # idem.
t <- ncvar_get(nc_data, "time")

part_lon <- replace(part_lon, part_lon >= 9.969E+36, NaN)
part_lat <- replace(part_lat, part_lat >= 9.969E+36, NaN)

lon_ini <- part_lon[ini_time]
lat_ini <- part_lat[ini_time]

lon_end <- part_lon[end_time]
lat_end <- part_lat[end_time]

data_from <- as.data.frame(cbind(lon_ini, lat_ini))
nan_in_df <- which(is.na(data_from))
data_to <- as.data.frame(cbind(lon_end, lat_end))
nan_in_dt <- which(is.na(data_to))

# NOTA PARA ANDRES SEPULVEDA: Hay NaNs en el dataset inicial y final y no se porque ocurre, hay que investigar, por ahora los limpio.
data_points <- as.data.frame(cbind(data_from, data_to))
data_points  <- data_points[complete.cases(data_points),]

data_from <- data_points[,1:2]
data_to <- data_points[,3:4]

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
