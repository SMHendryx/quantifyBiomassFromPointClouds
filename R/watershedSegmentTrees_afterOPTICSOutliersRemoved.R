# Script segments a point cloud into clusters using watershed segmentation on rasterized point cloud

# Clear workspace:
rm(list=ls())

library(lidR)
library(feather)
library(data.table)
#terminal output coloring
library(crayon)
error <- red $ bold
warn <- magenta $ underline
note <- cyan
#cat(error("Error: subscript out of bounds!\n"))
#cat(warn("Warning: shorter argument was recycled.\n"))
#cat(note("Note: no such directory.\n"))

#bug in lasnormalize as of 11/2/17 related to :Error: 546 points were not normalizable because the DTM contained NA values. Process aborded
# no NAs in dtm
# so load an old version:
source("~/githublocal/quantifyBiomassFromPointClouds/quantifyBiomassFromPointClouds/R/lasNormalize.R")
#library(lidR, lib.loc = "/Users/seanmhendryx/githublocal/lidR/")


#get original header:
setwd("/Users/seanmhendryx/Data/thesis/Processed_Data/SfM/rerunWatershed/")

# read in original las file
las = readLAS("Merged_Ground_Classified.las")
# get header:
oheader = las@header

groundPoints = las %>% lasfilter(Classification == 2)
plot(groundPoints)

# read in OPTICS outliers removed, non ground points
#setwd("/Users/seanhendryx/DATA/Lidar/SRER/AZ_Tucson_2011_000564/rectangular_study_area/GreaterThan1mHAG/")
DT = as.data.table(read_feather("OPTICS_clustered_points_eps_8.3_min_samples_150.feather"))
#lasOutliersRemoved = LAS(DT, header = oheader)

#then change working directory for writing output:
setwd("/Users/seanmhendryx/Data/thesis/Processed_Data/T-lidar/rerunWatershed/output_20171101")

# Add Classification, all points should be nonground (1):
DT[,Classification := 1]

#rbind ground points from full point cloud:
#But first normalize las so that ground points are normalized to dtm (i.e., close to zero):
dtm = grid_terrain(las, res = .1, method = "knnidw")
dtmRaster = raster::as.raster(dtm)
raster::plot(dtmRaster)

#lasRaster = raster::as.raster(las)

# DT is already normalized to above ground height, so normalize las:
#lasnorm = lasnormalize(las, dtm)
lasnorm = lasNormalizeR(las, dtm)


# i am here. bug in lasnormalize^



DT[,Intensity := NA]

DT = rbind(DT, lasnorm@data[Classification == 2,], fill = TRUE)
DT[,pulseID := seq(1,nrow(DT))]


lasnorm = LAS(DT, oheader)

#dtm = grid_terrain(las, method = "kriging", k = 8)
#^killed: 9
#dtm = grid_terrain(las, res = .1, method = "knnidw")

#normalize nonground points that have had outliers removed:
#lasnorm = lasnormalize(nonground, dtm)


#quartz.save("/Users/seanhendryx/Google Drive/THE UNIVERSITY OF ARIZONA (UA)/THESIS/Graphics/tree segmentation/watershed/SRER Mesq. Tower Site Digital Terrain Model - MCC-Lidar Classing & KNN-IDW Rasterization")
#dev.off()


# compute a canopy image
chm = grid_canopy(lasnorm, res = 0.1, na.fill = "knnidw", k = 8)
chm = raster::as.raster(chm)
raster::plot(chm)

#quartz.save("/Users/seanhendryx/Google Drive/THE UNIVERSITY OF ARIZONA (UA)/THESIS/Graphs/Alidar/Clustering:Tree Segmentation/OPTICS Outliers Removed/Alidar CHM - MCC-Lidar Classing & KNN-IDW Rasterization.png")
dev.off()

# smoothing post-process (e.g. 2x mean)
kernel = matrix(1,3,3)
schm = raster::focal(chm, w = kernel, fun = mean)
#schm = raster::focal(chm, w = kernel, fun = mean)

raster::plot(schm, col = height.colors(50)) # check the image

#quartz.save("/Users/seanhendryx/Google Drive/THE UNIVERSITY OF ARIZONA (UA)/THESIS/Graphs/Alidar/Clustering:Tree Segmentation/OPTICS Outliers Removed/Alidar SCHM - MCC-Lidar Classing & KNN-IDW Rasterization.png")
#dev.off()


# save smoothed canopy height model as tif
raster::writeRaster(schm, "Tlidar_OPTICS_Outliers_Removed_Smoothed_CHM_no_edge_stretch.tif", format = "GTiff", overwrite = TRUE)


# tree segmentation
# ‘th’ Numeric. Number value below which a pixel cannot be a crown.
#Default 2
crowns = lastrees(lasnorm, "watershed", schm, th = 1, extra = TRUE)

# Plotting point cloud of trees only:
# without rendering points that are not assigned to a tree
tree = lasfilter(lasnorm, !is.na(treeID))
plot(tree, color = "treeID", colorPalette = pastel.colors(100))

#save tree point cloud (clustered point cloud):
writeLAS(tree, "TLidar_Clustered_By_Watershed_Segmentation.las")
#write.csv(tree@data, "all20TilesGroundClassified_and_Clustered_By_Watershed_Segmentation.csv")
write_feather(tree@data, "TLidar_Clustered_By_Watershed_Segmentation.feather")

# Plotting raster with delineated crowns:
library(raster)
contour = rasterToPolygons(crowns, dissolve = TRUE)

plot(schm, col = height.colors(50))
plot(contour, add = T)
quartz.save("Tlidar Segmented SCHM - MCC-Lidar Classing & KNN-IDW Rasterization.png")
#dev.off()

