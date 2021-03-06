#' Clustering
#' @description This function serves to clustering data analysis using diverse methods and ploting diverses graphs
#' @param Y a numeric matrix or a data frame with all numeric columns (Ex:consumers scores)
#' @param ClustMeth Clustering method that must be "hierarchical", "diana", "kmeans", "sota", "pam", "clara" or "som"
#' @param k integer, the number of clusters. It is required that 0<k<n where n is the number of observations (i.e., n = nrow(x))
#' @param Sotadismethod character string specifying the metric to be used for calculating dissimilarities between observations for Sota method.It could be "euclidean" or "correlation"
#' @param Pdismethod  character string specifying the metric to be used for calculating dissimilarities between observations for PAM method.It could be "euclidean" or "manhattan"
#' @param Cdismethod character string specifying the metric to be used for calculating dissimilarities between observations for Clara method.It could be "euclidean","manhattan" or "jaccard"
#' @param Ddismethod character string specifying the metric to be used for calculating dissimilarities between observations for Diana method.It could be "euclidean" or "manhattan"
#' @param Hdismethod  The method to calculate a dissimilarity structure as produced by dist for hierarchical method.It could be :"aitchison", "euclidean", "maximum", "manhattan", "canberra","binary" or "minkowski"
#' @param Hmethod the agglomeration method to be used ,should be "single", "complete", "average", "mcquitty", "ward.D", "ward.D2", "centroid" or "median"
#' @param Graph  TRUE if you want to visualize the dendrogram (only for Hierarchical and Diana methods )
#' @param VarCart  TRUE if you want to visualize Variables's representation
#' @param IndCart  TRUE if you want to visualize Distribution of consumers
#'
#' @return  Graph,IndCart,VarCart,classes
#' @export
#' @import FactoMineR
#' @import factoextra
#' @import cluster
#' @import clValid
#' @import kohonen
#' @import grDevices
#' @examples
#'
#'  library(ClusteringR)
#'  cl=Clustering(Y=t(hedo),ClustMeth='hierarchical',
#'  k=3,Hdismethod='euclidean',Hmethod="ward.D2",
#'  Graph=FALSE,VarCart=FALSE,IndCart=FALSE)
#'

Clustering=function(Y,ClustMeth='hierarchical',k=3,Sotadismethod='euclidean',Pdismethod='euclidean',Cdismethod='euclidean',Ddismethod='euclidean',Hdismethod='euclidean',Hmethod="ward.D2",
                    Graph=T,VarCart=F,IndCart=F){


repPCA=function(class,Y){
      classif=cbind.data.frame(class,Y)

      res.pca=PCA(classif,quali.sup =1,graph = F )
      p=fviz_pca_var(res.pca, col.var = "cos2",
                 gradient.cols ="jco",
                 repel = T )
      p2=fviz_pca_ind(res.pca,
                  geom.ind = "point",
                  col.ind = classif$class, # colorer by groups
                  palette = 'jco',
                  addEllipses = T,
                  legend.title = "Groups")
  return(list(res.pca=res.pca,graphvar=p,graphind=p2))
}

if(ClustMeth=='hierarchical'||ClustMeth=='diana'||ClustMeth=='kmeans'||ClustMeth=='clara'||
   ClustMeth=='pam'||
   ClustMeth=='sota'||ClustMeth=='som'){
########### hierarchical ########
switch (ClustMeth,
        hierarchical = {
    if (Hdismethod=='euclidean'||Hdismethod=='aitchison'||Hdismethod=='maximum'||Hdismethod=='manhattan'||
        Hdismethod=='canberra'||Hdismethod=='minkowski'||Hdismethod=='binary') d=stats::dist(Y,method = Hdismethod)
    else stop('type must be "aitchison", "euclidean", "maximum", "manhattan", "canberra","binary" or "minkowski"')

    if(Hmethod=="single"||Hmethod=="complete"||Hmethod=="average"||
       Hmethod=="mcquitty"||Hmethod=="ward.D"
       ||Hmethod=="ward.D2"||Hmethod=="centroid" ||Hmethod=="median") hc=stats::hclust(d,method = Hmethod)
    else stop('type must be "single", "complete", "average", "mcquitty", "ward.D", "ward.D2", "centroid" or "median"')

  classes=stats::cutree(hc,k=k)
  class=as.factor(classes)
  #dend=as.dendrogram(hc)
  dend_plot=fviz_dend(hc, cex = 0.5, k=k, main = "Dendrogram ", xlab = "Objects", ylab = "Distance", # Cut in four groups
                      k_colors = "jco",rect = TRUE, # Add rectangle around groups
                      rect_border = 'jco', rect_fill =F)

  if(Graph==T) show(dend_plot)
  res=repPCA(class,Y)
  p=res$graphvar
  if(VarCart==T) show(p)
  p2=res$graphind
  if(IndCart==T) show(p2)


  return(list(Hclust=hc,dendrogram=dend_plot,VarCart=p,IndCart=p2,classes=class))
  },
  #############DIANA##############
  diana={

            if(Ddismethod=="euclidean" ||Ddismethod=="manhattan") D=diana(Y,metric=Ddismethod,diss=FALSE)
            else stop('type must be "euclidean" or "manhattan"')
            dend_plot=fviz_dend(D, cex = 0.5, k=3, main = "Dendrogram ", xlab = "Objects", ylab = "Distance", # Cut in four groups
                                k_colors = "jco",rect = TRUE,
                                rect_border = 'jco', rect_fill = F)

            if(Graph) show(dend_plot)
            classes=stats::cutree(D,k=k)
            class=as.factor(classes)
            res=repPCA(class,Y)
            p=res$graphvar
            if(VarCart) show(p)
            p2=res$graphind
            if(IndCart) show(p2)


            return(list(Dianaclust=D,dendro= dend_plot,VarCart=p,IndCart=p2,classes=class))
  },
  ################Kmeans########################
  kmeans={
      km.res1 <- stats::kmeans(Y,k)
      f=fviz_cluster(list(data = Y, cluster = km.res1$cluster),
                     ellipse.type = "norm", geom = "point", stand = FALSE, palette = "jco")
      if(Graph) show(f)
      class=as.factor(km.res1$cluster)
      res=repPCA(class,Y)
      p=res$graphvar
      if(VarCart==T) show(p)
      p2=res$graphind
      if(IndCart==T) show(p2)
      return(list(Km=km.res1,graph=f,IndCart=p2,VarCart=p,classes=class))

  }
  ##################CLARA##############
  ,clara={

      if (Cdismethod=='euclidean'||Cdismethod=='manhattan'||Cdismethod=="jaccard") cl=clara(Y,k,metric = Cdismethod) #it's recomended to fix samples(default=5)
      else stop('Type must be "euclidean","manhattan" or "jaccard"')
      f=fviz_cluster(cl,palette ="jco",# color paletteellipse.type ="t",# Concentration
                     ellipsegeom ="point",pointsize =1)
      if(Graph==T) show(f)
      class=as.factor(cl$clustering)
      res=repPCA(class,Y)
      p=res$graphvar
      if(VarCart==T) show(p)
      p2=res$graphind
      if(IndCart==T) show(p2)
      return(list(Claracl=cl,Graph=f,IndCart=p2,VarCart=p,classes=class))
  },
  #################PAM#############
  #pam may need too much memory or too much computation time since both are O(n^2). Then, clara() is preferable, see its documentation.
  pam={
      if (Pdismethod=='euclidean'||Pdismethod=='manhattan') p=pam(Y,k,metric = Pdismethod) #it's recomended to fix samples(default=5)
      else stop('Type must be "euclidean"or "manhattan"')

      f=fviz_cluster(p,palette ="jco",
                     ellipsegeom ="point",pointsize =1)
      if(Graph==T) show(f)
      class=as.factor(p$clustering)
      res=repPCA(class,Y)
      p=res$graphvar
      if(VarCart==T) show(p)
      p2=res$graphind
      if(IndCart==T) show(p2)
      return(list(Pamcl=p,Graph=f,IndCart=p2,VarCart=p,classes=class))



  },
  ###################SOTA################
  sota={
      if(Sotadismethod=='euclidean'||Sotadismethod=='correlation') s=sota(as.matrix(Y),maxCycles=k-1,distance=Sotadismethod)
      else stop('Type must be "euclidean" or"correlation"')
      class=as.factor(s$clust)
      res=repPCA(class,Y)
      p=res$graphvar
      if(VarCart==T) show(p)
      p2=res$graphind
      if(IndCart==T) show(p2)
      return(list(sotaCl=s,IndCart=p2,VarCart=p,classes=class))

  },
  som={
      s = som(Y,somgrid(k, k, "hexagonal")) # use of a cart

      class=as.factor(s$unit.classif)
      res=repPCA(class,Y)
      f=res$graphvar
      if(VarCart) show(p)
      p2=res$graphind
      if(IndCart) show(p2)
      return(list(SomCl=s,Graph=f,IndCart=p2,VarCart=p,classes=class))

    }



)


}

else stop('ClustMeth must be  "hierarchical", "diana", "kmeans", "sota", "pam", "clara" or "som"')



}
