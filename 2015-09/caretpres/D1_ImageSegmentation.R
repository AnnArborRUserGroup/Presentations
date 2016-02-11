
# Adapted from http://www.edii.uclm.es/~useR-2013/Tutorials/kuhn/user_caret_2up.pdf

library(caret);

# Load the data
data(segmentationData);
# Remove the Cell numbers since it is not useful for predictive modeling
segmentationData$Cell = NULL;

# Create the testing and training data
training = subset(segmentationData, Case=="Train");
testing = subset(segmentationData, Case="Test");
# Remove the Case field since we no longer need it
training$Case = NULL;
testing$Case = NULL;


# Pre-process the data
trainX = training[, names(training) != "Class"];
preProcValues = preProcess(trainX, method=c("center","scale"));
# Apply to the training set
scaledTrain = predict(preProcValues, trainX);

# Model training
cvCtrl = trainControl(method = "boot", repeats = 3, summaryFunction = twoClassSummary, classProbs = TRUE);
modelFit = train(Class ~ ., data=training, method="rpart", tuneLength=10, metric="ROC", trControl=cvCtrl);
modelFit = train(Class ~ ., data=training, method="rpart", tuneLength=10);
modelFit = train(trainX, training$Class, method="rpart", tuneLength=10, metric="ROC", trControl=cvCtrl);
ggplot(modelFit)

varImp(modelFit)
featurePlot(x=training[,c("FiberWidthCh1","TotalIntenCh2")], y=training$Class, plot = "pairs")

rpartPred = predict(modelFit, testing);
confusionMatrix(rpartPred, testing$Class);

rpartPredp = predict(modelFit, testing, type="prob");

# Create the ROC curve
library(pROC);
rpartROC = roc(testing$Class, rpartPredp[,"PS"], levels=rev(levels(testing$Class)))
plot(rpartROC)

# c5.0 trees
grid = expand.grid(.model = "tree", .trials = c(1:100), .winnow = FALSE);
c5tune = train (trainX, training$Class, method="C5.0", metric="ROC", tuneGrid=grid, trControl = cvCtrl);
c5Pred = predict(c5tune, testing);
confusionMatrix(c5Pred, testing$Class);

c5Probs = predict(c5tune, testing, type="prob");
c5ROC = roc(predictor = c5Probs$PS, response = testing$Class, levels = rev(levels(testing$Class)));

plot(rpartROC)
# par(new=TRUE)
plot(c5ROC, add=TRUE, col="#9E0142")

#histogram(~c5Probs$PS|testing$Class, xlab="Probablity of Poor Segmentation");
#histogram(~c5Probs$WS|testing$Class, xlab="Probablity of Well Segmentation");

# SVM models
set.seed(1);
# library(doSMP);
# registerDoMC(cores=2);
svmTune = train(x=trainX, y=training$Class, method="svmRadial", tuneLength=9, preProc = c("center","scale"), 
                metric="ROC", trControl = cvCtrl);

svmPred = predict(svmTune, testing[, names(testing)!="Class"]);
confusionMatrix(svmPred, testing$Class);

svmProbs = predict(svmTune, testing[,names(testing)!="Class"], type="prob");
svmROC = roc(predictor = svmProbs$PS, response = testing$Class, levels = rev(levels(testing$Class)));
plot(svmROC, add=TRUE, col="#019E42")

# Comparing models
#cvValues = resamples(list(CART=modelFit, SVM=svmTune, C5.0=c5tune));
cvValues = resamples(list(CART=modelFit, SVM=svmTune));
splom(cvValues, metric="ROC")
parallelplot(cvValues, metric="ROC")
dotplot(cvValues, metric="ROC")

rocDiffs = diff(cvValues, metric="ROC")
summary(rocDiffs)
dotplot(rocDiffs, metric="ROC")

rocDiffs = diff(cvValues, metric = "ROC");
summary(rocDiffs);
