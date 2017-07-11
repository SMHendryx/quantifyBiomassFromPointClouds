# plotCHM.R
# Clear workspace:
rm(list=ls())
library(lidR) #detach("package:lidR", unload=TRUE)
library(data.table) #detach("package:data.table", unload=TRUE)
library(raster) #detach("package:raster", unload=TRUE)
library(ggplot2)


studyArea = readLAS("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/inputData/outputDirectory/SOR_Cleaned_CC-Default-tLidarSRERMesTowerOct2015.las")

#studyArea %>% grid_density(res = 1) %>% plot

# lasdecimate doesn't seem to be working since pulseID all equal 1
# So set pulse id to sequence
dims = dim(studyArea$data)
length = dims[1]
studyArea$data[,pulseID := seq(length.out = length)]
thinned = lasdecimate(studyArea, density = 1000,res = 1)
# Works!
writeLAS(thinned, "/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/inputData/outputDirectory/watershedBeforeClipToRectangular/Decimated_SOR_Cleaned_CC-Default-tLidarSRERMesTowerOct2015.las")

