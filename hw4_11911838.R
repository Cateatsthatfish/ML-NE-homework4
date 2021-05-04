library(R.utils)
library(rjags) 
grabfun<-function(x,p,var) {return(x[x$subj==p,var])} 

itcdata<-read.csv("output2.csv",header=TRUE) # requirement 2
subjects <- unique(itcdata$subj)  
ntrials  <- dim(itcdata)[1]/length(unique(itcdata$subj))
nsubj    <- length(unique(itcdata$subj)) 

delays4A  <- t(vapply(subjects,FUN=function(x) grabfun(itcdata,x,"DA"),integer(ntrials))) 
delays4B  <- t(vapply(subjects,FUN=function(x) grabfun(itcdata,x,"DB"),integer(ntrials)))
amounts4A <- t(vapply(subjects,FUN=function(x) grabfun(itcdata,x,"A"),integer(ntrials)))
amounts4B <- t(vapply(subjects,FUN=function(x) grabfun(itcdata,x,"B"),integer(ntrials)))
responses <- t(vapply(subjects,FUN=function(x) grabfun(itcdata,x,"R"),integer(ntrials)))

#initialize model for JAGS
hierITC <- jags.model("Lecture14_4_hierarchicalITC.j",  
                      data = list("nsubj"=nsubj,
                                  "DA"=delays4A,
                                  "DB"=delays4B,
                                  "A"=amounts4A,
                                  "B"=amounts4B,
                                  "T"=ntrials,
                                  "R"=responses),                   
                      n.chains=4)  
# burnin
update(hierITC,n.iter=1000)  
# perform MCMC
# requirement 1
# parameters <- c("k", "alpha", "groupkmu", "groupksigma", "groupALPHAmu", "groupALPHAsigma",
#                "VA","VB","P","DB") 

# requirement 2
parameters <- c("k") 
mcmcfin<-coda.samples(hierITC,parameters,5000) 
sum = summary(mcmcfin)
print(sum)

# requirement 3
k = sum$statistics 
subj_k = k[,"Mean"] 
features = read.csv("output3.csv",header=TRUE)
new_feature = cbind(features,k=subj_k)
# t-test
t.test(new_feature$k~new_feature$gender)

# requirement 4
# covariance
cov(new_feature$personal.characteristics, new_feature$k)
# correlation : 
cor(new_feature$personal.characteristics, new_feature$k)
# plot (scatter)
plot(new_feature$personal.characteristics, new_feature$k)

# requirement 5
# t-test
t.test(new_feature$k~new_feature$single) 
# correlation 
cor(new_feature$single, new_feature$k)
