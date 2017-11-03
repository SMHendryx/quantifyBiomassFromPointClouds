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


#read in las file
setwd("/Users/seanmhendryx/Data/thesis/Processed_Data/A-lidar/rerunWatershed/")
las = readLAS("Rectangular_UTMAZ_Tucson_2011_000564.las")
# get header:
oheader = las@header

#groundPoints = las %>% lasfilter(Classification == 2)
#plot(groundPoints)

#then change working directory for writing output:
setwd("/Users/seanmhendryx/Data/thesis/Processed_Data/A-lidar/rerunWatershed/output_20171103")

#make dtm:
dtm = grid_terrain(las, res = .1, method = "knnidw")
dtmRaster = raster::as.raster(dtm)
raster::plot(dtmRaster)

#lasRaster = raster::as.raster(las)

lasnorm = lasNormalizeR(las, dtm)

# compute a canopy image
chm = grid_canopy(lasnorm, res = 0.1, na.fill = "knnidw", k = 8)
chm = raster::as.raster(chm)
dev.new()
raster::plot(chm)

dev.off()

# smoothing post-process (e.g. 2x mean)
kernel = matrix(1,3,3)
schm = raster::focal(chm, w = kernel, fun = mean)
#schm = raster::focal(chm, w = kernel, fun = mean)

dev.new()
raster::plot(schm, col = height.colors(50)) # check the image
quartz.save("A-lidar_SCHM.png")

# save smoothed canopy height model as tif
raster::writeRaster(schm, "A-lidar_OPTICS_Outliers_Removed_Smoothed_CHM_no_edge_stretch.tif", format = "GTiff", overwrite = TRUE)

# tree segmentation
# 'th' Numeric. Number value below which a pixel cannot be a crown.
#Default 2
crowns = lastrees(lasnorm, "watershed", schm, th = 1, extra = TRUE)

# Plotting point cloud of trees only:
# without rendering points that are not assigned to a tree
tree = lasfilter(lasnorm, !is.na(treeID))
# this would be a good plot to play on rotate using ImageMagick:
plot(tree, color = "treeID", colorPalette = pastel.colors(100))

#save tree point cloud (clustered point cloud):
writeLAS(tree, "A-lidar_Clustered_By_Watershed_Segmentation.las")
#write.csv(tree@data, "all20TilesGroundClassified_and_Clustered_By_Watershed_Segmentation.csv")
write_feather(tree@data, "A-lidar_Clustered_By_Watershed_Segmentation.feather")

# Plotting raster with delineated crowns:
library(raster)
contour = rasterToPolygons(crowns, dissolve = TRUE)

dev.new()
plot(schm, col = height.colors(50))
plot(contour, add = T)
quartz.save("A-lidar Segmented SCHM - MCC-Lidar Classing & KNN-IDW Rasterization.png")
#dev.off()

