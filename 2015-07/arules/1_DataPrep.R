library(readr)
library(dplyr)
library(tidyr)
library(Matrix)

# import csv or download from source
  if(file.exists('./Data/DOHMH_New_York_City_Restaurant_Inspection_Results.csv')) {
    raw <- read_csv('./Data/DOHMH_New_York_City_Restaurant_Inspection_Results.csv',progress=F)
  } else {
  raw <- read_csv("https://data.cityofnewyork.us/api/views/xx67-kt59/rows.csv?accessType=DOWNLOAD",
           progress=F)
  write_csv(raw, './Data/DOHMH_New_York_City_Restaurant_Inspection_Results.csv')
  }

# import violation code grouping
nyc <- raw
VCwalk <- read_csv("./Data/ViolationCodeWalkover.csv")

# clean up colnames and dates
names(nyc) <- gsub(" ","_",names(nyc))
names(VCwalk) <- gsub(" ","_",names(VCwalk))
nyc$INSPECTION_DATE <- as.Date(nyc$INSPECTION_DATE,format='%m/%d/%Y')
nyc <- nyc[nyc$INSPECTION_DATE!='1900-01-01',]

# clean cuisine desc
nyc$CUISINE_DESCRIPTION <- as.character(nyc$CUISINE_DESCRIPTION)
nyc$CUISINE_DESCRIPTION <- gsub("ÃƒÂ©","e", nyc$CUISINE_DESCRIPTION)
nyc$CUISINE_DESCRIPTION <- gsub("Ã©","e", nyc$CUISINE_DESCRIPTION)
nyc$CUISINE_DESCRIPTION <- gsub( " *\\(.*?\\) *", "", nyc$CUISINE_DESCRIPTION)

# Add manual grouping to violation types
nyc <- inner_join(nyc, VCwalk, by = c("VIOLATION_CODE"))
nyc <- nyc[nyc$VIOLATION_TYPE!="Pass or Not Critical",]

nyc$CUISINE_DESCRIPTION[nyc$CUISINE_DESCRIPTION=="CafÃ©/Coffee/Tea"] <- "Cafe/Coffee/Tea"

# put data in long format in preparation for sparse matrix
nycw <- nyc
nycw$INSID <- paste0(nycw$CAMIS, nycw$INSPECTION_DATE) #create inspection key
#nycw$INSID <- nycw$CAMIS
nycs <- nycw %>%
  select(INSID, BORO, CUISINE_DESCRIPTION, VIOLATION_TYPE) %>%
  gather(MEASURE, VALUE, -INSID)
#nycs$MEASURE <- paste0(nycs$MEASURE, ' : ', nycs$VALUE)
nycs$MEASURE <- nycs$VALUE
nycs$VALUE <- 1

# store values and replace with integer for sparse matrix
ID <- unique(nycs$INSID)
ME <- unique(nycs$MEASURE)
nycs$MEASURE<-match(nycs$MEASURE,ME)
nycs$INSID<-match(nycs$INSID,ID)

# convert to sparse matrix
sm<-sparseMatrix(i=nycs$INSID, j=nycs$MEASURE,x=nycs$VALUE,
                 dimnames=list(ID,ME),giveCsparse=T)

# clean up
rm(nycs,nycw,nyc)
