# runs lidR's Progressive Morphological Filter for ground delineation
#should be run from directory within which you want files to be written.
# Written files will be written inside a newly created di

# Clear workspace:
rm(list=ls())
library("lidR")
library("data.table")
source("/Users/seanhendryx/githublocal/quantifyBiomassFromPointClouds/R/filesNotRun.R")


#setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/rectangular_study_area/tiles")
# cd /Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/inputData/outputDirectory/watershedBeforeClipToRectangular

# make list of files not run by MCC:
inDirec = "/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/inputData/outputDirectory/watershedBeforeClipToRectangular/tiles/"
outDirec = "/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/inputData/outputDirectory/watershedBeforeClipToRectangular/groundClassified/tiles/"
extension = ".las"
lasFiles = filesNotRun(inDirec, outDirec, extension)

# ground classification:
for (file in lasFiles){
  las = readLAS(paste0(inDirec, file))
  lasground(las, MaxWinSize = 10, Slope = .5, InitDist = 0.05, CellSize = 7)
  writeLAS(las, paste0("PMF_groundClassified/tiles", file))
}

