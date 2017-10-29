# Runs the prediction model on the entire point cloud file.
# Authored by Sean Hendryx at the University of Arizona 2017
# seanmhendryx@email.arizona.edu


library(lidR)
library(data.table)
library(feather)
library(ggplot2)
library(randomForest)
library(plyr)
source("~/githublocal/quantifyBiomassFromPointClouds/quantifyBiomassFromPointClouds/R/allometricEqns.R")
#redefining rLiDAR's crownMetrics to allow for NAs in Intensity since not all point clouds have intensity (also extended default precision to 5 decimal places):
source("~/githublocal/quantifyBiomassFromPointClouds/quantifyBiomassFromPointClouds/R/CrownMetrics.R")


#------------------------------------------------------------------------------------------------------------------------------#
#         FUNCTION DEFINITIONS                                                                                                 #
#------------------------------------------------------------------------------------------------------------------------------#

trainRF = function(LF){
  model = randomForest(LF$Label ~ ., data = LF)
  return(model)
}

runRF = function(RF, F){
  # Returns random forest model predictions
  F = copy(F)
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

# Read in data:
directory = "/Users/seanmhendryx/Data/thesis/Processed_Data/A-lidar/predictBiomassOfArea"
setwd(directory)

clusteredStudayAreaPointCloud = "ALidar_Clustered_By_Watershed_Segmentation.feather"
clusters = as.data.table(read_feather(clusteredStudayAreaPointCloud))

plotter = TRUE
if(plotter){
  #plot(clusters$X, clusters$Y, col=as.factor(clusters$treeID))
  cbf = c(#"#000000", 
    "#be408c",
    "#4cdc8b",
    "#b1379e",
    "#90d15e",
    "#442986",
    "#dab528",
    "#577ceb",
    "#cba815",
    "#424cad",
    "#acbd3d",
    "#745bc4",
    "#7bcf6e",
    "#863c9f",
    "#4eaa4c",
    "#e768c5",
    "#669b2c",
    "#9e7ee9",
    "#2e7c23",
    "#c180e2",
    "#a6bf55",
    "#6d1b66",
    "#37d8b0",
    "#c42a6d",
    "#5dba6f",
    "#8d3f90",
    "#af9a23",
    "#6d7ddb",
    "#e7af45",
    "#468ae0",
    "#dd8026",
    "#4e62aa",
    "#c1851b",
    "#3d3072",
    "#bdb553",
    "#835fb5",
    "#70851b",
    "#e592e6",
    "#255719",
    "#b765b8",
    "#3eac74",
    "#992963",
    "#77daa9",
    "#ab2540",
    "#36dee6",
    "#cd3e43",
    "#3aad8c",
    "#e25968",
    "#458541",
    "#db81c4",
    "#516f1d",
    "#c093db",
    "#817614",
    "#7199e0",
    "#a54909",
    "#894f8e",
    "#9fc069",
    "#6b1740",
    "#8cbf79",
    "#d95987",
    "#b9b567",
    "#97436d",
    "#e0b75e",
    "#de7bae",
    "#818035",
    "#d04c6c",
    "#b18b34",
    "#e67d9f",
    "#a06919",
    "#822131",
    "#d0a865",
    "#7d2716",
    "#e29249",
    "#c76674",
    "#80591b",
    "#e77162",
    "#9e3119",
    "#e1925d",
    "#d26c69",
    "#d16c2f",
    "#c46d53",
    "#e26a4a",
    "#aa612f")

  cbf240 = c("#9367d4",
    "#2dae15",
    "#724fe2",
    "#8dce23",
    "#3f3ac2",
    "#5ae869",
    "#a053e1",
    "#3cbe3a",
    "#6f2bae",
    "#9be04c",
    "#9f6bf8",
    "#61b928",
    "#c947cd",
    "#b3d029",
    "#5969f0",
    "#c6cc27",
    "#8f1ea3",
    "#40ca6a",
    "#e83bbc",
    "#359721",
    "#b152d3",
    "#73ae22",
    "#b91ea2",
    "#8edf74",
    "#e66eec",
    "#71c050",
    "#5b3dac",
    "#d7c629",
    "#4250c2",
    "#ecc02b",
    "#7f73ed",
    "#87aa23",
    "#ba71ea",
    "#bbd14f",
    "#7f2d93",
    "#57e298",
    "#ef3ba5",
    "#539322",
    "#aa329c",
    "#479e46",
    "#ce268c",
    "#30af6a",
    "#f33a81",
    "#5cdfb5",
    "#e72525",
    "#48e5d5",
    "#e52740",
    "#45dbf1",
    "#ef4e25",
    "#436ed7",
    "#e9a226",
    "#695dbf",
    "#b7d165",
    "#8f4ab1",
    "#7eab3e",
    "#f570d4",
    "#297627",
    "#d55bc0",
    "#98a633",
    "#8c7ce2",
    "#eac252",
    "#5c3e94",
    "#d4c95c",
    "#3f4b9b",
    "#e9902b",
    "#458ee8",
    "#e9711f",
    "#778aed",
    "#c77715",
    "#2f63ac",
    "#cf4b15",
    "#53a4e5",
    "#d73a2d",
    "#45ccbc",
    "#e3245f",
    "#33b18b",
    "#a6186a",
    "#a7d479",
    "#872b83",
    "#90db9e",
    "#ae3388",
    "#688620",
    "#cc88ef",
    "#37661e",
    "#ea88e2",
    "#596d18",
    "#af6bcc",
    "#b19c31",
    "#af95f6",
    "#d19d37",
    "#7565b4",
    "#7b9b47",
    "#b85ab2",
    "#6cba7d",
    "#b61e5c",
    "#4cbe9e",
    "#ad2716",
    "#6ed7d8",
    "#c12f39",
    "#38b4be",
    "#f35656",
    "#298e5f",
    "#e15890",
    "#b8d88d",
    "#8d2973",
    "#95bc75",
    "#763174",
    "#dec775",
    "#334a84",
    "#eb8d4a",
    "#367bbb",
    "#f56d4a",
    "#68c3ef",
    "#d85537",
    "#41a7c5",
    "#ab4c0e",
    "#89cce7",
    "#c62f4d",
    "#379e93",
    "#e45a75",
    "#93d8bf",
    "#941b38",
    "#96d4d4",
    "#912320",
    "#a2bcf2",
    "#d97236",
    "#15729c",
    "#e77852",
    "#154975",
    "#f0b66e",
    "#a181d7",
    "#7e7318",
    "#e89ff0",
    "#415a1f",
    "#ea80ca",
    "#326034",
    "#ce5da7",
    "#769e5d",
    "#bd4383",
    "#569160",
    "#932764",
    "#afb46a",
    "#8c559d",
    "#938b34",
    "#8f8dd9",
    "#b08028",
    "#5d4480",
    "#ce883c",
    "#3585b0",
    "#a23e1d",
    "#5e9abd",
    "#87370d",
    "#939cdc",
    "#9d621e",
    "#c2aff0",
    "#616117",
    "#e7b1f1",
    "#4c501a",
    "#e89ddb",
    "#618042",
    "#b66eb7",
    "#b49c55",
    "#b386cd",
    "#64531b",
    "#cc7fc4",
    "#326b50",
    "#ee76aa",
    "#2e543c",
    "#ef7971",
    "#145a6a",
    "#e98e5d",
    "#3b5b8b",
    "#b75f30",
    "#6777b3",
    "#cd9659",
    "#7f6daa",
    "#c3d09f",
    "#972554",
    "#7cb89b",
    "#ba3f4c",
    "#448e99",
    "#c95449",
    "#34758f",
    "#a84535",
    "#b1c8eb",
    "#7a4618",
    "#dec6f1",
    "#6b6e37",
    "#94548c",
    "#93ac80",
    "#b94365",
    "#588f74",
    "#a14e7c",
    "#607f54",
    "#df90bb",
    "#20554c",
    "#ed93ac",
    "#35776f",
    "#bc5857",
    "#75afaa",
    "#92353d",
    "#7090bb",
    "#863c2c",
    "#9ea2c8",
    "#8a632f",
    "#bfa0d0",
    "#806d35",
    "#ab7fb1",
    "#9a7d42",
    "#54739a",
    "#ee9f81",
    "#485172",
    "#e3c18f",
    "#79345d",
    "#ddc7a5",
    "#66426a",
    "#8d9260",
    "#bd739c",
    "#504e2d",
    "#dfacce",
    "#724b31",
    "#f0b8c3",
    "#7e3443",
    "#b79c6e",
    "#93577c",
    "#6e6c49",
    "#ba6882",
    "#e0ae95",
    "#777399",
    "#c27c54",
    "#886587",
    "#a25f48",
    "#bc899c",
    "#a38366",
    "#92465f",
    "#da9896",
    "#7d4f55",
    "#d27a78",
    "#af796f",
    "#b25e68"
  )
  p = ggplot(data = clusters, mapping = aes(x = X, y = Y, color = as.factor(treeID))) + geom_point() + theme_bw() + scale_colour_manual(values = cbf240) 
  p
}

# Read in cluster features for model training:
LF = as.data.table(read_feather("cluster_features_with_label.feather"))
LF[,Cluster_ID := NULL]
setnames(LF, "in_situ_AGB_summed_by_cluster", "Label")

#Remove any rows where label == NA
LF = LF[!is.na(Label),]

#Train RF:
RF = trainRF(LF)

#Extract features from point cloud:
F = extractFeatures(clusters)
# Remove Cluster_ID
F[,Cluster_ID := NULL]


modelPredictions = runModel(RF, F)

# Sum biomass of all clusters to get estimate of total study area biomass:
print("Summed biomass of all clusters to get estimate of total study area biomass:")
totalBiomass = sum(modelPredictions)
totalBiomass

# Study area is: covered 7913.35 square meters (or .791335 hectares)
area = .791335
biomassDensity = totalBiomass/area
print("Estimated biomass density of study area from 2011 aerial lidar (kg/ha):")
biomassDensity
# 21995.74 kg/hectare

areaSqM = 7913.35
biomassDensity = totalBiomass/areaSqM
print("Estimated biomass density of study area from 2011 aerial lidar (kg/sq. meter):")
biomassDensity
# 2.199574


#