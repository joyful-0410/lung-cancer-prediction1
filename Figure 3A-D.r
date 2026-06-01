features<-read.csv('Celldeath_feature.csv',row.names = 1)
library(ConsensusClusterPlus)
title<-"D:/R/X-optosis2/分组"
Fea_1<-as.matrix(t(features[,1:5]))
results<-ConsensusClusterPlus(Fea_1,maxK = 5,
                              reps = 500,
                              pItem = 0.8,
                              pFeature =1,
                              clusterAlg = "km",
                              distance = "pearson",
                              title = title,
                              innerLinkage = "complete",
                              plot = "png")
#K-Mcurve??֤
clusterdata<-as.data.frame(results[[3]]$consensusClass)
colnames(clusterdata)<-"Cluster"
KMcdata<-cbind(features,clusterdata)
library(survival)
library(survminer)
fit<-survfit(Surv(os,status)~Cluster,data=KMcdata)
ggsurvplot(fit,
           pval = TRUE, conf.int = F,
           risk.table = T,
           palette = c("#87CEFA","#5F9EA0","#FFD700",'red'),
)
tiff('Surv.tiff',width = 7,height = 6,units = 'in',res = 300)
dev.off()
##
Fea_1<-features[,c(1,2,4,5,14,15)]
Fea_1$Composite_Score<-apply(Fea_1,1,sum)
Fea_1<-cbind(Fea_1,features$status,features$os)
colnames(Fea_1)[8]<-'status'
colnames(Fea_1)[9]<-'os'
colnames(Fea_1)[6]<-'Apoptosis'
library(survival)
library(survminer)
res.cut<-surv_cutpoint(Fea_1,time = 'os',event = 'status',
                       variables = 'Composite_Score')
tiff('Composite.tiff',width = 5,height = 4,units='in',res = 300)
plot(res.cut, "Composite_Score", palette = "npg")
dev.off()
res.cat <- surv_categorize(res.cut)
fit <- survfit(Surv(os, status) ~Composite_Score, data = res.cat)
tiff('Surv_Group.tiff',width = 7,height = 6,units = 'in',res = 300)
ggsurvplot(fit, data = res.cat, pval = TRUE, conf.int = F,
           risk.table = T,
           palette = c("#EE2C2C","#0000CD"))
dev.off()
#
features<-features[,-3]
colnames(features)[14]<-'Apoptosis'
features$Composite_Score<-Fea_1$Composite_Score
features$ordinal<-c(1:515)
features<-features[order(features$Composite_Score),]
features$Cluster<-rep(c('1','2'),c(129,386))
features<-features[order(features$ordinal),]
features<-features[,-16]
write.csv(features,file = '.\\Composite_Score.csv')
