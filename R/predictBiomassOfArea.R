# Runs the prediction model on the entire point cloud file.
# Authored by Sean Hendryx at the University of Arizona 2017
# seanmhendryx@email.arizona.edu


library(lidR)
library(data.table)
library(feather)
library(ggplot2)
library(randomForest)
library(plyr)
source("~/githublocal/quantifyBiomassFromPointClouds/R/allometricEqns.R")
#redefining rLiDAR's crownMetrics to allow for NAs in Intensity since not all point clouds have intensity (also extended default precision to 5 decimal places):
source("~/githublocal/quantifyBiomassFromPointClouds/R/CrownMetrics.R")


#------------------------------------------------------------------------------------------------------------------------------#
#         FUNCTION DEFINITIONS                                                                                                 #
#------------------------------------------------------------------------------------------------------------------------------#

trainRF = function(LF){
  model = randomForest(LF$Label ~ ., data = LF)
  return(model)
}

runRF = function(RF, F){
  # Returns random forest model predictions
  F = copy(LF)
  F[,Label := NULL]
  predictions = as.data.table(as.data.frame(predict(RF, F)))
  return(predictions)
}

ESA = function(F){
  # Returns deterministic, ecosystem state allometric (ecoAllom) predictions
  # this function is alternately called testDeterministic in other files
  
  F = copy(F)
  #compute PC cluster mean axis:
  F[,Cluster_Mean_Axis := ((EWIDTH + NWIDTH)/2)]
  #compute Canopy Area:
  circArea = function(r){return(pi * (r^2))}
  # divide Mean_Axis by two to get radius:
  F[,Cluster_CA := circArea(Cluster_Mean_Axis/2)]
  
  #compute ecoAllom, deterministic mass as baseline:
  deterministicPredictions = ecoAllom(F[,Cluster_CA])
  return(deterministicPredictions)
  #errors = getErrors(LF[,Label], LF[,ecoAllom_AGB_cluster_measurements])
  #RMSE = rmse(errors)
  #return(RMSE)
}

runModel = function(RF, F){
  #Runs the ensemble model which is the mean of the random forest and the ecosystem state allometric equation
  ESA_pred = ESA(F)
  RF_pred = runRF(RF, F)
  model_pred = (ESA_pred + RF_pred)/2.0
  return(model_pred)
}

extractFeatures = function(clusters){
  #Extract the features for each cluster (treeID)
  discardIntensity = TRUE

  #setwd("/Users/seanhendryx/Data/Lidar/SRER/AZ_Tucson_2011_000564/rectangular_study_area/")

  # Read in data:
  # read in clustered point cloud:
  #clusters = as.data.table(read_feather("Alidar_Clustered_By_Watershed_Segmentation.feather"))
  #colnames(clusters)[1] = 'X'

  '%!in%' = function(x,y)!('%in%'(x,y))

  #add empty intensity if it doesn't exist
  if("Intensity" %!in% colnames(clusters)){
    clusters[,Intensity := numeric()]
  }
    
  metrics = CrownMetrics(as.matrix(clusters[,.(X,Y,Z,Intensity, treeID)]), na_rm = TRUE, digits = 5)

  DT = as.data.table(metrics)


  #required for writing to feather (write list not implemented):
  DT = as.data.table(apply(DT,MARGIN = 2,as.numeric))

  #To read in if restarting from here:
  #DT = as.data.table(read_feather("cluster_features.feather"))
  setnames(DT, "Tree", "Cluster_ID")

  if(discardIntensity){
    numColsToSave = ncol(DT) - 29
    cols = names(DT)[1:numColsToSave]
    DT = DT[,.SD, .SDcols = cols]
  }
  return(DT)
}

# END FUNCTION DEFINTIONS


####-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------####
#                                                                                                                                                                                                              ####
#    MAIN                                                                                                                                                                                                      ####
#                                                                                                                                                                                                              ####
####-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------####

# Read in point cloud file:
# Need to get this off of other machine/google drive:
clusteredStudayAreaPointCloud = "TLidar_Clustered_By_Watershed_Segmentation.feather"
clusters = as.data.table(read_feather(clusteredStudayAreaPointCloud)

# Read in cluster features for model training:
directory = "/path/to/cluster_features"
setwd(directory)
LF = as.data.table(read_feather("cluster_features_with_label.feather"))
LF[,Cluster_ID := NULL]
setnames(LF, "in_situ_AGB_summed_by_cluster", "Label")

#Remove any rows where label == NA
LF = LF[!is.na(Label),]

#Train RF:
RF = trainRF(LF)

#Extract features from point cloud:
F = extractFeatures(clusters)

modelPredictions = runModel(RF, F)

# Sum biomass of all clusters to get estimate of total study area biomass:
print("Summed biomass of all clusters to get estimate of total study area biomass:")
sum(modelPredictions)



#