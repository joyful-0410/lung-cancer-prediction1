ori<-read.csv('.\\Composite_Score.csv',row.names = 1)
#
cli_stage<-ori[,c(10,16)]
cli_stage<-na.omit(cli_stage)
library(ggstatsplot)
library(ggplot2)
ggbarstats(cli_stage,Clinical_Stage,Cluster,ggtheme = theme_classic(),
           palette = 'Set3')
ggsave('Cli.tiff',width = 5.7,height = 6,units = 'in',dpi = 300)
#
T_Stage<-ori[,c(9,15)]
T_Stage[T_Stage=='TX']<-NA
T_Stage<-na.omit(T_Stage)
ggbarstats(T_Stage,T_Stage,Cluster,ggtheme = theme_classic(),
           palette = 'Set3')
ggsave('T.tiff',width = 5.7,height = 6,units = 'in',dpi = 300)
#
N_Stage<-ori[,c(10,15)]
N_Stage[N_Stage=='NX']<-NA
N_Stage<-na.omit(N_Stage)
ggbarstats(N_Stage,N_Stage,Cluster,ggtheme = theme_classic(),
           palette = 'Set3')
ggsave('N.tiff',width = 5.7,height = 6,units = 'in',dpi = 300)
#
M_Stage<-ori[,c(11,15)]
M_Stage[M_Stage=='MX']<-NA
M_Stage<-na.omit(M_Stage)
ggbarstats(M_Stage,M_Stage,Cluster,ggtheme = theme_classic(),
           palette = 'Set3')
ggsave('M.tiff',width = 5.7,height = 6,units = 'in',dpi = 300)
#
Gender<-ori[,c(13,15)]
ggbarstats(Gender,Gender,Cluster,ggtheme = theme_classic(),
           palette = 'Set3')
ggsave('Gender.tiff',width = 5.7,height = 6,units = 'in',dpi = 300)
#
hm<-as.matrix(ori[,1:5])
hm<-data.frame(scale(hm))
hm<-cbind(hm,ori[,8:15])
hm<-hm[order(hm$Cluster),]
hm<-hm[,-12]
library(ComplexHeatmap)
main<-t(hm[,1:5])
annotion<-hm[,6:12]

library(circlize)
col_mhm<-colorRamp2(c(-5,0,5),c('#4682B4','white','Red'))
annotation_c<-HeatmapAnnotation(
  df=annotion,col = list(Cluster=c('1'='#0000CD','2'='#EE2C2C'),
                           Clinical_Stage=c('I'='LightPink','II'='HotPink','III'='DeepPink'),
                           T_Stage=c('T1'='MediumPurple','T2'='MediumSlateBlue',
                                     'T3'='SlateBlue','T4'='DarkSlateBlue','TX'='white'),
                           N_Stage=c('N0'='LightSkyBlue','N1'='SkyBlue','N2'='DeepSkyBlue',
                                     'N3'='CornflowerBlue','NX'='white'),
                           M_Stage=c('M0'='MediumSpringGreen','M1'='SpringGreen','MX'='White'),
                           Gender=c('male'='Gold','female'='Yellow'),
                           Smoking=c('Yes'='#8B0000','No'='#F08080')),
  na_col = 'white'
)
tiff('Heatmap.tiff',res = 300,width = 10,height = 8,units = 'in')
Heatmap(main,show_column_names = F,name = 'Features',col = col_mhm,
            column_order = colnames(main),top_annotation = annotation_c,row_order =rownames(main))
dev.off()
