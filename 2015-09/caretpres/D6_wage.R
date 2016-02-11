
# Adapted from http://sux13.github.io/DataScienceSpCourseNotes/8_PREDMACHLEARN/Practical_Machine_Learning_Course_Notes.pdf

# Get the data
library(ISLR);
library(caret);
data(Wage);

# Partition the data into a training and testing set
inTrain = createDataPartition(y=Wage$wage, p=0.7, list=FALSE);
training = Wage[inTrain,];
testing = Wage[-inTrain,];

# Plot the features
featurePlot(x=training$age, y=training$wage, plot="scatter");

# Fit the model
modFit = train(wage ~ age + jobclass + education, method="lm", data=training);
modFit = train(wage ~ age + jobclass + education, method="lm", 
               preProcess = c("center", "scale", "YeoJohnson"),
               data=training);

# Get the final model information
par(mfrow = c(2,2));
plot(modFit$finalModel)

# Predict on the test set
pval = predict(modFit, testing);

grid = expand.grid(neurons = seq(1,10,by=2));
modFit2 = train(wage ~ age + jobclass + education, method="brnn", data=training);
modFit2 = train(wage ~ age + jobclass + education, method="brnn", data=training, 
                preProcess = c("center", "scale", "YeoJohnson"),
                tuneGrid = grid, verbose=FALSE);
ggplot(modFit2)

grid2 = expand.grid(k = seq(1,20,by=2));
modFit3 = train(wage ~ age + jobclass + education, method="knn", data=training, tuneGrid = grid2, verbose=FALSE);
ggplot(modFit3)

RMSE(predict(modFit,testing), testing$wage)
R2(predict(modFit,testing), testing$wage)

RMSE(predict(modFit2,testing), testing$wage)
R2(predict(modFit2,testing), testing$wage)

RMSE(predict(modFit3,testing), testing$wage)

R2(predict(modFit3,testing), testing$wage)

cvValues = resamples(list(lm=modFit, brnn=modFit2, knn=modFit3));
rocDiffs = diff(cvValues, metric = "RMSE");
summary(rocDiffs);
