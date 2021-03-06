# Runs k-folds cross validation on a machine learning model

# Clear workspace:
rm(list=ls())
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

trainModel = function(LF, mtry, biasCorrection = FALSE) {
  if(missing(mtry)) {
    model = randomForest(LF$Label ~ ., data = LF, corr.bias=biasCorrection)
  }
  else {
    model = randomForest(LF$Label ~ ., data = LF, mtry = mtry, corr.bias=biasCorrection)
  }
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
  # Returns deterministic predictions using ecosystem-state allometric equation:
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

crossValidate = function(LF, k = 10, LOOCV = FALSE, write = TRUE, mtry, biasCorrection = FALSE){
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

    model = trainModel(trainDT, biasCorrection)
    #plot(model)
    #varImpPlot(model)

    tempValDT[,Deterministic_Predictions := testDeterministic(testDT)]
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

setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/rectangular_study_area/classified/watershed_after_remove_OPTICS_outliers/outlier_clusters")

LF = as.data.table(read_feather("../cluster_features_with_label.feather"))
LF[,Outlier_Cluster := FALSE][Cluster_ID == 78 | Cluster_ID == 4, Outlier_Cluster := TRUE]
setnames(LF, "in_situ_AGB_summed_by_cluster", "Label")

LF = LF[Outlier_Cluster == FALSE,]

#remove Cluster_ID because it is not a feature for prediction, only a bookkeeping index:
LF[,Cluster_ID := NULL]
LF[,Outlier_Cluster := NULL]

results = crossValidate(LF, LOOCV = TRUE, biasCorrection = FALSE)

modelErrors = getErrors(results$Actual, results$Model_Predictions)
deterministicErrors = getErrors(results$Actual, results$Deterministic_Predictions)
mesqAssumptionErrors = getErrors(results$Actual, results$Mesquite_Allometry_Assumed)
RFEcoAlloErrors = getErrors(results$Actual, results$Mean_RF_EcoAllo)

dRMSE = rmse(deterministicErrors)
print(paste("deterministic RMSE = ", dRMSE))
modelRMSE = rmse(modelErrors)
print(paste("randomForest RMSE = ", modelRMSE))

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


reducedPercentage = (dMAE - modelMAE)/dMAE
reducedPercentage
# with outlier clusters:
#0.355991
# By using the randomForest-cluster model, error was reduced by 35.6% from the deterministic model.

percReducedFromMesqAssumption = (mesqMAE - modelMAE)/mesqMAE
percReducedFromMesqAssumption


gridSearch = FALSE
if(gridSearch){
  #Grid search through mtry:
  mtries = seq(2,ncol(LF) - 2)
  modelMAEs = c()
  i = 1
  for(mtry in mtries){

    results = crossValidate(LF, LOOCV = TRUE, mtry = mtry, biasCorrection = FALSE)

    modelErrors = getErrors(results$Actual, results$Model_Predictions)
    #deterministicErrors = getErrors(results$Actual, results$Deterministic_Predictions)
    
    #dRMSE = rmse(deterministicErrors)
    print(paste("deterministic RMSE = ", dRMSE))
    modelRMSE = rmse(modelErrors)
    print(paste("randomForest RMSE = ", modelRMSE))


    #dMAE = mae(deterministicErrors)
    print(paste("deterministic MAE = ", dMAE))
    modelMAE = mae(modelErrors)
    print(paste("randomForest MAE = ", modelMAE))

    modelMAEs[[i]] = modelMAE

    reducedPercentage = (dMAE - modelMAE)/dMAE
    reducedPercentage

    i = i + 1
  }
  mtrySearchDT = data.table(mtry = mtries, model_MAE = modelMAEs, dMAE = dMAE)
  plot(mtrySearchDT$mtry, mtrySearchDT$model_MAE, main = "Grid Search Through RF mtry Parameter Settings", xlab = "mtry Parameter Setting", ylab = "Random Forest CV Mean Absolute Error (kg)")
  lines(mtrySearchDT$mtry, mtrySearchDT$model_MAE)
  #lines(dMAE)
}


eDT = as.data.table(cbind(modelErrors, deterministicErrors, mesqAssumptionErrors))
melted = melt(eDT)
dens = ggplot(data = melted, mapping = aes(x = value, color = variable)) + geom_density()

#plotting predicted over actual:
meltr = melt(results, measure.vars= c("Model_Predictions", "Deterministic_Predictions", "Mesquite_Allometry_Assumed"))
p = ggplot(data = meltr, mapping = aes(x = Actual, y = value, color = variable)) + geom_point() + theme_bw() + geom_smooth(method = "lm")
p = p + labs(x = "AGB Reference (kg)", y = "AGB Estimate (kg)")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
p = p + geom_abline(color = "red")



# Plotting cumulative errors:
eDT[,Actual := results[,Actual]][,Fold := results[,Fold]]
melted2 = melt(eDT, measure.vars = c("modelErrors", "deterministicErrors", "mesqAssumptionErrors"))
# this code isn't working: weird values for cumsum mesqAssumptionErrors
c = ggplot(data = melted2, mapping = aes(x = Fold, y = cumsum(value), color = variable)) + geom_line() + theme_bw() +  labs(x = "Fold", y = "Cumulative Difference from Test Data (kg)")# + ggtitle("Feature Family Subset Classification Performance")

cabs = ggplot(data = melted2, mapping = aes(x = Fold, y = cumsum(abs(value)), color = variable)) + geom_line() + theme_bw() +  labs(x = "Fold", y = "Cumulative Absolute Difference from Test Data (kg)")# + ggtitle("Feature Family Subset Classification Performance")

# Making column of cumulatively summed errors:
eDT[, cModelErrors := cumsum(modelErrors)][,cDeterministicErrors := cumsum(deterministicErrors)][,cMesqAssumptionErrors := cumsum(mesqAssumptionErrors)]
melted3 = melt(eDT, measure.vars = c("cModelErrors", "cDeterministicErrors", "cMesqAssumptionErrors"))
melted3[,c("modelErrors", "deterministicErrors", "mesqAssumptionErrors") := NULL]
c2 = ggplot(data = melted3, mapping = aes(x = Fold, y = value, color = variable)) + geom_line() + theme_bw() +  labs(x = "Fold", y = "Cumulative Difference from Test Data (kg)") + scale_color_hue(name = "Prediction Type", 
                      breaks=c("cModelErrors","cDeterministicErrors", "cMesqAssumptionErrors"), 
                      labels=c("RF Model Errors", "Ecosystem State Allometric Error", "Assumed Mesquite Allometric Error"))

eDT[, cModelErrors := cumsum(abs(modelErrors))][,cDeterministicErrors := cumsum(abs(deterministicErrors))][,cMesqAssumptionErrors := cumsum(abs(mesqAssumptionErrors))]
melted3 = melt(eDT, measure.vars = c("cModelErrors", "cDeterministicErrors", "cMesqAssumptionErrors"))
melted3[,c("modelErrors", "deterministicErrors", "mesqAssumptionErrors") := NULL]
c2 = ggplot(data = melted3, mapping = aes(x = Fold, y = value, color = variable)) + geom_line() + theme_bw() +  labs(x = "Fold", y = "Cumulative Difference from Test Data (kg)") + scale_color_hue(name = "Prediction Type", 
                      breaks=c("cModelErrors","cDeterministicErrors", "cMesqAssumptionErrors"), 
                      labels=c("RF Model Errors", "Ecosystem State Allometric Error", "Assumed Mesquite Allometric Error"))

p = ggplot(data = melted2, aes(x = Actual, y = abs(value), color = variable)) + geom_point() + theme_bw() + geom_smooth(method = "lm")+ labs(x = "AGB Reference (kg)", y = "|Error| of AGB Estimate (kg)")# + ggtitle("Feature Family Subset Classification Performance")

p = ggplot(data = melted2, aes(x = Actual, y = value, color = variable)) + geom_point() + theme_bw() + geom_smooth(method = "lm")


#Adding mean of RF and Ecosystem State Allometry model:
results[,Mean_RF_EcoAllo := ((Model_Predictions + Deterministic_Predictions)/2)]
eDT[,meanRFEcoAlloErrors := getErrors(results$Actual, results$Mean_RF_EcoAllo)]

#plotting predicted over actual:
meltr = melt(results, measure.vars= c("Model_Predictions", "Deterministic_Predictions", "Mesquite_Allometry_Assumed", "Mean_RF_EcoAllo"))
p = ggplot(data = meltr, mapping = aes(x = Actual, y = value, color = variable)) + geom_point() + theme_bw() + geom_smooth(method = "lm", se = FALSE)
p = p + labs(x = "AGB Reference (kg)", y = "AGB Estimate (kg)")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
p = p + geom_abline(color = "red") + scale_color_hue(name = "Prediction Type", 
                      breaks=c("Model_Predictions", "Deterministic_Predictions", "Mesquite_Allometry_Assumed", "Mean_RF_EcoAllo"), 
                      labels=c("Random Forest", "Ecosystem State Allometry", "Mesquite Allometry", "Mean of RF & Ecosystem State"))

# Making column of cumulatively summed errors:
eDT[, cModelErrors := cumsum(modelErrors)][,cDeterministicErrors := cumsum(deterministicErrors)][,cMesqAssumptionErrors := cumsum(mesqAssumptionErrors)][,cMeanRFEcoAllErrors := cumsum(meanRFEcoAlloErrors)]
melted3 = melt(eDT, measure.vars = c("cModelErrors", "cDeterministicErrors", "cMesqAssumptionErrors", "cMeanRFEcoAllErrors"))
melted3[,c("modelErrors", "deterministicErrors", "mesqAssumptionErrors") := NULL]
c3 = ggplot(data = melted3, mapping = aes(x = Fold, y = value, color = variable)) + geom_line() + theme_bw() +  labs(x = "Fold", y = "Cumulative Difference from Test Data (kg)") + scale_color_hue(name = "Prediction Type", 
                      breaks=c("cModelErrors","cDeterministicErrors", "cMesqAssumptionErrors", "cMeanRFEcoAllErrors"), 
                      labels=c("RF Model Errors", "Ecosystem State Allometric Error", "Assumed Mesquite Allometric Error", "Mean of RF & Ecosystem State"))


# Making column of cumulatively summed errors:
eDT[, cModelErrors := cumsum(abs(modelErrors))][,cDeterministicErrors := cumsum(abs(deterministicErrors))][,cMesqAssumptionErrors := cumsum(abs(mesqAssumptionErrors))][,cMeanRFEcoAllErrors := cumsum(abs(meanRFEcoAlloErrors))]
melted3 = melt(eDT, measure.vars = c("cModelErrors", "cDeterministicErrors", "cMesqAssumptionErrors", "cMeanRFEcoAllErrors"))
melted3[,c("modelErrors", "deterministicErrors", "mesqAssumptionErrors") := NULL]
c3 = ggplot(data = melted3, mapping = aes(x = Fold, y = value, color = variable)) + geom_line() + theme_bw() +  labs(x = "Fold", y = "Cumulative Absolute Difference from Test Data (kg)") + scale_color_hue(name = "Prediction Type", 
                      breaks=c("cModelErrors","cDeterministicErrors", "cMesqAssumptionErrors", "cMeanRFEcoAllErrors"), 
                      labels=c("RF Model Errors", "Ecosystem State Allometric Error", "Assumed Mesquite Allometric Error", "Mean of RF & Ecosystem State"))




#i am here
#now do t.test on errors to show significant reduction, do this on data with outlier clusters

