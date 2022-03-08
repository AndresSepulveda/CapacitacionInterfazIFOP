node_stats <- function(graph) {
gs <- list()
gs[[1]] <- graph
vstats <- do.call('rbind', lapply(1:length(gs), function(x) {
  o <- get.data.frame(gs[[x]], what = 'vertices')
  o$network <- get.graph.attribute(gs[[x]], "name")
  return(o)
}))
return(vstats)
}