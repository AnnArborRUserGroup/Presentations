# R code that creates presentation for ASA group
## Created: 4/11/2016
## Modified:
## What is done:
## TO DO:
## ** Notes **

#### Prepare data ####
load("C:/Users/sfgre/Documents/Targeted Learning Presentation/arf.RData")

# Scale cont vars #
library(arm)
cont <- c("age","edu","das2d3pc","aps1","scoma1","meanbp1","wblc1","hrt1",
          "resp1","temp1","pafi1","alb1","hema1","bili1","crea1","sod1",
          "pot1","paco21","ph1","wtkilo1")
arf[,cont] <- data.frame(apply(arf[cont], 2, function(x)
  {x <- rescale(x, "full")})); rm(cont) # standardizes by centering and 
                                        # dividing by 2 sd

# Create dummy vars #
arf$white <- ifelse(arf$race=="white",1,0)  
arf$rhc <- ifelse(arf$swang1=="RHC",1,0)
arf$swang1 <- arf$race <- NULL

arf$death <- arf$dth30; arf$dth30 <- NULL
arf$id <- arf$ptid; arf$ptid <- NULL

#### Prepare Super Learner ####

library(SuperLearner)
# Specify new SL prediction algorithm wrapper for Ridge regression #
SL.glmnet.0 <- function(..., alpha = 0){
  SL.glmnet(..., alpha = alpha) 
  } 

# Specify the SL library with prediction algorithms to be used #

SL.library <- c("SL.glm","SL.bayesglm","SL.earth","SL.gam","SL.glmnet",
                "SL.glmnet.0","SL.knn","SL.step","SL.nnet")

#### Run SuperLearner 1st prediction model ####
colnames(arf)

system.time({
  pm1 <- CV.SuperLearner(Y=arf$death, 
                         X=arf[1:45], 
                         V=10, family=binomial(),
                         SL.library=SL.library, 
                         method="method.NNLS",
                         verbose = TRUE,
                         control = list(saveFitLibrary = TRUE),
                         cvControl = list(V=10), saveAll = TRUE,
                         parallel = 'multicore')
  
})[[3]] # Obtain computation time: 66.689 min.

#### TMLE with SL for Q(Y|W) and lasso for g(A|W) ####
library(tmle)

system.time({
  eff <- tmle(Y=arf$death, 
              A=arf$rhc, 
              W=arf[1:44], 
              Q.SL.library = c("SL.gam","SL.knn","SL.step"),
              g.SL.library = c("SL.glmnet"), family = "binomial",
              cvQinit = TRUE, verbose = TRUE)
  })[[3]] # Obtain computation time: 15.43 min.
or = eff[[1]][["OR"]][["psi"]]
lci = eff[[1]][["OR"]][["CI"]][[1]]
uci = eff[[1]][["OR"]][["CI"]][[2]]
pv = eff[[1]][["OR"]][["pvalue"]]
result = cbind(round(or,2), round(lci,2), round(uci,2), round(pv,3))
print(result); rm(or,lci,uci,pv,result)




