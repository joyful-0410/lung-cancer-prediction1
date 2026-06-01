ori<-read.csv('.\\Celldeath_feature_ori.csv',row.names = 1)
#
cli_stage<-ori[,c(1,2,3,4,5,8)]
cli_stage<-na.omit(cli_stage)
library(ggplot2)
library(ggpubr)
Cli_A<-ggplot(cli_stage,aes(x=Clinical_Stage,y=Apoptosis,fill=Clinical_Stage))+geom_boxplot()+
  stat_compare_means(comparisons = list(c('I','II'),
                                        c('I',"III"),c('II','III')))+
  theme_classic()+
  scale_fill_manual(values = c('#FFD700','#EEC900','#CDAD00'))
#
T_Stage<-ori[,c(1,2,3,4,5,9)]
T_Stage[T_Stage=='TX']<-NA
T_Stage<-na.omit(T_Stage)
T_A<-ggplot(T_Stage,aes(x=T_Stage,y=Apoptosis,fill=T_Stage))+geom_boxplot()+
  stat_compare_means(comparisons = list(c('T1','T2'),c('T1','T3'),
                                        c('T1','T4'),c('T2','T3'),
                                        c('T2','T4'),c('T3','T4')))+
  theme_classic()+
  scale_fill_manual(values = c('#FFD700','#EEC900','#CDAD00','#8B7500'))
#
N_Stage<-ori[,c(1,2,3,4,5,10)]
N_Stage[N_Stage=='NX'|N_Stage=='N3']<-NA
N_Stage<-na.omit(N_Stage)
N_A<-ggplot(N_Stage,aes(x=N_Stage,y=Apoptosis,fill=N_Stage))+geom_boxplot()+
  stat_compare_means(comparisons = list(c('N0','N1'),c('N0','N2'),
                                        c('N1','N2')))+
  theme_classic()+
  scale_fill_manual(values = c('#FFD700','#EEC900','#CDAD00'))
#
M_Stage<-ori[,c(1,2,3,4,5,11)]
M_Stage[M_Stage=='MX']<-NA
M_Stage<-na.omit(M_Stage)
M_A<-ggplot(M_Stage,aes(x=M_Stage,y=Apoptosis,fill=M_Stage))+geom_boxplot()+
  stat_compare_means(comparisons = list(c('M0','M1')))+
  theme_classic()+
  scale_fill_manual(values = c('#FFD700','#EEC900'))
#
A<-ggarrange(ggarrange(Cli_A,T_A,N_A,M_A,ncol = 4),
          nrow = 1)
ggsave('Apoptosis.tiff',plot = A,width = 15,height = 4,dpi = 300)
##
N_Stage<-ori[,c(1,2,3,4,5,10)]
N_Stage$N_Stage[N_Stage$N_Stage=='NX']<-NA
N_Stage<-na.omit(N_Stage)
N_Stage$N_Stage[N_Stage$N_Stage!='N0']<-'NM'
ggplot(N_Stage,aes(x=N_Stage,y=Autophagy,fill=N_Stage))+geom_boxplot()+
  stat_compare_means()+
  theme_classic()
#
library(ggplot2)
library(ggpubr)
ggscatter(ori, x = "Cuproptosis", y = "os", 
          add = "reg.line",size = 1, conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",color = '#4169E1')
ggsave('Cuproptosis.tiff',dpi=300,width = 6,height = 4)
