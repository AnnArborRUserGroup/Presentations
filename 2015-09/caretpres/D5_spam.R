
# Adapted from http://sux13.github.io/DataScienceSpCourseNotes/8_PREDMACHLEARN/Practical_Machine_Learning_Course_Notes.pdf

# Load the data
library(kernlab);
data(spam);

# Create the data parititions
library(caret);
inTrain = createDataPartition(y=spam$type, p=0.75,list = FALSE);
training = spam[inTrain,];
testing = spam[-inTrain,]

# Run a data through a training function
modelFit = train(training$type ~ ., method="glm", data=training);

# Compare results
confusionMatrix(testing$type, predict(modelFit,testing))
