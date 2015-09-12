
library(QSARdata);
data(MeltingPoint);

training = cbind(MP_Descriptors[MP_Data == "Train", ], MP_Outcome[MP_Data=="Train"]);
testing = cbind(MP_Descriptors[MP_Data == "Test", ], MP_Outcome[MP_Data=="Test"]);

colnames(training) = c(colnames(MP_Descriptors), "MeltingPt");
colnames(testing) = c(colnames(MP_Descriptors), "MeltingPt");

# Remove near zero and 0.90 correlation columns
nzcols = nearZeroVar(training);
training = training[,-nzcols];
testing = testing[,-nzcols];

descrCorr = cor(training);
highCorr = findCorrelation(descrCorr, 0.90);
training = training[,-highCorr];
testing = testing[,-highCorr];

comboInfo = findLinearCombos(training);
training = training[,-comboInfo$remove];
testing = testing[,-comboInfo$remove];

# Fit the model
modFit = train(MeltingPt ~ ., method="lm", data=training);

#modFit2 = train(MeltingPt ~ ., method="neuralnet", data=training);

# Get the final model information
par(mfrow = c(2,2));
plot(modFit$finalModel)

# Predict on the test set
pval = predict(modFit, testing);

RMSE(predict(modFit,testing), testing$MeltingPt)
R2(predict(modFit,testing), testing$MeltingPt)
