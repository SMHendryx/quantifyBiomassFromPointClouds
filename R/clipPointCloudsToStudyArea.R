# Clips point cloud to only those points INSIDE shapefile
# Clear workspace:
rm(list=ls())
library(lidR) 
library(data.table) 
library(raster) 
library(rgeos)



args = commandArgs(trailingOnly = TRUE)
#args should be 1. directory, 2. input las file to clip, and 3. whether or not to plot

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==2) {
  args[3] = FALSE
}

directoryPath = args[1]
file = args[2]
plotControl = args[3]

setwd(directoryPath)
pointCloud = readLAS(file)

#For example to read ‘bounds.shp’ from ‘C:/Maps’, do ‘map <- readOGR(dsn="C:/Maps", layer="bounds")’
bounds  = rgdal::readOGR(dsn = "/Users/seanhendryx/DATA/Lidar/SRER", layer = "Rectangular_Study_Area_UTM_EPSG26912")
#bounds  = rgdal::readOGR(shapefile_dir, "SfMWithHighImageryOverlapCloudAndtLidarCloudOverlap")

#Classify the points
lasclassify(pointCloud, bounds, field="outside")

# Apply lasfilter to create new las object including points only inside study bounds:
studyArea = pointCloud %>% lasfilter(outside == TRUE)

writeLAS(studyArea, paste0("rectangular_study_area/Rectangular_", file))

#Get area of studyArea:
# and calculate the area
area = gArea(bounds)
print(area)
print("Should be: ")
print("7913.345 square meters ~= .79 hectares")

if(plotControl == TRUE){
  plot(studyArea)
}

print("EXIT_SUCCESS")
