# plotCHM.R
# Clear workspace:
rm(list=ls())
library(lidR) #detach("package:lidR", unload=TRUE)
library(data.table) #detach("package:data.table", unload=TRUE)
library(raster) #detach("package:raster", unload=TRUE)
library(rgeos)
#library(rLiDAR) After loading: The following object is masked from ‘package:lidR’: readLAS
#detach("package:rLiDAR", unload=TRUE)
library(ggplot2)
#library(sp) #already loaded

#load in dtm generated from FUSION:
dtm = raster("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/inputData/FUSIONgroundSurfaceFromtLidarSRERMesTowerOct2015.dtm")

plot(dtm)


#E.g.: Use lasclassify with shapefiles to filter lakes

#Load the data and read a shapefile


tLidar = readLAS("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/inputData/outputDirectory/Decimated_Cropped_SOR_Cleaned_CC-Default-tLidarSRERMesTowerOct2015.las")

#tLidar = readLAS(LASfile) #doesn't work: 
#Error: Unable to read any input file(s)
#In addition: Warning messages:
#1: File(s)  not found 
#2: File(s) NA not supported 

#For example to read ‘bounds.shp’ from ‘C:/Maps’, do ‘map <- readOGR(dsn="C:/Maps", layer="bounds")’
bounds  = rgdal::readOGR(dsn = "/Users/seanhendryx/DATA/Lidar/SRER", layer = "Rectangular_Study_Area_UTM_EPSG26912")
#bounds  = rgdal::readOGR(shapefile_dir, "SfMWithHighImageryOverlapCloudAndtLidarCloudOverlap")

#Classify the points
lasclassify(tLidar, bounds, field="outside")

# Apply lasfilter to create new las object including points only inside study bounds:
studyArea = tLidar %>% lasfilter(outside == TRUE)

writeLAS(studyArea, "/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/inputData/outputDirectory/Rectangular_Decimated_SOR_Cleaned_CC-Default-tLidarSRERMesTowerOct2015.las")

#Get area of studyArea:
# and calculate the area
area = gArea(bounds)
# 7913.345 square meters ~= .79 hectares



plot(studyArea)







#Compute density for MCC alg.
#density = length(unique(pulseID))/area
# program numPulses instead
numPulses = 102557635
density = numPulses/area
# 7994.257 pulses/m^2 = 0.7994257 pulses/cm^2
#compute spatial sampling frequency (post spacing):
# 0.35 m/pulse = 1/sqrt(8 pulses/m2
samplingFreq = 1/sqrt(density)
# samplingFreq = 0.01118436 m


#Trying lasdecimate():
#If starting here:
studyArea = readLAS("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/inputData/outputDirectory/Cropped_SOR_Cleaned_CC-Default-tLidarSRERMesTowerOct2015.las")

studyArea %>% grid_density(res = 1) %>% plot

# lasdecimate doesn't seem to be working since pulseID all equal 1
# So set pulse id to sequence
dims = dim(studyArea$data)
length = dims[1]
studyArea$data[,pulseID := seq(length.out = length)]
thinned = lasdecimate(studyArea, density = 1000,resolution = 1)
# Works!
#writeLAS(thinned, "/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/inputData/outputDirectory/Decimated_Cropped_SOR_Cleaned_CC-Default-tLidarSRERMesTowerOct2015.las")
thinned %>% grid_density(res = 1) %>% plot

#here
numPulses = dim(thinned$data)[1]
density = numPulses/area
samplingFreq = 1/sqrt(density)



writeLAS(thinned, "/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/inputData/outputDirectory/Decimated_Cropped_SOR_Cleaned_CC-Default-tLidarSRERMesTowerOct2015.las")

#Read in point cloud classified by MCC-lidar
classified = readLAS("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/inputData/outputDirectory/Classified_Decimated_Cropped_SOR_Cleaned_CC-Default-tLidarSRERMesTowerOct2015.las")

#generate DTM:
#with kriging:
dtm = grid_terrain(classified, method = "kriging", k = 10L)

#normalize heights








DSM = grid_metrics(thinned, max(Z), res = 1)
plot(DSM)

DSM_thick = grid_metrics(studyArea, max(Z), res = .1)
plot(DSM_thick)

#plot(tLidar) # too much data to render
# plot(studyArea) # ditto ^


















#Old code below

#' Transform raster to data.table
#' 
#' @param x  Raster* object
#' @param row.names `NULL` or a character vector giving the row names for the data frame. Missing values are not allowed
#' @param optional  logical. If `TRUE`, setting row names and converting column names (to syntactic names: see make.names) is optional
#' @param xy  logical. If `TRUE`, also return the spatial coordinates
#' @param centroids logical. If TRUE return the centroids instead of all spatial coordinates (only relevant if xy=TRUE)
#' @param sepNA logical. If TRUE the parts of the spatial objects are separated by lines that are NA (only if xy=TRUE and, for polygons, if centroids=FALSE
#' @param ...  Additional arguments (none) passed to `raster::as.data.frame`
#' 
#' @value returns a data.table object
#' @examples
#' logo <- brick(system.file("external/rlogo.grd", package="raster"))
#' v <- as.data.table(logo)
#' @import

as.data.table.raster <- function(x, row.names = NULL, optional = FALSE, xy=FALSE, inmem = canProcessInMemory(x, 2), ...) {
  stopifnot(require("data.table"))
  if(inmem) {
    v <- as.data.table(as.data.frame(x, row.names=row.names, optional=optional, xy=xy, ...))
  } else {
    tr <- blockSize(x, n=2)
    l <- lapply(1:tr$n, function(i) 
      as.data.table(as.data.frame(getValues(x, 
                                            row=tr$row[i], 
                                            nrows=tr$nrows[i]), 
                                  row.names=row.names, optional=optional, xy=xy, ...)))
    v <- rbindlist(l)
  }
  coln <- names(x)
  if(xy) coln <- c("x", "y", coln)
  setnames(v, coln)
  v
}

if (!isGeneric("as.data.table")) {
  setGeneric("as.data.table", function(x, ...)
    standardGeneric("as.data.table"))
}  

setMethod('as.data.table', signature(x='data.frame'), data.table::as.data.table)
setMethod('as.data.table', signature(x='Raster'), as.data.table.raster)

###################################################################################################################################################################################################
#Aerial lidar
file <- "aLidarCHM.max.grid"
path <- "/Users/seanhendryx/DATA/Lidar/SRER/AZ_Tucson_2011_000564/points2grid/CHM"
setwd(path)

CHM <- raster(file)
CHM[CHM < 0] <- NA

plot(CHM, main = "Canopy Height Model from Aerial Lidar 2011 SRER", col = gray.colors(256000, start = 0.0, end = 0.99, gamma = 2.2, alpha = NULL), legend.only = FALSE,  legend.args=list(text='Meters'))
#plot(CHM, main = "Canopy Height Model from Aerial Lidar 2011 SRER", legend.only = FALSE,  legend.args=list(text='Meters'))

###################################################################################################################################################################################################
#Structure from Motion

path <- "/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/OptimizedByGCPsAndGeoreferencedInPhotoscan/RISE"
file <- "SfMCHM.max.grid"
setwd(path)

CHM <- raster(file)
CHM[CHM < 0] <- NA

dev.new()
plot(CHM, main = "Structure from Motion CHM 2016 SRER", col = gray.colors(256000, start = 0.0, end = 0.99, gamma = 2.2, alpha = NULL), legend.only = FALSE,  legend.args=list(text='Meters'))
#dev.new()
#plot(CHM, main = "Structure from Motion CHM 2011 SRER", legend.only = FALSE,  legend.args=list(text='Meters'))



################################################################################################################################################################################################################################################################################################################################
#SfM LAStools "bulge" param experiments:
#file <-"SfMCHMBulge1.max.grid"

#CHM <- raster(file)
#CHM[CHM < 0] <- NA

#plot(CHM, main = "Bulge 1Structure from Motion CHM 2016 SRER", col = gray.colors(256000, start = 0.0, end = 0.99, gamma = 2.2, alpha = NULL), legend.only = FALSE,  legend.args=list(text='Meters'))
################################################################################################################################################################################################################################################################################################################################



###################################################################################################################################################################################################
#Structure from Motion
# NO DEPTH FILTERING

path <- "/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/noDepthFiltering/outputDir"
file <- "NoDepthFilterSfMCHM.max.grid"
setwd(path)

noDepthFilterCHM <- raster(file)
noDepthFilterCHM[noDepthFilterCHM < 0] <- NA

dev.new()
plot(noDepthFilterCHM, main = "No Depth Filter SfM CHM 2016 SRER", col = gray.colors(256000, start = 0.0, end = 0.99, gamma = 2.2, alpha = NULL), legend.only = FALSE,  legend.args=list(text='Meters'))
#looks terrible



#Plotting DTM:
file <- "/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/noDepthFiltering/outputDir/DTM.tif"
DTM <- raster(file)
DTM[DTM < 0] <- NA
DTM[DTM < 900] <- NA

dev.new()
plot(DTM, main = "No Depth Filter SfM DTM 2016 SRER", col = gray.colors(256000, start = 0.0, end = 0.99, gamma = 2.2, alpha = NULL), legend.only = FALSE,  legend.args=list(text='Meters'))












