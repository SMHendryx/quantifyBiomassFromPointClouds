# Extracts cluster features from a point cloud for training machine learning model


library(lidR)
library(data.table)
library(feather)
library(ggplot2)


setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/rectangular_study_area/classified/watershed_after_remove_OPTICS_outliers")

# Read in data:
# read in clustered point cloud:
clusters = as.data.table(read_feather("all20TilesGroundClassified_and_Clustered_By_Watershed_Segmentation.feather"))
#colnames(clusters)[1] = 'X'

'%!in%' = function(x,y)!('%in%'(x,y))

#add empty intensity if it doesn't exist
if("Intensity" %!in% colnames(clusters)){
  clusters[,Intensity := numeric()]
}

#redefining rLiDAR's crownMetrics to allow for NAs in Intensity since not all point clouds have intensity (also extended default precision to 5 decimal places):
source("~/githublocal/quantifyBiomassFromPointClouds/R/CrownMetrics.R")
metrics = CrownMetrics(as.matrix(clusters[,.(X,Y,Z,Intensity, treeID)]), na_rm = TRUE, digits = 5)

DT = as.data.table(metrics)

#required for writing to feather (write list not implemented):
DT = as.data.table(apply(DT,MARGIN = 2,as.numeric))

#write to disk:
# Tree column is the cluster label
write_feather(DT, "cluster_features.feather")
write.csv(DT, "cluster_features.csv")
