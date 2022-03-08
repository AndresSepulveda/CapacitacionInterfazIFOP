edge_stats <- function(graph) {
gs <- list()
gs[[1]] <- graph
estats <- do.call('rbind', lapply(1:length(gs), function(x) {
  o <- get.data.frame(gs[[x]], what = 'edges')
  o$network <- get.graph.attribute(gs[[x]], "name")
  return(o)
}))
return(estats)
}