library(lidR)
library(data.table)
library(ggplot2)
library(grid)


allTiles = readLAS("/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/Merged_Ground_Classified.las")

mu = mean(allTiles@data[Classification==2, Z])

sigma = sd(allTiles@data[Classification==2, Z])

setwd("/Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/PMF/tiles")
files = list.files()
for(file in files){
  las = readLAS(file)
  las = las %>% lasfilter(Z > (mu- (.75 *sigma)))
  writeLAS(las, paste0("/Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/mcc-s_point20_-t_point05/notRun/pointsBelowMuMinus.75SigmaRemoved/", file))
}

