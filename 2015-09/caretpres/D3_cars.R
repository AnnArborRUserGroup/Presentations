
library(caret);
data(cars);

inTrain = createDataPartition(y=cars$Price, p=0.7, list=FALSE);
training = cars[inTrain,];
testing = cars[-inTrain,];

# Remove near zero and 0.90 correlation columns
comboInfo = findLinearCombos(training);
training = training[,-comboInfo$remove];
testing = testing[,-comboInfo$remove];

# Fit the model
modFit = train(Price ~ ., method="knn", data=training);

# Predict on the test set
pval = predict(modFit, testing);

RMSE(predict(modFit,testing), testing$Price)
R2(predict(modFit,testing), testing$Price)
