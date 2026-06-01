#limma
ori<-read.csv('.\\Celldeath_Score.csv',row.names = 1)
gsva_mat<-read.csv('.\\gsva_kegg_matrix.csv',row.names = 1)
ori$id<-rownames(ori)
group_list<-ori[,c(16,15)]
rownames(group_list)<-rownames(ori)
group_list<-data.frame(group_list[,-1])
colnames(group_list)<-'cluster'
group_list<-as.matrix(group_list)
library(limma)
design <- model.matrix(~0+factor(group_list))
colnames(design) <- c('Cluster1','Cluster2')
rownames(design) <- rownames(ori)
contrast.matrix <- makeContrasts('Cluster1-Cluster2',
                                 levels = design)
fit1 <- lmFit(gsva_mat,design)                
fit2 <- contrasts.fit(fit1, contrast.matrix) 
fit2 <- eBayes(fit2)                         

tT=topTable(fit2,n = Inf, adjust = "fdr")
gsva_go_data<-subset(tT,tT$adj.P.Val<=0.01)
gsva_kegg_data<-gsva_go_data[order(abs(gsva_go_data$logFC),decreasing = T),]
gsva_kegg_data<-gsva_kegg_data[(1:20),]
kegg_str<-gsva_kegg_data[,1]
kegg_str<-append(kegg_str,'group')
gsva_data<-data.frame(t(gsva_mat))
gsva_data$group<-ori$Cluster
gsva_data<-gsva_data[order(gsva_data$group),]
heatmap_kegg<-subset(gsva_data,select = kegg_str)
#
library(ComplexHeatmap)
heatmapdata<-heatmap_kegg
heatmapdata<-data.frame(t(heatmapdata))
heatmapdata<-heatmapdata[1:20,]
heatmapdata<-scale(heatmapdata)
library(circlize)
col_hm<-colorRamp2(c(-4,0,4),c('#386aff','#FFFFFF','red'))
hm1<-Heatmap(heatmapdata,show_column_names = F,name = ' ',col = col_hm,
             column_order = colnames(heatmapdata),
             row_names_gp = gpar(fontsize=6))
hm1
Group<-rep(c('Cluster1','Cluster2'),c(92,423))
hm2<-Heatmap(rbind(Group),name = 'Cluster',col = c('#0000CD',"#EE2C2C"))


tiff('Heatmap_GSVA.tiff',res = 300,width = 10,height = 8,units = 'in')
hm2%v%hm1
dev.off()

