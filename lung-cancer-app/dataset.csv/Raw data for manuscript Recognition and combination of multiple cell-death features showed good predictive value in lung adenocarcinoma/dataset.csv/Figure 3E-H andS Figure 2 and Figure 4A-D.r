ori<-read.csv('.\\Celldeath_Score.csv',row.names = 1)
TIDE<-read.csv('TIDE.csv',row.names = 1)
ori$id<-rownames(ori)
library(dplyr)
TIDE<-left_join(ori,TIDE,by='id')
TIDE<-TIDE[,-c(31:34)]
#
library(ggstatsplot)
library(ggplot2)
ggbarstats(TIDE,Responder,Cluster,ggtheme = theme_classic(),
           palette = 'Set2')
ggsave('Responder.tiff',width = 5.7,height = 6,units = 'in',dpi = 300)
#
library(ggpubr)
TIDE$Cluster<-as.factor(TIDE$Cluster)
ggplot(TIDE,aes(x=Cluster,y=CAF))+geom_boxplot(fill=c('#4169e1','#ec1c24'))+
  theme_classic()+stat_compare_means()
ggsave('CAF.tiff',width = 3.5,height = 6,units = 'in',dpi = 300)
#
Estimate<-read.csv('.\\estimate.csv',row.names = 1)
TIDE<-cbind(TIDE,Estimate)
ggplot(TIDE,aes(x=Cluster,y=TumorPurity))+geom_boxplot(fill=c('#87CEEB','#FF6347'))+
  theme_classic()+stat_compare_means()
ggsave('TumorPurity.tiff',width = 3.5,height = 6,units = 'in',dpi = 300)
#
IC<-read.csv('.\\IT.csv',row.names = 1)
IC<-data.frame(t(IC))
IC<-cbind(IC,ori[,15])
colnames(IC)[7]<-'Cluster'
IC$Cluster<-as.factor(IC$Cluster)
ggplot(IC,aes(x=Cluster,y=TIGIT))+geom_boxplot(fill=c('#87CEEB','#FF6347'))+
  theme_classic()+stat_compare_means(comparisons = list(c('1','2')))+ylab('TIGIT')
ggsave('TIGIT.tiff',width = 2,height = 5,units = 'in',dpi = 300)
