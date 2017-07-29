# Making and plotting catalog of las tiles on local machine

# Clear workspace:
rm(list=ls())
# Load packages:
library(lidR) 
library(data.table) 
library(raster) 
library(rgeos)
library(ggplot2)
library(feather)


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

clusters[treeID == 78 | treeID == 4,Outlier := TRUE]

las = LAS(clusters, oheader)

plot(las, color = "Outlier")
