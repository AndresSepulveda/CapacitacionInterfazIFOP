opendrift_read_csv <- function(filename, col_names = FALSE, skip_first_row = TRUE) 
{

  if(skip_first_row == TRUE){
    # Jump to second row
    {
      skip_row = 1
    }
  }

#### Loading text output ####
nc_data <- read_table(filename, col_names = FALSE, skip = skip_row)
    
    


#### Working with the text file variables ####
status <- nc_data$X9

idx <- which(status == 0)


lon_ini <- nc_data$X3[idx]
lat_ini <- nc_data$X4[idx]

lon_end <- nc_data$X7[idx]
lat_end <- nc_data$X8[idx]

data_from <- as.data.frame(cbind(lon_ini, lat_ini))
nan_in_df <- which(is.na(data_from))
data_to <- as.data.frame(cbind(lon_end, lat_end))
nan_in_dt <- which(is.na(data_to))


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
