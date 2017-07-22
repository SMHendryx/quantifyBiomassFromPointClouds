# Clear workspace:
rm(list=ls())

library(lidR)
library(feather)
library(data.table)


# run from directory containing ground classified point cloud:
setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/rectangular_study_area/classified/")
# or first cd into directory, then start R there

# read in original las file
las = readLAS("all20TilesGroundClassified.las")
# get header:
oheader = las@header

# read in OPTICS outliers removed non ground points
setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/rectangular_study_area/classified/watershed_after_remove_OPTICS_outliers")

DT = as.data.table(read_feather("OPTICS_outliers_removed_points_eps_8.3_min_samples_150.feather"))
# Add Classification, all points should be nonground (1):
DT[,Classification := 1]

#rbind ground points from full point cloud:
#But first normalize las so that ground points are normalized to dtm (i.e., close to zero):
dtm = grid_terrain(las, res = .1, method = "knnidw")
lasnorm = lasnormalize(las, dtm)

DT[,Intensity := NA]

DT = rbind(DT, lasnorm@data[Classification == 2,], fill = TRUE)
DT[,pulseID := seq(1,nrow(DT))]


lasnorm = LAS(DT, oheader)

#dtm = grid_terrain(las, method = "kriging", k = 8)
#^killed: 9
#dtm = grid_terrain(las, res = .1, method = "knnidw")

#normalize nonground points that have had outliers removed:
#lasnorm = lasnormalize(nonground, dtm)

#dtm = raster::as.raster(dtm)
#raster::plot(dtm)

#quartz.save("/Users/seanhendryx/Google Drive/THE UNIVERSITY OF ARIZONA (UA)/THESIS/Graphics/tree segmentation/watershed/SRER Mesq. Tower Site Digital Terrain Model - MCC-Lidar Classing & KNN-IDW Rasterization")
#dev.off()


# compute a canopy image
chm = grid_canopy(lasnorm, res = 0.1, na.fill = "knnidw", k = 8)
chm = raster::as.raster(chm)
raster::plot(chm)

#quartz.save("/Users/seanhendryx/Google Drive/THE UNIVERSITY OF ARIZONA (UA)/THESIS/Graphics/tree segmentation/watershed/SRER Mesq. Tower Site CHM - MCC-Lidar Classing & KNN-IDW Rasterization")
#dev.off()

# smoothing post-process (e.g. 2x mean)
kernel = matrix(1,3,3)
schm = raster::focal(chm, w = kernel, fun = mean)
#schm = raster::focal(chm, w = kernel, fun = mean)

raster::plot(schm, col = height.colors(50)) # check the image


# tree segmentation
# ‘th’ Numeric. Number value below which a pixel cannot be a crown.
#Default 2
crowns = lastrees(lasnorm, "watershed", schm, th = 1, extra = TRUE)

# Plotting point cloud of trees only:
# without rendering points that are not assigned to a tree
tree = lasfilter(lasnorm, !is.na(treeID))
plot(tree, color = "treeID", colorPalette = pastel.colors(100))

#save tree point cloud (clustered point cloud):
writeLAS(tree, "all20TilesGroundClassified_and_Clustered_By_Watershed_Segmentation.las")
#write.csv(tree@data, "all20TilesGroundClassified_and_Clustered_By_Watershed_Segmentation.csv")
write_feather(tree@data, "all20TilesGroundClassified_and_Clustered_By_Watershed_Segmentation.feather")

# Plotting raster with delineated crowns:
library(raster)
contour = rasterToPolygons(crowns, dissolve = TRUE)

plot(schm, col = height.colors(50))
plot(contour, add = T)
