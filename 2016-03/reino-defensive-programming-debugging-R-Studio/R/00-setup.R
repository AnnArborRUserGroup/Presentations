#### Preloads the UI enviorment ####
## Auto Package loader ##
package.loader <- function(list.of.packages) {
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  # load packages that are already installed
  lapply(list.of.packages, library, character.only = TRUE)
  }
## List of sourced packages ##
list.of.packages <-c("shiny", "rmarkdown", "stringr",
                     "ggplot2", "png","grid",  "gridExtra",# "ggvis","dygraphs",
                     "heplots",# "reshape2", "survival", "survAUC", "digest",
                     "scales", "aod", "flux",  "devtools","KMsurv",#"rms",
                     "plyr","pryr", "MASS", "Hmisc", "splines",#  "DAAG",
                     "httpuv",  "data.table")
package.loader(list.of.packages)
list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if (!length(intersect('revealjs', installed.packages()[,"Package"]))) {
  devtools::install_github("jjallaire/revealjs")
  }
library('revealjs')
rm(list = c("list.of.packages","package.loader"))
