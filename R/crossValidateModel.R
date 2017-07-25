# Runs k-folds cross validation on a machine learning model

library(lidR)
library(data.table)
library(feather)
library(ggplot2)


k = 5

setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/rectangular_study_area/classified/watershed_after_remove_OPTICS_outliers")

LF = as.data.table(read_feather("cluster_features_with_label.feather"))

trainModel = function(LF){

}

testModel = function(LF, model){

}

crossValidate = function(LF, k = 10){
  for(fold in seq(1,k)){
    #make training dataset:
    trainDT = 
    model = trainModel(trainDT)
    
    #make test dataset:
    testDT = 
    testModel(testDT, model)
  }
}