opd_matrix <- function(data) 
{
  require(plyr)
  require(dplyr)
  # Organization of the dataframe to make the plots
  df.matrices <- ddply(data, c("from", "to"), .drop = FALSE, summarise, value = sum(super_particle_size))
  
  df.release.ind <- ddply(data, c("from"), .drop = FALSE, summarise,
                          value = sum(super_particle_size))
  
  df.matrices$probability <- df.matrices$value / df.release.ind[df.matrices$from,2]
  

return(df.matrices)
}
