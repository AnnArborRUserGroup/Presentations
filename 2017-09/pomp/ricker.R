p <- c(N.0=68, r=40, k=11,sigma=0.1,phi=1)
sim <- simulate(rickerModel, params = p, nsim=11,as.data.frame=TRUE,include.data=TRUE)
ggplot(data=sim,aes(x=time,y=pop,group=sim,color=(sim=="data")))+
  geom_line()+guides(color=FALSE)+
  facet_wrap(~sim,ncol=3)