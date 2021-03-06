library(slurmR) # This loads parallel
library(Rcpp)

# Loading the program
sourceCpp("programs/rwrapper.cpp")

# A wrapper for the simulation output
wrap_sim <- function(x) {
  structure(
    as.data.frame(do.call(cbind, x$data)),
    names = x$cnames
    )
}

ans <- sim_events(1000, 100)

str(wrap_sim(ans))

# But we need to setup the program in a cluster
cl  <- makePSOCKcluster(4)
out <- clusterEvalQ(cl, {
  library(Rcpp)
  sourceCpp("programs/rwrapper.cpp")
})

clusterExport(cl, "wrap_sim")

# Trying it out
ans <- parLapply(cl, 1:4, function(s) {
  out <- sim_events(1000, 100, seed = s)
  wrap_sim(out)
})

str(ans)
