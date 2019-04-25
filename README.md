
ClusteringR
===========

<!-- badges: start -->
<!-- badges: end -->

Its functionality includes exploratory data analysis, data segmentation and data visualization.It is designed to handle realistic data sets : hedonic data set and sensory data set. It makes use of several clustering methods as well as the implementation of partition-validity approach.

Finally, a graphical user interface is implemented with R shiny in order to propose a user friendly package.

Installation
------------

``` r
install.packages("devtools")
devtools::install_github("BouzidiImen/ClusteringR")
```

Usage
-----

Below is a quick look at how ClusteringR can help to do your sensory analysis. Many ClusteringR functions are also applicable to clustering data using diverse methods.

``` r
library(ClusteringR)
# Create a clustering object  -------------------------------------------------
cl <- Clustering(t(hedo),ClustMeth='Hierarchical',k=4,Hdismethod='euclidean',Hmethod="ward.D2",
                    Graph=F,VarCart=F,IndCart=F,ElbowP=F )
#Plot of elbow method , dendrogram , variables representation and individuals

plot_grid(cl$ElbowP, cl$dendrogram, cl$Pvar, cl$Pind, hjust = 1, vjust = 1,
          scale = c(1, 1, 1, 1))
```

![](README_files/figure-markdown_github/unnamed-chunk-2-1.png)

``` r
ClustShiny() #run shiny application
```

Data available in the package
-----------------------------

-   senso: sensory data from a professional trial of 8 biscuits by 12 judges.
-   hedo: hedonic data from a trial of 8 biscuits by 294 customers.

``` r
#to use 
library(ClusteringR)

S=senso
H=hedo
```

A User Friendly Package
-----------------------

Within the package you find a shiny application that demonstrate what the package does.

You can visit the following link to discover package functionalities.

[Shiny application for the package](https://imenbouzidi.shinyapps.io/InterfaceForThepackage/)
