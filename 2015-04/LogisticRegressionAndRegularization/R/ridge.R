library(ISLR)
library(glmnet)
library(ggplot2)

# Remove NA
Hitters <- na.omit(ISLR::Hitters)

med.salary <- median(Hitters$Salary)
x <- model.matrix(Salary~., Hitters)[,-1]
y <- factor(1* (Hitters$Salary > med))

grid=10^seq(2,-2,length=100)
ridge.mod=glmnet(x, y, family="binomial", alpha=0, lambda=grid)  
# ^^ Can only take numerical inputs
#    Standardizes/scales variables by default
#    alpha=0 is ridge, alpha=1 is lasso

# Coefficients for each predictor for each value of lambda
dim(coef(ridge.mod))


# Split into test/train
set.seed(1)
train=sample(1:nrow(x), nrow(x)/2)
test=(-train)
y.test=y[test]

# Fit ridge model on training data
ridge.mod = glmnet(x[train, ], y[train], 
                   family="binomial", alpha=0, 
                   lambda=grid, thresh=1e-12)

# Use model to predict test data
sg <- sort(grid)[1:60]
mses <- rep(0, length(sg))
for(i in 1:length(sg)){
  ridge.pred.prob=predict(ridge.mod, s=sg[i], newx=x[test, ], type="response")
  ridge.pred.class=round(ridge.pred.prob)

  # Calculate MSE
  mse <- mean((ridge.pred.class - as.numeric(as.character(y[test])))^2)
  print(mse)
  mses[i] <- mse
}

plot(sg, mses, type='l')


ridge.pred.prob = predict(ridge.mod, s=.2, newx=x[test, ], type="response")
ridge.pred.class=round(ridge.pred.prob)
table(factor(ridge.pred.class), y.test)


# Cross validation
cv.glmmod <- cv.glmnet(x, y, family="binomial", alpha=0, type.measure="class")
plot(cv.glmmod)
best_lambda <- cv.glmmod$lambda.min


cv.glmmod <- cv.glmnet(x,y,family="binomial",alpha=1)
plot(cv.glmmod)
best_lambda <- cv.glmmod$lambda.min



