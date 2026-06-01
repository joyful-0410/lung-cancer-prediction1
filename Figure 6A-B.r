ori<-read.csv('.\\Celldeath_Score.csv',row.names = 1)
Whole<-read.csv('D://R/Cuproptosis/肺腺癌/DEGs/TCGA-LUAD-Gene.csv',row.names = 1)
Whole<-Whole[which(rowSums(Whole==0)==0),]
Group<-data.frame(ori[,15])
rownames(Group)<-rownames(ori)
colnames(Group)<-'Cluster'
library(limma)
Group<-as.matrix(Group)
design<-model.matrix(~0+factor(Group))
colnames(design)=c('Cluster1','Cluster2')
rownames(design)=rownames(Group)
df.fit<-lmFit(Whole,design)
df.matrix <- makeContrasts(Cluster1-Cluster2,
                           levels = design)
fit <- contrasts.fit(df.fit, df.matrix)
fit <- eBayes(fit)
tempOutput <- topTable(fit,n = Inf, adjust = "fdr")
foldChange = 1.5
padj = 0.01
All_tempOutput <-subset(tempOutput,(abs(tempOutput$logFC)>=1.5)&tempOutput$adj.P.Val<=0.001)
degs<-rownames(All_tempOutput)
write.csv(degs,file = '.\\DEGs.csv')
#
library(ggplot2)
library(ggrepel)
logFC <- tempOutput$logFC
deg.padj <- tempOutput$adj.P.Val
data <- data.frame(logFC = logFC, padj = deg.padj)
data$group[(data$padj > 0.001) | (data$logFC < 1.5) | (data$logFC > -1.5)] <- "Exclude"
data$group[(data$padj <= 0.001 & data$logFC > 1.5)] <-  "Up"
data$group[(data$padj <= 0.001 & data$logFC < -1.5)] <- "Down"
x_lim <- max(logFC,-logFC)
tiff('volcano.tiff',width = 7,height = 6.5,units = 'in',res = 300)
label = subset(tempOutput,adj.P.Val <0.001 & abs(logFC) > 1.5)
label1 = rownames(label)
Significant=ifelse((tempOutput$adj.P.Val < 0.001 & abs(tempOutput$logFC)> 1.5), 
                   ifelse(tempOutput$logFC > 1,"Up","Down"), "Exclude")

ggplot(tempOutput, aes(logFC, -log10(adj.P.Val)))+
  geom_point(aes(col=Significant))+
  scale_color_manual(values=c("#1E90FF","gray","#FFA500"))+
  labs(title = " ")+
  geom_vline(xintercept=c(-1.5,1.5), colour="black", linetype="dashed")+
  geom_hline(yintercept = -log10(0.001),colour="black", linetype="dashed")+
  theme(plot.title = element_text(size = 16, hjust = 0.5, face = "bold"))+
  labs(x="log2(FoldChange)",y="-log10(Pvalue)")+
  theme(axis.text=element_text(size=13),axis.title=element_text(size=13))+
  str(tempOutput, max.level = c(-1, 1))+theme_bw()

dev.off()
#
library(formattable)
df<-All_tempOutput[,c(1,5)]
df<-df[order(df$logFC,decreasing = T),]
df1<-subset(df,(abs(df$logFC)>=2)&df$adj.P.Val<=0.001)
tiff('DEGs.tiff',width = 5,height = 15,units = 'in',res = 300)
formattable(df1,list(
  logFC=color_tile('#87CEFA','#F08080')
))
dev.off()
#
library(htmlwidgets)
library(webshot)
htmlwidgets::saveWidget(a, "table.html", selfcontained = TRUE)

webshot::webshot(url = "table.html", file = "table.png", 
                 vwidth = 1000, vheight = 275)