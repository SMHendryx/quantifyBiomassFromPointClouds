# runs lidR's Progressive Morphological Filter for ground delineation
# should be run from directory within which you want files to be written.
# Written files will be written inside a newly created di

# Clear workspace:
rm(list=ls())
library("lidR")
library("data.table")
source("/Users/seanhendryx/githublocal/quantifyBiomassFromPointClouds/R/filesNotRun.R")

args = commandArgs(trailingOnly = TRUE)
#args should be 1. working directory, 2. inDirec: directory containing files that were input to the process, and 3. outDirec: directory containing files that were output by the process

# test if there is at least one argument: if not, return an error
if (length(args)!=3) {
  stop("Length of arguments must be 3.", call.=FALSE)
}

workingDirectoryPath = args[1]
inDirec = args[2]
outDirec = args[3]
#workingDirectoryPath = "/Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/classified/PMF/tiles"
#inDirec = "/Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/tiles"
#outDirec = "/Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/classified/mcc-s_point20_-t_point05/tiles"

setwd(workingDirectoryPath)

# make list of files not run by MCC:
extension = ".las"
lasFiles = filesNotRun(inDirec, outDirec, extension)

print("Ground classifying files:")
print(lasFiles)

numFiles = length(lasFiles)

# ground classification:
i = 1
for (file in lasFiles){
  print(paste0("Classifying file: ", file))
  print(paste0(i, " of ", numFiles))
  las = readLAS(paste0(inDirec, file))
  lasground(las, MaxWinSize = 10, Slope = .5, InitDist = 0.05, CellSize = 7)
  writeLAS(las, file)
  print(paste0(file, " ground classified by PMF and written."))
  i = i + 1
}

