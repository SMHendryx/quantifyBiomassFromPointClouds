# Trains a real-valued prediction model

library(feather)
library(lidR)
library(data.table)
library(randomForest)
library(ggplot2)


#getdata:

numColsToSave = ncol(metrics) - 29
cols = names(DT)[1:numColsToSave]
DT = DT[,.SD, .SDcols = cols]
