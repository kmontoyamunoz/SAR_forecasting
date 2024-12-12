#load required libraries
library(StatMatch)
library(survey)
library(questionr)
library(reldist)
library(glmnet)
library(useful)
library(data.table)
library(readstata13)
library(statar)
library(parallel)
library(foreach)
library(doParallel)
library(dplyr)
library(dineq)
library(survey)
library(convey)
library(foreign)

# clear all
rm(list=ls())

# parallel set
numCores <- detectCores()
registerDoParallel(numCores) 

# input file
inputfile=paste("simulated.dta",sep="")

# receiver
samp.b=read.dta13(inputfile,nonint.factors = TRUE,generate.factors = TRUE)
samp.b=subset(samp.b,hh_sample==1)

#donor
samp.a=samp.b
samp.a$ratio=samp.a$pc_inc_base/samp.a$welfare_base
samp.a$pc_inc_s = samp.a$pc_inc_base

# donation classes and variables
group.v <- c("region","vtile","urban")  
X.mtc=c("age","h_size","pc_inc_s") 

# matching
set.seed(123456)
rnd.2 <- RANDwNND.hotdeck(data.rec=samp.b, data.don=samp.a,
                          match.vars=X.mtc, don.class=group.v,
                          dist.fun="Euclidean",
                          cut.don="min")

#Create synthetic panel
fA.wrnd <- create.fused(data.rec=samp.b, data.don=samp.a,
                        mtc.ids=rnd.2$mtc.ids,
                        z.vars=c("ratio"))

# fA.wrnd$ratio=ifelse(abs((fA.wrnd$orig_ratio-fA.wrnd$ratio)/fA.wrnd$orig_ratio)>0.2,
#                      fA.wrnd$orig_ratio,fA.wrnd$ratio)
# 
# fA.wrnd$ratio=ifelse(is.na(fA.wrnd$ratio),fA.wrnd$orig_ratio,fA.wrnd$ratio)
# 
# fA.wrnd$welfare_s=fA.wrnd$pc_inc_s/fA.wrnd$ratio
# 
# fA.wrnd$welfare_s=ifelse(fA.wrnd$ratio<=0,
#                          fA.wrnd$welfare_base*(1+fA.wrnd$growth_cons),
#                          fA.wrnd$welfare_s)
# 
# #rescaling
# fA.wrnd$welfare_s=fA.wrnd$welfare_s*wtd.mean(fA.wrnd$welfare_base,
#     fA.wrnd$h_fexp_base)*(1+fA.wrnd$growth_cons)/wtd.mean(fA.wrnd$welfare_s,
#                                                 fA.wrnd$h_fexp_s)

# Saving
fA.wrnd[fA.wrnd == ""] <- NA
write.dta(fA.wrnd,"matching_output.dta")
