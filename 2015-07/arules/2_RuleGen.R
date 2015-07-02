require(arules)

# convert to transaction object format
sm2<-as(t(sm),"nsparseMatrix")
sm2<-as(sm2,"transactions")

# Filter RHS to include only rules with outcomes that are violations
outcomelist <- ME[c(91:97)]
  
#rule generation
rules <- apriori(sm2,
                   parameter = list(minlen=1, supp=0.008, conf=0.45, maxlen=4),
                   appearance = list(rhs=outcomelist, 
                                     default="lhs"),
                   control = list(verbose=T))
rules.sorted<-sort(rules,by="lift")

# remove redunant rules
subset.matrix<-is.subset(rules.sorted, rules.sorted)
subset.matrix[lower.tri(subset.matrix,diag=T)]<-NA
redundant<-colSums(subset.matrix,na.rm=T)>=1
rules<-rules.sorted[!redundant]

# create nice rules data.frame
rf<-data.frame(
  lhs = labels(lhs(rules))$elements,
  rhs = labels(rhs(rules))$elements,
  rules@quality)
rf<-rf[order(-rf$lift),]
#rf<-rf[order(-rf$support),]

# format for extracting transaction IDs
st<-supportingTransactions(rules,sm2)
tids<-as(st,"list")
rm(subset.matrix, redundant, rules.sorted)
