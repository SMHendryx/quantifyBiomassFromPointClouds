#Segments canopies from raster data using watershed algorithm

# Clear workspace:
rm(list=ls())

library(lidR)
library(feather)
library(data.table)


argsControl = FALSE

if(argsControl){
  args = commandArgs(trailingOnly = TRUE)
  #args should be (complete paths with '/' after directories) 1. file from which to extract nonground points, 2. directory in which to write output point cloud files, 3. whether or not to plot (default is FALSE) 4. whether or not to write (default is TRUE)

  # test if there is at least one argument: if not, return an error
  if (length(args) < 2) {
    stop("At least two arguments must be supplied: 1. file from which to extract nonground points and 2. directory in which to write output point cloud files. ", call.=FALSE)
  } else if (length(args)==2) {
    args[3] = FALSE
    args[4] = TRUE
  } else if(length(args ==3)){
    args[4] = TRUE
  }
  inFile = args[1]
  outDirec = args[2]
  plotControl = args[3]
  writeControl = args[4]
}

inFile = "Rectangular_UTMAZ_Tucson_2011_000564.las"
outDirec = "/Users/seanhendryx/Data/Lidar/SRER/AZ_Tucson_2011_000564/rectangular_study_area"
plotControl = FALSE
writeControl = TRUE

setwd(outDirec)
#Read in las file:
allPoints = readLAS(inFile)

dtm = grid_terrain(allPoints, res = .1, method = "knnidw")
# get header:
oheader = allPoints@header

#normalize las
lasnorm = lasnormalize(allPoints, dtm)

# compute a canopy image
chm = grid_canopy(lasnorm, res = 0.1, na.fill = "knnidw", k = 8)
chm = raster::as.raster(chm)

if(plotControl){
  raster::plot(chm)
  quartz.save("/Users/seanhendryx/Google Drive/THE UNIVERSITY OF ARIZONA (UA)/THESIS/Graphs/Alidar/Aerial Lidar CHM - MCC-Lidar Classing & KNN-IDW Rasterization.png")

  dev.off()
}

# smoothing post-process (e.g. 2x mean)
kernel = matrix(1,3,3)
schm = raster::focal(chm, w = kernel, fun = mean)
#schm = raster::focal(chm, w = kernel, fun = mean)

if(plotControl){
  raster::plot(schm, col = height.colors(50)) # check the image
  quartz.save("/Users/seanhendryx/Google Drive/THE UNIVERSITY OF ARIZONA (UA)/THESIS/Graphs/Alidar/Aerial Lidar SCHM - MCC-Lidar Classing & KNN-IDW Rasterization.png")

  dev.off()
}

# tree segmentation
# ‘th’ Numeric. Number value below which a pixel cannot be a crown.
#Default 2
crowns = lastrees(lasnorm, "watershed", schm, th = 1, extra = TRUE)

# Plotting point cloud of trees only:
# without rendering points that are not assigned to a tree
tree = lasfilter(lasnorm, !is.na(treeID))

plot(tree, color = "treeID", colorPalette = pastel.colors(100))

if(writeControl){
  #save tree point cloud (clustered point cloud):
  writeLAS(tree, "ALidar_Clustered_By_Watershed_Segmentation.las")
  #write.csv(tree@data, "all20TilesGroundClassified_and_Clustered_By_Watershed_Segmentation.csv")
  write_feather(tree@data, "Alidar_Clustered_By_Watershed_Segmentation.feather")
}

# Plotting raster with delineated crowns:
library(raster)
contour = rasterToPolygons(crowns, dissolve = TRUE)

if(plotControl){
  plot(schm, col = height.colors(50))
  plot(contour, add = T)
  quartz.save("/Users/seanhendryx/Google Drive/THE UNIVERSITY OF ARIZONA (UA)/THESIS/Graphs/Alidar/Watershed Segmented Smoothed ALidar & KNN-IDW Rasterization.png")
}

if(writeControl){
  # save smoothed canopy height model as tif
  writeRaster(schm, "ALidar_Smoothed_CHM.tif", format = "GTiff")
}
