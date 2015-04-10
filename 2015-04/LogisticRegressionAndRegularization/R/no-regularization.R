# Plain old logistic regression using glm
library(ISLR)
library(glmnet)
library(ggplot2)

# Remove NA
Hitters <- na.omit(Hitters)

Hitters$Salary <- factor(1 * (Hitters$Salary > 500))

# Split into test/train
set.seed(1)
train=sample(1:nrow(x), nrow(x)/2)
test=(-train)


# Fit logistic regression with glm()
glm.mdl <- glm(Salary~., data=Hitters[train, ], family=binomial)

# Predict classes for test data
glm.pred <- predict(glm.mdl, newdata=Hitters[test,], type="response")
class.pred <- round(glm.pred)

table(class.pred, y.test)

