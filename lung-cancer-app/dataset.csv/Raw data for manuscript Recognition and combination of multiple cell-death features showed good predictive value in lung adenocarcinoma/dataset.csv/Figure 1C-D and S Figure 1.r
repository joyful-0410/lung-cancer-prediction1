ori<-read.csv('.\\Celldeath_feature_ori.csv',row.names = 1)
#相关性分析
feature<-ori[,1:5]
cor_coe<-cor(feature,method = 'pearson')
cor_coe<-as.data.frame(cor_coe)
diag(cor_coe)<-0
cor_coe<-as.matrix(cor_coe)
library(circlize)
library(RColorBrewer)
tiff(filename = 'Chord.tiff',width = 6,height = 6,units = 'in',res = 300)
chordDiagram(cor_coe,
             annotationTrack = c('grid','name','axis'),
             grid.col = c(Autophagy='#0000CD',Pyroptosis='#2E8B57',
                          Apoptosis='#DAA520',Necroptosis='#EE2C2C',
                          Cuproptosis='#9B30FF'),
             col = colorRamp2(c(-1, 0, 1), c('purple', 'white', 'red'), transparency = 0.5),
             annotationTrackHeight = c(0.05, 0.05))
dev.off()
#COX回归森林图
library(survival)
library(forestplot)
library(stringr)
unicox<-coxph(Surv(os,status)~Autophagy+Pyroptosis+Apoptosis+
                Necroptosis+Cuproptosis,data = ori)
summary(unicox)
COX<-read.csv('.\\MuCOX.csv')
COX<-rbind(c('Feature',NA,NA,NA,'HR(95%CI)','p'),COX)
COX$X.2<-as.numeric(COX$X.2)
COX$X<-as.numeric(COX$X)
COX$X.1<-as.numeric(COX$X.1)
tiff('forest.tiff',width = 6,height = 5,units = 'in',res = 300)
fig1<- forestplot(COX[,c(1,5,6)], 
                  mean=COX[,2],   
                  lower=COX[,3],  
                  upper=COX[,4],  
                  zero=1,           
                  boxsize=0.1,       
                  graph.pos=3,
                  xlab='Hazard ratio',
                  col=fpColors(box = '#0000CD'),
                  graphwidth=unit(50,'mm'))
fig1
dev.off()
#K-m
library(survminer)
res.cut<-surv_cutpoint(ori,time = 'os',event = 'status',
                       variables = 'Cuproptosis')
res.cat <- surv_categorize(res.cut)
fit <- survfit(Surv(os, status) ~Cuproptosis, data = res.cat)
tiff('C.tiff',width = 7,height = 6,units = 'in',res = 300)
ggsurvplot(fit, data = res.cat, pval = TRUE, conf.int = F,
           risk.table = T,
           palette = c("#EE2C2C","#0000CD"))
dev.off()
