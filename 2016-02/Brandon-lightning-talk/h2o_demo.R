library(h2o)

# intialize h2o JVM or connects to existing
localH2O <- h2o.init() 
h2o.removeAll()

# upload csvs
train.hex <- h2o.uploadFile("train.csv",destination_frame = "train.hex")
test.hex <- h2o.uploadFile("test.csv",destination_frame = "test.hex")
train.hex$Survived <- as.factor(train.hex$Survived)
train.hex$Pclass <- as.factor(train.hex$Pclass)

# extract R data.frame from h2o frame
# train <-  as.data.frame(train.hex)

# list all h2o objects
h2o.ls()
summary(train.hex)

# create train and test sets.  Output is a list of frames
titanic <- h2o.splitFrame(train.hex, ratios = .7)

# train deep NN with minimal parameters
model_dl <- h2o.deeplearning(
  model_id = "model_dl",
  x = c(3,5:8,10,12),
  y = 2,
  training_frame = titanic[[1]],
  validation_frame = titanic[[2]],
#  training_frame = train.hex,
#  nfolds = 5,
  activation = "TanhWithDropout",
  hidden = c(30,30),
  epochs = 2000,
  variable_importances = T,
  shuffle_training_data = T,
  hidden_dropout_ratios = c(.5,.5),
  score_interval = .01,
  adaptive_rate = F, # changed after the presentation
  rho = .99,
  epsilon = 1e-08,
  rate = .00001, # changed after the presentation
  rate_annealing = 1e-06,
  rate_decay = 1
)
# scoring history plot
plot(model_dl)

# Variable Importance
View(as.data.frame(h2o.varimp(model_dl)),"VarImp")
# ROC curve
dl <- h2o.performance(model_dl, data = titanic[[2]])
plot(dl)

# predict on new data
pred <- h2o.predict(model_dl,test.hex)

# kaggle submission
submission <- data.frame(PassengerID = as.vector(test.hex[,1]),
                            Survived = as.vector(pred[,1]))
write.csv(submission,"submission.csv",row.names=F)
