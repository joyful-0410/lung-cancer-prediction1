Expr<-read.csv('D://R/Cuproptosis/肺腺癌/DEGs/TCGA-LUAD-Gene.csv',row.names = 1)
degs<-read.csv('.\\DEGs.csv')
ori<-read.csv('.\\Celldeath_Score.csv',row.names = 1)
degs<-degs$x
modeling<-Expr[degs,]
modeling<-data.frame(t(modeling))
modeling<-2^(modeling)-1
library(glmnet)
X<-as.matrix(modeling[,1:107]) 
Y<-as.matrix(ori[,7])
lasso <- glmnet(X,Y,alpha = 1,family = 'gaussian') 
print(lasso)
tiff('LASSO.tiff',width = 8,height = 10,units = 'in',res = 300)
plot(lasso,xvar = "lambda",label="true") 
dev.off()
lasso.coef <- coef(lasso,s=5)
lasso.coef
lambdas<- exp(seq(-3,5,length.out=200))
set.seed(100)
cv.lasso <- cv.glmnet(X,Y,alpha=1,lambda=lambdas,nfolds=5,family="gaussian")
tiff('Lambda.tiff',width = 8,height = 5,units = 'in',res = 300)
plot(cv.lasso)
dev.off()
lasso.min <- cv.lasso$lambda.min
lasso.1se<-cv.lasso$lambda.1se
lasso.coef <- coef(cv.lasso$glmnet.fit,s=lasso.min,exact=F)
lasso.coef
attach(modeling)
modeling$Score<-(IDO1*4.06-GJB2*22.15-PTAFR*5.67-BIRC3*27.53)
ori$Celldeath_Score<-modeling$Score
library(survival)
library(survminer)
res.cut<-surv_cutpoint(ori,time = 'os',event = 'status',
                       variables = 'Celldeath_Score')
tiff('Celldeath_Score.tiff',width = 5,height = 5,units='in',res = 300)
plot(res.cut, "Celldeath_Score", palette = "npg")
dev.off()
res.cat <- surv_categorize(res.cut)
fit <- survfit(Surv(os, status) ~Celldeath_Score, data = res.cat)
tiff('Surv.tiff',width = 7,height = 6,units = 'in',res = 300)
ggsurvplot(fit, data = res.cat, pval = TRUE, conf.int = F,
           risk.table = T,
           palette = c("#EE2C2C","#0000CD"))
dev.off()
#
library(timeROC)
ROC_m<-timeROC(T=ori$os,delta = ori$status,
               marker = -ori$Celldeath_Score,cause = 1,
               weighting = 'marginal',times = c(365,1095,1825),ROC = TRUE) 
tiff('AUC.tiff',width = 5,height = 6.5,units = 'in',res = 300)
plot(ROC_m,time = 365,title = '',lwd=5)
plot(ROC_m,time = 1095,add=T,col = '#87CEFA',lwd=5)
plot(ROC_m,time = 1825,add=T,col = '#FFD700',lwd=5)
legend(0.5,0.15,
       c('AUC at 1 year=0.635','AUC at 3 years=0.628','AUC at 5 years=0.631'),
       col = c('red','#87CEFA',"#FFD700"),lty =1,
       lwd = 5,bty = 'n',cex = 0.7)
dev.off()
#
ori<-ori[order(ori$Celldeath_Score),]
ori$Group<-rep(c('Low_Score','High_Score'),c(187,328))
library(sankeywheel)
sankeywheel(from = ori$Cluster,to=ori$Group,type = 'sankey',
            width = '100%',weight = ori$Cluster)
library(ggalluvial)
library(ggplot2)
colors<-c("#1C86EE","#CD0000")
ori$Cluster<-as.factor(ori$Cluster)
ori$Group<-as.factor(ori$Group)
ggplot(data = ori,       
       aes(axis1 = Cluster, axis2 = Group)) +
  geom_alluvium(aes(fill = Cluster)) +  
  geom_stratum() +  geom_text(stat = "stratum", aes(label = after_stat(stratum))) +  
  theme_minimal()+scale_fill_manual(values = colors)+theme_classic()+labs(alpha=0)
ggsave('sankey.png',width = 5,height = 5,units = 'in',dpi = 300)
#
library(ggDCA)
library(rmda)
library(survival)
ori$os<-ori$os/365
Celldeath_Score<-coxph(Surv(os,status)~Celldeath_Score,data = ori)
ori$Clinical_Stage<-gsub('III','3',ori$Clinical_Stage)
ori$Clinical_Stage<-gsub('II','2',ori$Clinical_Stage)
ori$Clinical_Stage<-gsub('I','1',ori$Clinical_Stage)
ori$Clinical_Stage<-as.numeric(ori$Clinical_Stage)
ClinicalStage<-coxph(Surv(os,status)~Clinical_Stage,data = ori)
fig1<-dca(Celldeath_Score,ClinicalStage,times=5)
ggplot(fig1)+scale_x_continuous(breaks = seq(0,1,by=0.1)) 
ggsave('DACcurve.tiff',width = 5.5,height = 4,units = 'in',dpi = 300)
#
devtools::install_github('yikeshu0611/ggDCA')
