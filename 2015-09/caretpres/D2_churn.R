
# Based off the 2014 Max Kuhn presentation
# http://static1.squarespace.com/static/51156277e4b0b8b2ffe11c00/t/5310d223e4b0d21c529a0814/1393611299730/webinar.pdf

library(C50);
library(caret);

# Loads churnTest and churnTrain
data(churn);

predictors = names(churnTrain)[names(churnTrain) != "churn"];

# Put all the data together so we can make our own testing and training data
allData = rbind(churnTest, churnTrain);

# Create the training and testing data
set.seed(1);
inTrainingSet = createDataPartition(allData$churn, p=0.75, list=FALSE);
training = allData[inTrainingSet,];
testing = allData[-inTrainingSet, ]

# Data pre-processing
numerics = c("account_length", "total_day_calls", "total_night_calls");
## Determien means and sds
procValues = preProcess(training[,numerics], method=c("center", "scale", "YeoJohnson"));
## Use the predict method to do the adjustments
trainingScaled = predict(procValues, training[,numerics]);
training[numerics] = trainingScaled;
testingScaled = predict(procValues, testing[,numerics]);
testing[numerics] = testingScaled;

# gbm model fitting
ctrl = trainControl(method="repeatedcv", repeats=5, classProbs = TRUE, summaryFunction = twoClassSummary);
grid = expand.grid(interaction.depth = seq(1,7,by=2), n.trees = seq(100,1000,by=50), shrinkage = c(0.01, 0.1));
gbmTune = train(churn ~ ., data=training, method="gbm", metric="ROC", tuneGrid=grid, verbose=FALSE, trControl=ctrl);

# Plot the results
ggplot(gbmTune)

# Predict the results from the testing set and get the results


