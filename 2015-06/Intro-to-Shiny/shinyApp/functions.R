makeTable <- function(x) {
  df[sample(nrow(df), x), ]
}

makeData <- function() {
  df <- data.frame(a=rnorm(10000000), b=runif(10000000))
}
