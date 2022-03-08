normalize_fun <- function(x) {
  a <- min(x) 
  b <- max(x) 
  (x - a)/(b - a) 
}