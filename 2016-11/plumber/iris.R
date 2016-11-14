#!/usr/bin/R

#* @filter logger
function(req){
    print(paste0(date(), " - ",
                 req$REMOTE_ADDR, " - ",
                 req$REQUEST_METHOD, " ",
                 req$PATH_INFO))
    forward()
}

# curl -d 'Sepal.Length=6.4&Sepal.Width=3.2&Petal.Length=5.3&Petal.Width=2.3' http://127.0.0.1:8000/iris
#* @post /iris
function(Sepal.Length,Sepal.Width,Petal.Length,Petal.Width){
    model <- randomForest::randomForest(Species ~ ., iris)
    newData <- data.frame(Sepal.Length,
                          Sepal.Width,
                          Petal.Length,
                          Petal.Width)
    predict(model, newdata = newData)
}

