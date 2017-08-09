# Clear workspace:
rm(list=ls())

library(lidR)
library(feather)
library(data.table)
library(raster)


outDirec = "/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/mcc-s_point20_-t_point05/"
setwd(outDirec)

SfM = raster("/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/mcc-s_point20_-t_point05/SfM_Smoothed_CHM.tif")
tLid = raster("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/rectangular_study_area/classified/watershed_after_remove_OPTICS_outliers/Tlidar_OPTICS_Outliers_Removed_Smoothed_CHM.tif")

difference = tLid - SfM

plot(difference)
quartz.save("/Users/seanhendryx/Google Drive/THE UNIVERSITY OF ARIZONA (UA)/THESIS/Graphs/SfM/Tree Segmentation/difference between Tlidar and SfM SCHMs (tLid - SfM).png")

summedDifference = sum(values(difference), na.rm = TRUE)

volumetricDifference = summedDifference * .01
