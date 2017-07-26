# Runs k-folds cross validation on a machine learning model

library(lidR)
library(data.table)
library(feather)
library(ggplot2)
library(randomForest)
source("~/githublocal/quantifyBiomassFromPointClouds/R/allometricEqns.R")


# To compute RMSE, first get errors:
getErrors = function(measured, predicted){
  return(measured - predicted)
}

#Define functions:
rmse = function(errors){
  return(sqrt(mean(errors^2)))
}


trainModel = function(LF){
  model = randomForest(LF$Label ~ ., data = LF)
  return(model)
}

testModel = function(LF, model){

}

#compute Canopy Area:
circArea = function(r){return(pi * (r^2))}

testDeterministic = function(LF){
  # Functoin returns RMSE on test set

  LF = copy(LF)
  #compute PC cluster mean axis:
  LF[,Cluster_Mean_Axis := ((EWIDTH + NWIDTH)/2)]
  #compute Canopy Area:
  circArea = function(r){return(pi * (r^2))}
  # divide Mean_Axis by two to get radius:
  LF[,Cluster_CA := circArea(Cluster_Mean_Axis/2)]

  #compute ecoAllom, deterministic mass as baseline:
  LF[,ecoAllom_AGB_cluster_measurements := ecoAllom(Cluster_CA)]

  errors = getErrors(LF[,Label], LF[,ecoAllom_AGB_cluster_measurements])
  RMSE = rmse(errors)
  return(RMSE)
}

crossValidate = function(LF, k = 10){
  # crossval inspiration taken from: https://gist.github.com/bhoung/11237681
  
  ks = 1:k
  kid = sample(ks, nrow(LF), replace = TRUE)
  LF[,kid := kid]

  validationDT = data.table(Fold = ks, RMSE_model = NA_integer_, RMSE_deterministic = NA_integer_)

  #Creating a progress bar to know the status of CV
  progressBar = create_progress_bar("text")
  progressBar$init(k)

  for(fold in ks){
    #make training dataset:
    #sample(x, size, replace = FALSE, prob = NULL)
    #trainingset <- subset(data, id %in% list[-i])
    #testset <- subset(data, id %in% c(i))
    trainDT = copy(LF[kid %in% ks[-fold]])
    trainDT[,kid := NULL]
    #trainDT = subset(LF, kid %in% ks[-fold])

    #make test dataset:
    testDT = copy(LF[kid == fold,])
    testDT[,kid := NULL]

    model = trainModel(trainDT)

    RMSE_deterministic = testDeterministic(testDT)
    validationDT[Fold == fold, RMSE_deterministic := RMSE_deterministic]

    testModel(testDT, model)
  }
}
# End function definitions


# Run main:
k = 5

setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/rectangular_study_area/classified/watershed_after_remove_OPTICS_outliers")

LF = as.data.table(read_feather("cluster_features_with_label.feather"))
setnames(LF, "in_situ_AGB_summed_by_cluster", "Label")

