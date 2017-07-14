# Trains a real-valued prediction model

library(feather)
library(lidR)
library(data.table)
library(randomForest)
library(ggplot2)


#getdata:
setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/OPTICS_Param_Tests/study-area")
DT = as.data.table(read_feather("cluster_features.feather"))

numColsToSave = ncol(DT) - 29
cols = names(DT)[1:numColsToSave]
DT = DT[,.SD, .SDcols = cols]
