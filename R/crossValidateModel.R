# Runs k-folds cross validation on a machine learning model

library(lidR)
library(data.table)
library(feather)
library(ggplot2)
library(randomForest)
library(plyr)
source("~/githublocal/quantifyBiomassFromPointClouds/R/allometricEqns.R")


#Define functions:
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
  # Returns deterministic predictions
  
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


# Run main:
#k = 5

setwd("/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/mcc-s_point20_-t_point05/")

LF = as.data.table(read_feather("cluster_features_with_label.feather"))
LF[,Cluster_ID := NULL]
setnames(LF, "in_situ_AGB_summed_by_cluster", "Label")

#Remove any rows where label == NA
LF = LF[!is.na(Label),]

results = crossValidate(LF, LOOCV = TRUE)

#Adding mean of RF and Ecosystem State Allometry model:
results[,Mean_RF_EcoAllo := ((Model_Predictions + Deterministic_Predictions)/2)]
eDT[,meanRFEcoAlloErrors := getErrors(results$Actual, results$Mean_RF_EcoAllo)]


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

#density plot of errors:
eDT = as.data.table(cbind(modelErrors, deterministicErrors, mesqAssumptionErrors, RFEcoAlloErrors))
melted = melt(eDT)
dens = ggplot(data = melted, mapping = aes(x = value, color = variable)) + geom_density()

#plotting predicted over actual:
meltr = melt(results, measure.vars= c("Model_Predictions", "Deterministic_Predictions", "Mesquite_Allometry_Assumed", "Mean_RF_EcoAllo"))
p = ggplot(data = meltr, mapping = aes(x = Actual, y = value, color = variable)) + geom_point() + theme_bw() + geom_smooth(method = "lm", se = FALSE)
p = p + labs(x = "AGB Reference (kg)", y = "AGB Estimate (kg)")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
p = p + geom_abline(color = "darkblue") + scale_color_hue(name = "Prediction Type", 
                      breaks=c("Model_Predictions", "Deterministic_Predictions", "Mesquite_Allometry_Assumed", "Mean_RF_EcoAllo"), 
                      labels=c("Random Forest", "Ecosystem State Allometry", "Mesquite Allometry", "Mean of RF & Ecosystem State"))

# Making column of cumulatively summed errors:
eDT[, cModelErrors := cumsum(modelErrors)][,cDeterministicErrors := cumsum(deterministicErrors)][,cMesqAssumptionErrors := cumsum(mesqAssumptionErrors)][,cMeanRFEcoAllErrors := cumsum(RFEcoAlloErrors)]
#adding Fold index:
eDT[,Actual := results[,Actual]][,Fold := results[,Fold]]
melted3 = melt(eDT, measure.vars = c("cModelErrors", "cDeterministicErrors", "cMesqAssumptionErrors", "cMeanRFEcoAllErrors"))
melted3[,c("modelErrors", "deterministicErrors", "mesqAssumptionErrors") := NULL]
c3 = ggplot(data = melted3, mapping = aes(x = Fold, y = value, color = variable)) + geom_line() + theme_bw() +  labs(x = "Fold", y = "Cumulative Difference from Test Data (kg)") + scale_color_hue(name = "Prediction Type", 
                      breaks=c("cModelErrors","cDeterministicErrors", "cMesqAssumptionErrors", "cMeanRFEcoAllErrors"), 
                      labels=c("RF Model Errors", "Ecosystem State Allometric Error", "Assumed Mesquite Allometric Error", "Mean of RF & Ecosystem State"))


#adding Actual and Fold columns to error datatable:
eDT[,Actual := results[,Actual]][,Fold := results[,Fold]]
melted2 = melt(eDT, measure.vars = c("modelErrors", "deterministicErrors"))
c = ggplot(data = melted2, mapping = aes(x = Fold, y = cumsum(value), color = variable)) + geom_line() + theme_bw() +  labs(x = "Fold", y = "Cumulative Difference from Test Data (kg)")# + ggtitle("Feature Family Subset Classification Performance")

cabs = ggplot(data = melted2, mapping = aes(x = Fold, y = cumsum(abs(value)), color = variable)) + geom_line() + theme_bw() +  labs(x = "Fold", y = "Cumulative Absolute Difference from Test Data (kg)")# + ggtitle("Feature Family Subset Classification Performance")

#i am here
#now do t.test on errors to show significant reduction
t.test(abs(mesqAssumptionErrors), abs(RFEcoAlloErrors))

