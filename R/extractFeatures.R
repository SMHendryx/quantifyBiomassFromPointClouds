# Extracts cluster features from a point cloud for training machine learning model

library(lidR)
library(data.table)
library(feather)
library(ggplot2)


discardIntensity = TRUE

setwd("/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/mcc-s_point20_-t_point05/")

# Read in data:
# read in clustered point cloud:
clusters = as.data.table(read_feather("SfM_allTilesGroundClassified_and_Clustered_By_Watershed_Segmentation.feather"))
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

#To read in if restarting from here:
#DT = as.data.table(read_feather("cluster_features.feather"))
setnames(DT, "Tree", "Cluster_ID")

if(discardIntensity){
  numColsToSave = ncol(DT) - 29
  cols = names(DT)[1:numColsToSave]
  DT = DT[,.SD, .SDcols = cols]
}

# read in points (labeled data):
setwd("/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/mcc-s_point20_-t_point05/buffer3")
points = as.data.table(read_feather("in_situ_biomass_points_with_cluster_assignments.feather"))

#These next three lines of code should be moved to extractFeatures.R:
#First, connect labels and features:
#LF = DT
#setDT(LF)[points, ]
toMerge = points[,.(Sample_ID, cluster_ID, AGB, closest_cluster_outside_threshold)]
#remove points outside of threshold:
toMerge = toMerge[closest_cluster_outside_threshold == FALSE]
toMerge[,closest_cluster_outside_threshold := NULL]
LF = merge(DT, toMerge, by.x = "Cluster_ID", by.y = "cluster_ID")

#Sum in situ mass by cluster (i.e. "Cluster_ID" column)
LF[,in_situ_AGB_summed_by_cluster := sum(AGB), by = Cluster_ID]

#Remove unnecessary columns for training model:
LF[,Sample_ID := NULL]
LF[,AGB := NULL]

#Remove duplicated rows now that biomass has been summed by cluster:
setkey(LF, NULL)
LF = unique(LF)

#write to disk:
# Tree column is the cluster label
write_feather(LF, "cluster_features_with_label.feather")
write.csv(LF, "cluster_features_with_label.csv")
