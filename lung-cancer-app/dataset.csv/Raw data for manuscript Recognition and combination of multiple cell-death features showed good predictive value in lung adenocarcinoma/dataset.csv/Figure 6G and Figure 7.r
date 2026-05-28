Im<-read.csv('.\\IMvigor210_Death.csv',row.names = 1)
Im1<-Im[order(Im$Celldeath_Score),]
Im1$Celldeath_Score<-rep(c('low','high'),c(174,174))
library(survival)
library(survminer)
res.cut<-surv_cutpoint(Im,time = 'time',event = 'status',
                       variables = 'Celldeath_Score')
plot(res.cut, "Celldeath_Score", palette = "npg")
res.cat <- surv_categorize(res.cut)
fit <- survfit(Surv(time, status) ~Celldeath_Score, data = res.cat)
tiff('Surv_Im.tiff',width = 7,height = 6,units = 'in',res = 300)
ggsurvplot(fit, data = res.cat, pval = TRUE, conf.int = F,
           risk.table = T,
           palette = c("#EE2C2C","#0000CD"))
dev.off()
#
fit<-survfit(Surv(time,status)~Celldeath_Score,data = Im1)
ggsurvplot(fit, data = Im1, pval = TRUE, conf.int = F,
           risk.table = T,
           palette = c("#EE2C2C","#0000CD"))
#
library(ggplot2)
library(ggpubr)
library(tidyr)
Im2<-read.csv('.\\IMvigor210_Death.csv',row.names = 1)
Im2<-Im2%>%drop_na(BOR_binary)
Im2$BOR_binary<-as.factor(Im2$BOR_binary)
ggplot(Im2,aes(x=BOR_binary,y=Celldeath_Score))+geom_boxplot(fill=c("#EE2C2C","#4169E1"))+
  theme_classic()+stat_compare_means()
ggsave('Im_bar.tiff',width = 3.5,height = 6,units = 'in',dpi = 300)
#
Im3<-Im%>%drop_na(TMB)
ggscatter(Im3, x = "Celldeath_Score", y = "TMB", 
          add = "reg.line",size = 1, conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",color = '#87CEEB')
ggplot(Im1,aes(x=Celldeath_Score,y=TNB))+geom_boxplot(fill=c("#EE2C2C","#4169E1"))+
  theme_classic()+stat_compare_means()
ggsave('TMB.tiff',dpi=300,width = 4.5,height = 3)
#
tumor<-read.csv('.\\tumor.csv',row.names = 1)
normal<-read.csv('.\\normal.csv',row.names = 1)
tumor$Sample<-'Tumor'
normal$Sample<-'Normal'
tumor1<-tumor[,-c(5,6)]
tumor1<-rbind(tumor1,normal)
tumor1$Sample<-as.factor(tumor1$Sample)
ggplot(tumor1,aes(x=Sample,y=BIRC3))+geom_boxplot(fill=c("#EE2C2C","#4169E1"))+
  theme_classic()+stat_compare_means()
ggsave('BIRC3.tiff',width = 3.5,height = 6,units = 'in',dpi = 300)
#
library(survival)
library(forestplot)
fit1<-coxph(Surv(os,status)~BIRC3,data = tumor)
summary(fit1)
COX<-read.csv('.\\MuCOX.csv')
COX<-rbind(c('Gene',NA,NA,NA,'HR(95%CI)','p'),COX)
COX$X.2<-as.numeric(COX$X.2)
COX$X<-as.numeric(COX$X)
COX$X.1<-as.numeric(COX$X.1)
tiff('forest-uni.tiff',width = 6,height = 5,units = 'in',res = 300)
fig1<- forestplot(COX[,c(1,5,6)], 
                  mean=COX[,2],   
                  lower=COX[,3],  
                  upper=COX[,4],  
                  zero=1,
                  clip=c(0.5,1.5),
                  boxsize=0.1,       
                  graph.pos=3,
                  xlab='Hazard ratio',
                  col=fpColors(box = '#0000CD'),
                  graphwidth=unit(50,'mm'))
fig1
dev.off()
#
library(survival)
library(survminer)
res.cut<-surv_cutpoint(tumor,time = 'os',event = 'status',
                       variables = 'BIRC3')
plot(res.cut, "BIRC3", palette = "npg")
res.cat <- surv_categorize(res.cut)
fit <- survfit(Surv(os, status) ~BIRC3, data = res.cat)
tiff('Surv_BIRC3.tiff',width = 7,height = 6,units = 'in',res = 300)
ggsurvplot(fit, data = res.cat, pval = TRUE, conf.int = F,
           risk.table = T,
           palette = c("#EE2C2C","#0000CD"))
dev.off()
