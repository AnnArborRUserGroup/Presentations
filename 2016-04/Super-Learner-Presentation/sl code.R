rhc <- read.csv("E:/KSU stuff/Course materials/Survival course/Resources/Code and data sets/Right Heart Catheterization Dataset/rhc2.csv")

# Subset data to include only ARF subjects
arf <- subset(rhc, cat1=='ARF') 
# delete unused variables
arf$cat1 <- arf$cat2 <- arf$cancer <- arf$sadmdte  <- arf$dschdte	<- 
  arf$dthdte	<- arf$lstctdte <- arf$t3d30 <-
  arf$death <- arf$surv2md1  <- arf$ortho <- arf$adld3p <- arf$urin1 <- 
  arf$strat <- arf$income <- arf$ninsclas <- NULL
rm(rhc) # remove rhc2 dataset

library(rms) # Load RMS package
# Descriptives
describe(arf,digits=2)

save(arf, file ="C:/Users/sfgre/Documents/Targeted Learning Presentation/arf.RData")

#### Prepare data ####

# Impute missing X values #
library("VIM")

# Scale cont vars #
library(arm)
cont <- c("age","edu","das2d3pc","aps1","scoma1","meanbp1","wblc1","hrt1",
          "resp1","temp1","pafi1","alb1","hema1","bili1","crea1","sod1",
          "pot1","paco21","ph1","wtkilo1")
arf[,cont] <- data.frame(apply(arf[cont], 2, function(x)
  {x <- rescale(x, "full")})); rm(cont)

# Create dummy vars #
arf$rhc <- ifelse(arf$swang1=="RHC",1,0)
arf$white <- ifelse(arf$race=="white",1,0)  
arf$swang1 <- arf$race <- NULL

#### Prepare Super Learner ####
install.packages (c ("glmnet","randomForest","class","gam","gbm","nnet",
                     "polspline","MASS","e1071","stepPlr","arm","party",
                     "spls","LogicReg","nnls","multicore","SIS","BayesTree",
                     "ipred","mlbench","rpart","caret","mda","earth"))


library(SuperLearner)
listWrappers()
SL.glmnet


