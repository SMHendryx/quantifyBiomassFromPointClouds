# Extracts cluster features from a point cloud for training machine learning model

library(lidR)
library(data.table)
library(feather)
library(ggplot2)


setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/OPTICS_Param_Tests/study-area")

# Read in data:
# read in clustered point cloud:
clusters = as.data.table(read_feather("OPTICS_clustered_points_eps_8.3_min_samples_150.feather"))
#colnames(clusters)[1] = 'X'

# read in points:
points = as.data.table(read.csv("in_situ_points_with_cluster_assignments.csv"))

#add empty intensity
clusters[,Intensity := numeric()]

#redefining rLiDAR's crownMetrics to allow for NAs in Intensity since not all point clouds have intensity (also extended default precision to 5 decimal places):
source("~/githublocal/quantifyBiomassFromPointClouds/R/CrownMetrics.R")
metrics = CrownMetrics(as.matrix(clusters[Label != -1 ,.(X,Y,Z,Intensity, Label)]), na_rm = TRUE, digits = 5)

DT = as.data.table(metrics)
#DT$Tree = unlist(DT$Tree)

#required for writing to feather (write list not implemented):
DT = as.data.table(apply(DT,MARGIN = 2,as.numeric))
write_feather(DT, "cluster_features.feather")
write.csv(DT, "cluster_features.csv")
