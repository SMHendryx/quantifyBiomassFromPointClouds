# Making and plotting catalog of las tiles on local machine

# Clear workspace:
rm(list=ls())
library(lidR) #detach("package:lidR", unload=TRUE)
#library(ggplot2)


setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/inputData/outputDirectory/watershedBeforeClipToRectangular/tiles")

files = list.files()

#plot one:
#las = readLAS(files[11])
#plot(las)


for (file in files){
    tile = readLAS(file)
    plot(tile)
}


for (file in files){
    tile = readLAS(file)
    plot(tile, color = "Classification")
}

#"File with most ground points: tile-20_PMF_MWS7Sp5IDp05CSp1.las"
