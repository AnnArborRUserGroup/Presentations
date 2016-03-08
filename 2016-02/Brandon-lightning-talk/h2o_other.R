# upload csvs
train.hex <- h2o.uploadFile("train.csv",destination_frame = "train.hex")
test.hex <- h2o.uploadFile("test.csv",destination_frame = "test.hex")
train.hex$Survived <- as.factor(train.hex$Survived)
train.hex$Pclass <- as.factor(train.hex$Pclass)
test.hex$Pclass <- as.factor(test.hex$Pclass)

titanic <- h2o.splitFrame(train.hex, ratios = .7)

model_gbm <- h2o.gbm(
  x = c(3,5:8,10,12),
  y = 2,
  training_frame = titanic[[1]],
  validation_frame = titanic[[2]],
  ntrees = 100,
  max_depth = 4
)
model_glm <- h2o.glm(
  x = c(3,5,6,10,12),
  y = 2,
  training_frame = titanic[[1]],
  validation_frame = titanic[[2]],
  family = "binomial", link = "logit"
)
model_rf <- h2o.randomForest(
  x = c(3,5,6,10,12),
  y = 2,
  training_frame = titanic[[1]],
  validation_frame = titanic[[2]],
  ntrees = 500,
  max_depth = 4
)
# scoring history plot
plot(model)

# Variable Importance
View(as.data.frame(h2o.varimp(model)),"VarImp")
# ROC curve
model_perf <- h2o.performance(model, data = titanic[[2]])
plot(model_perf)

# predict on new data
pred <- h2o.predict(model_glm,test.hex)

# kaggle submission
submission <- data.frame(PassengerID = as.vector(test.hex[,1]),
                         Survived = as.vector(pred[,1]))
write.csv(submission,"submission.csv",row.names=F)
