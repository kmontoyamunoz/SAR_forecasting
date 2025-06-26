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
#clear all
rm(list=ls())
# parallel set
numCores <- detectCores()
registerDoParallel(numCores) 

#set country and dir
setwd("C:\\Users\\wb520054\\OneDrive - WBG\\02_SAR Stats Team\\Microsimulations\\Regional model\\PEA_BGD\\BGD\\Data")
#setwd("C:\\Users\\wb520054\\OneDrive - WBG\\02_SAR Stats Team\\Microsimulations\\Regional model\\PEA_BGD\\BGD\\Data\\Baseline")

year=2024
dbversion="_dom_no_int_yes_inc_no"
macro_cons_gr=0.038158766
#                 2023        2024        2025        2026        2027
# Baseline        0.010543907	0.038158766	0.102915238	0.175642108 0.256656636
# Crisis          0.010543907	0.038158766	0.068995198	0.109426486 0.158856363

inputfile=paste("BGD_",year,"_6s",dbversion,"_cons_no.dta",sep="")
cpi2017=1.338891
icp2017=29.514082
#receiver
samp.b=read.dta13(inputfile,nonint.factors = TRUE,generate.factors = TRUE)
samp.b=subset(samp.b,h_head==1)
#samp.b$welfare_ppp17=with(samp.b,(12/365)*welfarenat/cpi2017/icp2017)
samp.b$welfare_base=with(samp.b,(12/365)*welfare_ppp)
samp.b$vtil=xtile(samp.b$welfare_base,n=20,wt=samp.b$fexp_base)
samp.b$h_fexp_base=samp.b$fexp_base * samp.b$h_size
samp.b$h_fexp_s=samp.b$fexp_s * samp.b$h_size
samp.b=samp.b[!is.na(samp.b$region) & !is.na(samp.b$vtil) &
                !is.na(samp.b$age) & !is.na(samp.b$urban)  & 
                !is.na(samp.b$h_fexp_base) ,]
samp.b$ratio_orig=samp.b$pc_inc_base/samp.b$welfare_base


#donor
samp.a=samp.b
samp.a$ratio=samp.a$pc_inc_base/samp.a$welfare_base
samp.a$pc_inc_s = samp.a$pc_inc_base

group.v <- c("region","vtil","urban")  # donation classes
X.mtc=c("age","h_size","pc_inc_s") 
set.seed(123456)
rnd.2 <- RANDwNND.hotdeck(data.rec=samp.b, data.don=samp.a,
                          match.vars=X.mtc, don.class=group.v,
                          dist.fun="Euclidean",
                          cut.don="min")
#Create synthetic panel
fA.wrnd <- create.fused(data.rec=samp.b, data.don=samp.a,
                        mtc.ids=rnd.2$mtc.ids,
                        z.vars=c("ratio"))


#avgratio=wtd.mean(fA.wrnd$ratio,fA.wrnd$pop_wgt)
fA.wrnd$ratio=ifelse(abs((fA.wrnd$ratio_orig-fA.wrnd$ratio)/fA.wrnd$ratio_orig)>0.2,
                     fA.wrnd$ratio_orig,fA.wrnd$ratio)

fA.wrnd$ratio=ifelse(is.na(fA.wrnd$ratio),fA.wrnd$ratio_orig,fA.wrnd$ratio)

#fA.wrnd$ratio=ifelse(fA.wrnd$ratio==0,avgratio,fA.wrnd$ratio)

fA.wrnd$welfare_s=fA.wrnd$pc_inc_s/fA.wrnd$ratio


fA.wrnd$welfare_s=ifelse(fA.wrnd$ratio<=0,
                         fA.wrnd$welfare_base*(1+macro_cons_gr),
                         fA.wrnd$welfare_s)
#actual_cons_gr=wtd.mean(fA.wrnd$welfare_ppp17_s,fA.wrnd$pop_wgt)/
#  wtd.mean(fA.wrnd$welfare_ppp17,fA.wrnd$pop_wgt)-1

#rescaling
fA.wrnd$welfare_s=fA.wrnd$welfare_s*wtd.mean(fA.wrnd$welfare_base,
    fA.wrnd$h_fexp_base)*(1+macro_cons_gr)/wtd.mean(fA.wrnd$welfare_s,
                                                fA.wrnd$h_fexp_s)


des <- svydesign(ids = ~hhid, data = fA.wrnd, weights = ~h_fexp_s)
des <- convey_prep(des)

#line
results=numeric()
lines=c(2.15,3.65,6.85)

for (line in lines){
poverty_hc <- svyfgt(~welfare_s, design = des, abs_thresh = line, g = 0,
                     na.rm = TRUE)
coef(poverty_hc)
#poverty gap
poverty_gap <- svyfgt(~welfare_s, design = des, abs_thresh = line, g = 1,
                      na.rm = TRUE)
coef(poverty_gap)
#poverty severity
poverty_sev <- svyfgt(~welfare_s, design = des, abs_thresh = line, g = 2,
                      na.rm = TRUE)
coef(poverty_sev)
resultstemp=c(coef(poverty_hc),coef(poverty_gap),coef(poverty_sev))
results=append(results,resultstemp)
}
results=append(results,gini.wtd(fA.wrnd$welfare_s,fA.wrnd$h_fexp_s))
results


# Define urban and rural subsets
areas <- c("Urban","Rural")

for (area in areas) {
  # Filter design object by area
  des_area <- subset(des, urban == area)
  
  for (line in lines) {
    # Poverty headcount
    poverty_hc <- svyfgt(~welfare_s, design = des_area, abs_thresh = line, g = 0, na.rm = TRUE)
    coef_hc <- coef(poverty_hc)
    
    # Poverty gap
    poverty_gap <- svyfgt(~welfare_s, design = des_area, abs_thresh = line, g = 1, na.rm = TRUE)
    coef_gap <- coef(poverty_gap)
    
    # Poverty severity
    poverty_sev <- svyfgt(~welfare_s, design = des_area, abs_thresh = line, g = 2, na.rm = TRUE)
    coef_sev <- coef(poverty_sev)
    
    # Combine results
    resultstemp <- c(coef_hc, coef_gap, coef_sev)
    results <- append(results, resultstemp)
  }
  
  # Gini coefficient for the area
  gini_value <- gini.wtd(fA.wrnd$welfare_s[fA.wrnd$urban == area], fA.wrnd$h_fexp_s[fA.wrnd$urban == area])
  results <- append(results, gini_value)
}

results


# Define east and west subsets
regions <- list(
  east = c("10-Barisal","30-Dhaka", "20-Chittagong", "45-Mymensingh", "60-Sylhet"),
  west = c("55-Rangpur", "50-Rajshahi", "40-Khulna")
)

regions

for (region2 in names(regions)) {
  # Filter design object by region
  des_region <- subset(des, region %in% regions[[region2]])  # Replace 'region_column' with your actual column name
  
  for (line in lines) {
    # Poverty headcount
    poverty_hc <- svyfgt(~welfare_s, design = des_region, abs_thresh = line, g = 0, na.rm = TRUE)
    coef_hc <- coef(poverty_hc)
    
    # Poverty gap
    poverty_gap <- svyfgt(~welfare_s, design = des_region, abs_thresh = line, g = 1, na.rm = TRUE)
    coef_gap <- coef(poverty_gap)
    
    # Poverty severity
    poverty_sev <- svyfgt(~welfare_s, design = des_region, abs_thresh = line, g = 2, na.rm = TRUE)
    coef_sev <- coef(poverty_sev)
    
    # Combine results
    resultstemp <- c(coef_hc, coef_gap, coef_sev)
    results <- append(results, resultstemp)
  }
  
  # Gini coefficient for the region
  gini_value <- gini.wtd(fA.wrnd$welfare_s[fA.wrnd$region %in% regions[[region2]]],
                         fA.wrnd$h_fexp_s[fA.wrnd$region %in% regions[[region2]]])
  results <- append(results, gini_value)
}

results

write.csv(100*results,paste("results_",year,dbversion,"_cons_yes.csv",sep=""))

