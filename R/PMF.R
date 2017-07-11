# runs lidR's Progressive Morphological Filter for ground delineation

# Clear workspace:
rm(list=ls())

library("lidR")
library("data.table")


#setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/rectangular_study_area/tiles")

# read file
files = list.files()
lasFiles = fileList[grep("*.las", fileList)]
rm(files)

# ground classification:
for (file in lasFiles){
  las = readLAS(file)
  lasground(las, MaxWinSize = 10, Slope = .5, InitDist = 0.05, CellSize = 7)
  writeLAS(las, paste0("groundClassified/", file))
}

