opd_network_graph <- function(df.matrices, amerbs_points) 
{
  require(plyr)
  require(dplyr)
  require(igraph)
  
# Here the latitude and longitude data are assigned to the predefined zones in the matrix object
  df.vertices <- data.frame(name = 1:nrow(amerbs_points), y = rep(NaN, nrow(amerbs_points)), x = rep(NaN, nrow(amerbs_points)))
  # A loop is used and the "which" function 
  for (i in 1:nrow(df.vertices)){
    idx                <- which(amerbs_points$name == df.vertices$name[i])
    df.vertices$y[i]   <- amerbs_points$lat[idx]
    df.vertices$x[i]   <- amerbs_points$lon[idx]
  }
  
  # Generating a probability connection graph
  df.mat.pot <- filter(df.matrices, probability > 0)
  
  con.plot <-graph_from_data_frame(data.frame(from=df.mat.pot$from, to=df.mat.pot$to, weight=df.mat.pot$probability), directed = TRUE, vertices = df.vertices)
  
  # All this is because igraph assumes that weights are costs
  E(con.plot)$strength     <- E(con.plot)$weight
  E(con.plot)$cost         <- mean(E(con.plot)$weight) / E(con.plot)$weight
  E(con.plot)$weight       <- E(con.plot)$cost
  
return(con.plot)
}
