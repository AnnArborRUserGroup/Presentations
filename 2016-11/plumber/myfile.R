#!/usr/bin/R

#* @filter logger
function(req){
    print(paste0(date(), " - ",
                 req$REMOTE_ADDR, " - ",
                 req$REQUEST_METHOD, " ",
                 req$PATH_INFO))
    forward()
}

#* @get /mean
normalMean <- function(samples=10){
    data <- rnorm(samples)
    mean(data)
}

#* @post /sum
addTwo <- function(a, b){
    as.numeric(a) + as.numeric(b)
}
