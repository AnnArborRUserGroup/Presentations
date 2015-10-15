# Lasso regularization for logistic regression

library(ISLR)
library(glmnet)
library(ggplot2)

# Remove NA
Hitters <- na.omit(Hitters)

x <- model.matrix(Salary~., Hitters)[,-1]
y <- factor(1* (Hitters$Salary > 500))

# Split into test/train
set.seed(1)
train=sample(1:nrow(x), nrow(x)/2)
test=(-train)
y.test=y[test]

grid=10^seq(2,-2,length=100)


# cross-validated lasso (alpha=1)
cv.glmmod <- cv.glmnet(x[train, ], y[train],
                       family="binomial",alpha=1)
plot(cv.glmmod)
best_lambda <- cv.glmmod$lambda.min


# use best lambda to build model
newmdl = glmnet(x[train, ], y[train], lambda=best_lambda, 
                family="binomial", alpha=1)
new.prob = predict(newmdl, newx=x[test, ], type="response")
new.class=round(new.prob)
table(factor(new.class), y.test)
#plot(newmdl, xvar="lambda")

