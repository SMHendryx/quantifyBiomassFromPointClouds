# tileR tests
# Clear workspace:
rm(list=ls())
library(lidR)
library(data.table)

# I am here:
setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/inputData/outputDirectory/watershedBeforeClipToRectangular/tiles")

tLidar = readLAS("../Decimated_SOR_Cleaned_CC-Default-tLidarSRERMesTowerOct2015.las")

source("/Users/seanhendryx/githublocal/tileR/tileR.R")

tileR(tLidar, c(4,5))

# merge with rbind in R or lasmerge lastools utility:
#mergedBackTogether = readLAS("merged.las")
#plot(mergedBackTogether)