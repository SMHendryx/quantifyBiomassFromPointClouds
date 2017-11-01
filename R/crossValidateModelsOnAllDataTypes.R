# Runs k-folds cross validation on a machine learning model on a number of datasets
# Authored by Sean Hendryx at the University of Arizona 2017
# seanmhendryx@email.arizona.edu


library(lidR)
library(data.table)
library(feather)
library(ggplot2)
library(randomForest)
library(plyr)
source("~/githublocal/quantifyBiomassFromPointClouds/R/allometricEqns.R")


####-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------####
#
#    FUNCTION DEFINITIONS                                                                                                                                                                                      ####
#
####-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------####

# To compute RMSE, first get errors:
getErrors = function(measured, predicted){
  return(predicted - measured)
}

rmse = function(errors){
  # Computes Root Mean Square Error
  # will work on a list of error values or a single error value (in which case, the same value is returned)
  return(sqrt(mean(errors^2)))
}

mae = function(errors){
  # Computes Mean Absolute Error
  # will work on a list of error values or a single error value (in which case, the same value is returned)
  return(mean(abs(errors)))
}

#mae = function(measured, predicted){
#  # Computes Mean Absolute Error
#  # will work on a list of error values or a single error value (in which case, the same value is returned)
#  return(mean(abs(getErrors(measured, predicted))))
#}

trainModel = function(LF){
  model = randomForest(LF$Label ~ ., data = LF)
  return(model)
}

testModel = function(LF, model){
  # Returns model predictions
  
  F = copy(LF)
  F[,Label := NULL]
  predictions = as.data.table(as.data.frame(predict(model, F)))
  return(predictions)
}

#compute Canopy Area:
circArea = function(r){return(pi * (r^2))}

testDeterministic = function(LF){
  # Returns deterministic, ecosystem state allometric (ecoAllom) predictions
  
  LF = copy(LF)
  #compute PC cluster mean axis:
  LF[,Cluster_Mean_Axis := ((EWIDTH + NWIDTH)/2)]
  #compute Canopy Area:
  circArea = function(r){return(pi * (r^2))}
  # divide Mean_Axis by two to get radius:
  LF[,Cluster_CA := circArea(Cluster_Mean_Axis/2)]
  
  #compute ecoAllom, deterministic mass as baseline:
  deterministicPredictions = ecoAllom(LF[,Cluster_CA])
  return(deterministicPredictions)
  #errors = getErrors(LF[,Label], LF[,ecoAllom_AGB_cluster_measurements])
  #RMSE = rmse(errors)
  #return(RMSE)
}

assumeMesq = function(LF){
  # Returns deterministic predictions using ecosystem-state allometric equation:
  LF = copy(LF)
  #compute PC cluster mean axis:
  LF[,Cluster_Mean_Axis := ((EWIDTH + NWIDTH)/2)]
  #compute Canopy Area:
  circArea = function(r){return(pi * (r^2))}
  # divide Mean_Axis by two to get radius:
  LF[,Cluster_CA := circArea(Cluster_Mean_Axis/2)]
  
  #compute ecoAllom, deterministic mass as baseline:
  deterministicPredictions = mesqAllom(LF[,Cluster_CA])
  return(deterministicPredictions)
}


crossValidate = function(LF, k = 10, LOOCV = FALSE, write = TRUE){
  # Runs cross-validation.  
  # param LF: a data.table with a column "Label" and all other columns are features.  Rows are observations.
  # param k: number of folds
  # param LOOCV: if TRUE, run Leave One Out Cross Val, i.e. numnber of folds = nrow(LF)
  # param write: if TRUE, writes csv of cross val results in current working directory
  # crossval inspiration taken from: https://gist.github.com/bhoung/11237681
  
  if(LOOCV){
    ks = seq(1, nrow(LF))
    LF[,kid := ks]
  } else {
    ks = 1:k
    kid = sample(ks, nrow(LF), replace = TRUE)
    LF[,kid := kid]
  }
  
  validationDT = data.table(Fold = numeric(), Model_Predictions =  numeric(), Deterministic_Predictions =  numeric(), Mesquite_Allometry_Assumed = numeric(), Actual =  numeric())
  
  #Creating a progress bar to know the status of CV
  progressBar = create_progress_bar("text")
  progressBar$init(k)
  
  for(fold in ks){
    print(paste("Testing fold: ", fold))

    #make training dataset:
    trainDT = copy(LF[kid %in% ks[-fold]])
    #trainDT = subset(LF, kid %in% ks[-fold])
    trainDT[,kid := NULL]
    #

    #make test dataset:
    testDT = copy(LF[kid == fold,])
    #instantiate datatable to store the prediction & val results of this fold:
    tempValDT = data.table(Fold = testDT[,kid], Model_Predictions =  NA_integer_, Deterministic_Predictions =  NA_integer_, Mesquite_Allometry_Assumed = NA_integer_, Actual =  NA_integer_)
    testDT[,kid := NULL]

    model = trainModel(trainDT)
    
    #Deterministic, ecosystem state allometric function used:
    tempValDT[,Deterministic_Predictions := testDeterministic(testDT)]
    #Deterministic assumed mesquite allometry:
    tempValDT[,Mesquite_Allometry_Assumed := assumeMesq(testDT)]
    tempValDT[,Model_Predictions := testModel(testDT, model)]
    tempValDT[,Actual := testDT$Label]
    tempValDT[,Fold := fold]
    validationDT = rbind(validationDT, tempValDT)
    

    #validationDT[Fold == fold, RMSE_deterministic := RMSE_deterministic]
    #validationDT[Fold == fold, RMSE_model := RMSE_model]
  }
  print(validationDT)
  if(write == TRUE){
    write.csv(validationDT, "crossValResults.csv", row.names = FALSE)
  }
  return(validationDT)
}
# End function definitions


####-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------####
#
#    MAIN
#
####-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------####

resultsDirec = "/Users/seanhendryx/DATA/thesisResults"

datasetStrings = c("T-lidar", "A-lidar", "SfM")

directories = c("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/rectangular_study_area/classified/watershed_after_remove_OPTICS_outliers", 
                  "/Users/seanhendryx/DATA/Lidar/SRER/AZ_Tucson_2011_000564/rectangular_study_area/watershed_after_remove_OPTICS_outliers/buffer3", 
                  "/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/mcc-s_point20_-t_point05/buffer3/")

i = 1
for(directory in directories){
  #Set working directory from which to pull data:
  setwd(directory)

  LF = as.data.table(read_feather("cluster_features_with_label.feather"))
  LF[,Cluster_ID := NULL]
  setnames(LF, "in_situ_AGB_summed_by_cluster", "Label")

  #Remove any rows where label == NA
  LF = LF[!is.na(Label),]

  results = crossValidate(LF, LOOCV = TRUE)


  #Adding mean of RF and Ecosystem State Allometry model:
  results[,Mean_RF_EcoAllo := ((Model_Predictions + Deterministic_Predictions)/2)]
  #eDT[,meanRFEcoAlloErrors := getErrors(results$Actual, results$Mean_RF_EcoAllo)]

  modelErrors = getErrors(results$Actual, results$Model_Predictions)
  deterministicErrors = getErrors(results$Actual, results$Deterministic_Predictions)
  mesqAssumptionErrors = getErrors(results$Actual, results$Mesquite_Allometry_Assumed)
  RFEcoAlloErrors = getErrors(results$Actual, results$Mean_RF_EcoAllo)

  dRMSE = rmse(deterministicErrors)
  print(paste("deterministic RMSE = ", dRMSE))
  modelRMSE = rmse(modelErrors)
  print(paste("randomForest RMSE = ", modelRMSE))
  RFEcoAlloRMSE = rmse(RFEcoAlloErrors)

  mesqMAE = mae(mesqAssumptionErrors)
  mesqMAE
  dMAE = mae(deterministicErrors)
  print(paste("deterministic MAE = ", dMAE))
  modelMAE = mae(modelErrors)
  print(paste("randomForest MAE = ", modelMAE))
  RFEcoAlloMAE = mae(RFEcoAlloErrors)
  RFEcoAlloMAE

  errRedPercEcoAlloFromMesq = (mesqMAE - modelMAE)/mesqMAE
  print(paste("Error reduced by RF from assumed mesquite allometry: ", errRedPercEcoAlloFromMesq))
  errRedPercEcoAllo = (dMAE - modelMAE)/dMAE
  print(paste("Error reduced by RF from Ecosystem State allometry: ", errRedPercEcoAllo))

  errRedPercEcoAlloByMeanRFEcoAllo = (mesqMAE - RFEcoAlloMAE)/mesqMAE
  print(paste("Error reduced by mean of RF and Ecosystem State allometry: ", errRedPercEcoAlloByMeanRFEcoAllo))

  #Rename columns for consistency:
  #setnames(x,old,new)


  eDT = as.data.table(cbind(modelErrors, deterministicErrors, mesqAssumptionErrors, RFEcoAlloErrors))
  eDT[,fold := seq(nrow(eDT))]
  setkey(eDT, fold)


  #Rename columns for consistency:
  #setnames(x,old,new)
  setnames(eDT, "modelErrors", "RFCF")
  setnames(eDT, "deterministicErrors", "ESA")
  setnames(eDT, "mesqAssumptionErrors", "PV")
  setnames(eDT, "RFEcoAlloErrors", "RFCF_ESA")

  melted = melt(eDT, id.vars = "fold")

  setnames(melted, "value", "error")
  setnames(melted, "variable", "model")

  datasetString = datasetStrings[i]
  melted[,dataset := datasetString]

  if(i == 1){
    errors = copy(melted)
  } else {
    errors = rbind(melted, errors)
  }

  # Make cumulative errors data.table:
  rm(melted)
  eAbsDT = copy(eDT)
  eDT[, cModelErrors := cumsum(RFCF)][,cDeterministicErrors := cumsum(ESA)][,cMesqAssumptionErrors := cumsum(PV)][,cMeanRFEcoAllErrors := cumsum(RFCF_ESA)]
  eAbsDT[, cModelErrors := cumsum(abs(modelErrors))][,cDeterministicErrors := cumsum(abs(deterministicErrors))][,cMesqAssumptionErrors := cumsum(abs(mesqAssumptionErrors))][,cMeanRFEcoAllErrors := cumsum(abs(RFEcoAlloErrors))]

  #Delete columns that were not summed and rename with the model abbreviation
  #Example delete multiple columns:
  #DT[ ,c("x","y") := NULL]
  eDT[,c("RFCF", "ESA", "PV", "RFCF_ESA") := NULL]
  eAbsDT[,c("RFCF", "ESA", "PV", "RFCF_ESA") := NULL]

  # Change colnames
  setnames(eDT, "cModelErrors", "RFCF")
  setnames(eDT, "cDeterministicErrors", "ESA")
  setnames(eDT, "cMesqAssumptionErrors", "PV")
  setnames(eDT, "cMeanRFEcoAllErrors", "RFCF_ESA")
  # Change colnames
  setnames(eAbsDT, "cModelErrors", "RFCF")
  setnames(eAbsDT, "cDeterministicErrors", "ESA")
  setnames(eAbsDT, "cMesqAssumptionErrors", "PV")
  setnames(eAbsDT, "cMeanRFEcoAllErrors", "RFCF_ESA")

  melted = melt(eDT, id.vars = "fold")

  setnames(melted, "value", "error")
  setnames(melted, "variable", "model")

  melted2 = melt(eAbsDT, id.vars = "fold")

  setnames(melted2, "value", "absolute_error")
  setnames(melted2, "variable", "model")

  melted[,dataset := datasetString]

  melted[,absolute_error := melted2[,absolute_error]]

  if(i == 1){
    cumulativeErrors = copy(melted)
  } else {
    cumulativeErrors = rbind(melted, cumulativeErrors)
  }
  i = i + 1
  #end for loop, looping through data directories
}

write = TRUE
if(write){
  setwd(resultsDirec)
  write.csv(errors, paste0("Model_Errors.csv"))
  write_feather(errors, paste0("Model_Errors.feather"))
}

if(write){
  setwd(resultsDirec)
  write.csv(cumulativeErrors, paste0("Cumulative_Model_Errors.csv"))
  write_feather(cumulativeErrors, paste0("Cumulative_Model_Errors.feather"))
}


####-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------####
#
#    PLOTTING                                                                                                                                                                                               ####
#
####-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------####

#density plot of errors:
dens = ggplot(data = melted, mapping = aes(x = error, color = model)) + geom_density() + theme_bw() + labs(x = "Error (kg)") + theme(legend.title=element_blank())

dens



