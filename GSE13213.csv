GSE50081<-read.csv('.\\GSE13213.csv',row.names = 1)
attach(GSE50081)
GSE50081$Celldeath_Score<-(IDO1*4.06-GJB2*22.15-PTAFR*5.67-BIRC3*27.53)
library(survival)
library(survminer)
res.cut<-surv_cutpoint(GSE50081,time = 'os',event = 'status',
                       variables = 'Celldeath_Score')
tiff('Celldeath_Score.tiff',width = 5,height = 5,units='in',res = 300)
plot(res.cut, "Celldeath_Score", palette = "npg")
dev.off()
res.cat <- surv_categorize(res.cut)
fit <- survfit(Surv(os, status) ~Celldeath_Score, data = res.cat)
tiff('Surv13213.tiff',width = 7,height = 6,units = 'in',res = 300)
ggsurvplot(fit, data = res.cat, pval = TRUE, conf.int = F,
           risk.table = T,
           palette = c("#EE2C2C","#0000CD"))
dev.off()
