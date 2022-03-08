opd_centrality <- function(graph)
{ x = graph
  require(igraph)
  V(x)$degree       <- degree(x, mode = "all")
  V(x)$in_degree    <- degree(x, mode = "in")
  V(x)$out_degree   <- degree(x, mode = "out")
  V(x)$strength     <- strength(x,
                                weights = E(x)$strength,
                                mode = "all",
                                loops = T)
  V(x)$in_strength  <- strength(x,
                                weights = E(x)$strength,
                                mode = "in",
                                loops = T)
  V(x)$out_strength <- strength(x,
                                weights = E(x)$strength,
                                mode = "out",
                                loops = T)
  V(x)$evcent                <- evcent(x, weights = E(x)$strength)$vector
  V(x)$pagerank              <- page_rank(x, weights = E(x)$strength)$vector
  V(x)$auth_score            <- authority.score(x, weights = E(x)$strength)$vector
  V(x)$hub_score             <- hub.score(x, weights = E(x)$strength)$vector
  
  # Here we calculate node betweenness with respect to the cost
  V(x)$betweenness           <- betweenness(x)
  # Here we calculate edge betweenness with respect to the cost
  E(x)$edge_betweenness      <- edge.betweenness(x)
  
  # Normalized Centrality measures
  V(x)$n.degree              <- normalize_fun(V(x)$degree)
  V(x)$n.strength            <- normalize_fun(V(x)$strength)
  V(x)$n.in_strength         <- normalize_fun(V(x)$in_strength)
  V(x)$n.out_strength        <- normalize_fun(V(x)$out_strength)
  V(x)$n.betweenness         <- normalize_fun(V(x)$betweenness)
  V(x)$n.evcent              <- normalize_fun(V(x)$evcent+1E-16)
  V(x)$n.pagerank            <- normalize_fun(V(x)$pagerank)
  V(x)$n.auth_score          <- normalize_fun(V(x)$auth_score)
  V(x)$n.hub_score           <- normalize_fun(V(x)$hub_score)
  
  E(x)$n.edge_betweenness    <- normalize_fun(E(x)$edge_betweenness)
  E(x)$n.edge_weight         <- normalize_fun(as.numeric(E(x)$weight))
  E(x)$n.edge_strength       <- normalize_fun(as.numeric(E(x)$strength ))
  E(x)$n.edge_cost           <- normalize_fun(as.numeric(E(x)$cost))
  
  if (is.connected(x) == TRUE){
  V(x)$closeness             <- closeness(x)
  V(x)$n.closeness           <- normalize_fun(V(x)$closeness)
  }
  return(x)
}