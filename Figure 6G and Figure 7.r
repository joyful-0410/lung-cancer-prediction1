ori<-read.csv('.\\Celldeath_Score.csv',row.names = 1)
age<-read.csv('.\\age.csv')
age<-age[,-1]
ori$id<-rownames(ori)
ori$id<-substr(ori$id,1,12)
ori$id<-gsub('.','-',ori$id,fixed = T)
colnames(age)[1]<-'id'
colnames(age)[2]<-'age'
library(dplyr)
ori<-left_join(ori,age,by='id')
library(survival)
library(rms)
ori$Gender<-as.factor(ori$Gender)
dd<-datadist(ori)
options(datadist="dd")
fit<-cph(Surv(os,status)~age+Clinical_Stage+Celldeath_Score,
           data=ori,surv = T)
survival<-Survival(fit)
survival1<-function(x)survival(1,x)
survival3<-function(x)survival(3,x)
survival5<-function(x)survival(5,x)
nom<-nomogram(fit,fun = list(survival1,survival3,survival5),
              fun.at = c(0.05,seq(0.1,0.9,by=0.1),0.95),
              funlabel = c('1 year survival','3 year survival','5 year survival')
)
tiff('nomogram.tiff',width = 8,height = 6,units = 'in',res = 300)
plot(nom)
dev.off()
#
library(nomogramFormula)
results<-formula_rd(nomogram=nom)
library(tidyverse)
ori1<-ori%>%drop_na(Clinical_Stage,age)
ori1<-ori1[,c(6,7,8,14,18)]
ori1$Combined_Score<-points_cal(formula = results$formula,rd=ori1)
library(timeROC)
ROC_m<-timeROC(T=ori1$os,delta = ori1$status,
               marker = ori1$Combined_Score,cause = 1,
               weighting = 'marginal',times = c(1,3,5),ROC = TRUE) 
tiff('AUC.tiff',width = 5,height = 6.5,units = 'in',res = 300)
plot(ROC_m,time = 1,title = '',lwd=5)
plot(ROC_m,time = 3,add=T,col = '#87CEFA',lwd=5)
plot(ROC_m,time = 5,add=T,col = '#FFD700',lwd=5)
legend(0.5,0.15,
       c('AUC at 1 year=0.727','AUC at 3 years=0.699','AUC at 5 years=0.693'),
       col = c('red','#87CEFA',"#FFD700"),lty =1,
       lwd = 5,bty = 'n',cex = 0.7)
dev.off()
