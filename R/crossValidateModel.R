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
  # will work on a list of error values or a single error value (in which case, the same value is returned)
  return(sqrt(mean(errors^2)))
}


trainModel = function(LF){
  model = randomForest(LF$Label ~ ., data = LF)
  return(model)
}

testModel = function(LF, model){
  # Returns predictions
  # I am here this function needs testing
  F = copy(LF)
  F[,Label := NULL]
  predictions = as.data.table(as.data.frame(predict(model, F)))
  return(predictions)
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

crossValidate = function(LF, k = 10, LOOCV = FALSE, write = TRUE){
  # Runs cross-validation.  
  # param LF: a data.table with a column "Label" and all other columns are features.  Rows are observations.
  # param k: number of folds
  # param LOOCV: if TRUE, run Leave One Out Cross Val, i.e. numnber of folds = nrow(LF)
  # param write: if TRUE, writes csv of cross val results in current working directory
  # crossval inspiration taken from: https://gist.github.com/bhoung/11237681
  
  if(LOOCV){ks = seq(1, nrow(LF))} else {ks = 1:k}
  
  kid = sample(ks, nrow(LF), replace = TRUE)
  LF[,kid := kid]

  validationDT = data.table(Fold = NA_integer_, Model_Predictions = NA_integer_, Deterministic_Predictions = NA_integer_, Actual = NA_integer_)
  tempValDT = data.table(Fold = NA_integer_, Model_Predictions = NA_integer_, Deterministic_Predictions = NA_integer_, Actual = NA_integer_)
  
  #Creating a progress bar to know the status of CV
  progressBar = create_progress_bar("text")
  progressBar$init(k)

  for(fold in ks){
    #make training dataset:
    #sample(x, size, replace = FALSE, prob = NULL)
    #trainingset <- subset(data, id %in% list[-i])
    #testset <- subset(data, id %in% c(i))
    trainDT = copy(LF[kid %in% ks[-fold]])
    #trainDT = subset(LF, kid %in% ks[-fold])
    trainDT[,kid := NULL]
    #

    #make test dataset:
    testDT = copy(LF[kid == fold,])
    testDT[,kid := NULL]

    # I am here.  Update to code structure: make data.table of all predictions on test set and cbind with the actual values of the test set inside k-folds for loop
    model = trainModel(trainDT)
    
    tempValDT[,Deterministic_Predictions := testDeterministic(testDT)]
    tempValDT[,Model_Predictions := testModel(testDT, model)]
    tempValDT[,Actual := testDT$Label]
    tempValDT[,Fold := fold]
    validationDT = rbind(validationDT, tempValDT)
    

    #validationDT[Fold == fold, RMSE_deterministic := RMSE_deterministic]
    #validationDT[Fold == fold, RMSE_model := RMSE_model]
  }
  print(validationDT)
  if(write == TRUE){
    write.csv(validationDT, "crossValResults.csv")
  }
}
# End function definitions


# Run main:
k = 5

setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/rectangular_study_area/classified/watershed_after_remove_OPTICS_outliers")

LF = as.data.table(read_feather("cluster_features_with_label.feather"))
setnames(LF, "in_situ_AGB_summed_by_cluster", "Label")

crossValidate(LF, k)
