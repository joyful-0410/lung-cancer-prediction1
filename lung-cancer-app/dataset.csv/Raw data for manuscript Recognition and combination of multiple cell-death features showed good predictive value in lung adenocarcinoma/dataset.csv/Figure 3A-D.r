ori<-read.csv('.\\Celldeath_Score.csv',row.names = 1)
Im<-read.csv('.\\Immune.csv',row.names = 1)
Im$Cluster<-ori$Cluster
Im<-Im[order(Im$Cluster),]
Im<-Im[,-c(23:26)]
Im<-reshape2::melt(Im)
Cluster<-rep(c(1,2),c(92,423))
Cluster<-rep(Cluster,22)
Im$Cluster<-as.factor(Cluster)
colnames(Im)<-c('Immune_Cell','Scale_of_fraction','Cluster')
#
library(ggplot2)
library(ggpubr)
ggplot(Im,aes(x=Immune_Cell,y=Scale_of_fraction,fill=Cluster))+
  geom_boxplot(outlier.shape = NA)+
  stat_compare_means(aes(fill=Cluster),label = 'p.signif',hide.ns = T)+
  scale_fill_manual(values = c('#1C86EE','#EE2C2C'))+
  theme_classic()+theme(axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = 0.5))
ggsave('ImmuneCell.tiff',dpi = 300,height = 5,width = 10,units = 'in')
#
#
library(dplyr)
ori1<-ori%>%filter(Cluster==2)
Cluster2<-rownames(ori1)
Cluster2<-substr(Cluster2,1,12)
Cluster2<-gsub('.','-',Cluster2,fixed = T)
ori1<-ori%>%filter(Cluster==1)
Cluster1<-rownames(ori1)
Cluster1<-substr(Cluster1,1,12)
Cluster1<-gsub('.','-',Cluster1,fixed = T)
#
mut<-read.csv('.\\mut.csv',encoding = 'UTF-8')
mut[mut=='Splice_Region']<-NA
mut$Tumor_Sample_Barcode<-substr(mut$Tumor_Sample_Barcode,1,12)
mut1<-mut%>%filter(Tumor_Sample_Barcode%in%Cluster1)
mut1$Tumor_Sample_Barcode<-as.factor(mut1$Tumor_Sample_Barcode)
mut2<-mut%>%filter(Tumor_Sample_Barcode%in%Cluster2)
library(GenVisR)
tiff('mut_2.tiff',width = 13,height = 7,units = 'in',res = 300)
waterfall(mut2,fileType = 'MAF',mainRecurCutoff = 0.2)
dev.off()
#
GJB2<-mut%>%filter(Hugo_Symbol=='GJB2')
GJB2<-GJB2[!duplicated(GJB2[3]),]
colnames(GJB2)[3]<-'id'
ori$id<-rownames(ori)
ori$id<-substr(ori$id,1,12)
ori$id<-gsub('.','-',ori$id,fixed = T)
ori<-left_join(ori,GJB2,by='id')
ori<-ori[,-18]
colnames(ori)[17]<-'GJB2_mutation'
ori$GJB2_mutation[ori$GJB2_mutation=='GJB2']<-'Yes'
ori$GJB2_mutation[is.na(ori$GJB2_mutation)]<-'No'
library(ggstatsplot)
library(ggplot2)
ggbarstats(ori,GJB2_mutation,Cluster,ggtheme = theme_classic(),
           palette = 'Set1')
ggsave('GJB2.tiff',width = 5.7,height = 6,units = 'in',dpi = 300)
#
TMB<-read.csv('.\\TMB.csv',row.names = 1)
TMB<-TMB[,-c(1,2,3,4)]
colnames(TMB)[1]<-'id'
ori<-left_join(ori,TMB,by='id')
colnames(ori)[18]<-'TMB'
library(ggpubr)
ori$Cluster<-as.factor(ori$Cluster)
ggplot(ori,aes(x=Cluster,y=TMB))+geom_boxplot(fill=c('#87CEEB','#FF6347'))+
  theme_classic()+stat_compare_means()
ggsave('TMB.tiff',width = 3.5,height = 6,units = 'in',dpi = 300)
#
library(ggplot2)
library(ggpubr)
ggplot(ori,aes(x=TP53_mutation, y=Curroptosis))+
  geom_boxplot(outlier.shape = NA)+
  stat_compare_means()
