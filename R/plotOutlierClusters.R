# Making and plotting catalog of las tiles on local machine

# Clear workspace:
rm(list=ls())
# Load packages:
library(lidR) 
library(data.table) 
library(ggplot2)
library(feather)
library(rgl)
source("~/githublocal/quantifyBiomassFromPointClouds/R/utils_colors.R")


# Run:
setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/rectangular_study_area/classified/")

# read in original las file
las = readLAS("all20TilesGroundClassified.las")
# get header:
oheader = las@header

setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/rectangular_study_area/classified/watershed_after_remove_OPTICS_outliers")

# read in clustered point cloud:
clusters = as.data.table(read_feather("all20TilesGroundClassified_and_Clustered_By_Watershed_Segmentation.feather"))
colnames(clusters)[1] = 'X'

clusters[,Classification := 1]

clusters[,Outlier_Cluster := 0][treeID == 78 | treeID == 4, Outlier_Cluster := 1]

p = ggplot(data = clusters, mapping = aes(x = X, y = Y, color = Outlier_Cluster)) + geom_point() + theme_bw() + coord_fixed()


#here
# making new las files of only the outlier clusters and removing the outliers from clusters:
c78DT = clusters[treeID == 78,]
c4DT = clusters[treeID ==4,]

c78 = LAS(c78DT, oheader)
c4 = LAS(c4DT, oheader)

plot(c4)

#with rgl:
rgl.open()
rgl.bg(color = "black")
rgl.points(c4DT$X, c4DT$Y, c4DT$Z, color = set.colors(c4DT$Z, palette = height.colors(nrow(c4DT))))
rgl.viewpoint(phi = -90)

play3d(spin3d(axis = c(0, 0, 1)),duration = 120)

#movie3d(spin3d(axis = c(0, 0, 1)),duration = 120)

#axis = c(1, 0, 0)),

write_feather(outliersRemoved, "outlier_clusters/outlier_clusters_removed_all20TilesGroundClassified_and_Clustered_By_Watershed_Segmentation.feather")
witeLAS(c78, "outlier_clusters/c78.las")
writeLAS(c4, "outlier_clusters/c4.las")