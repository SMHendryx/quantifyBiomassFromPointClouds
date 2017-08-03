# Pipeline to quantify biomass from point clouds
# First argument should be input point cloud, second argument should be training data
# Script should be run in a directory within which processed files and directories will be created.
# File paths currently hardcoded inside scripts


# First, clip point cloud to study area if necessary:
Rscript clipPointCloudsToStudyArea.R /Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering MILDDEPTHFILTERINGOptimized_GeoreferencedWithUpdatealtizureImages.las 

#decimate the point cloud if very dense:
Rscript decimate_PointClouds.R /Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area Rectangular_MILDDEPTHFILTERINGOptimized_GeoreferencedWithUpdatealtizureImages.las

# Then tile the point cloud: (I am here)
Rscript run_tileR.R /Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/tiles /Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/Decimated_Rectangular_MILDDEPTHFILTERINGOptimized_GeoreferencedWithUpdatealtizureImages.las

# Classify ground points:
./run_MCC_Lidar.sh
# if mcc lidar doesn't run, classify ground points with PMF in lidR:
#Here: write bash script to cp all original tiles that were not MCC-Lidared into new directory called "notSuccessfullyGroundClassifedByMCC"

# Merge now-classified tiles back together:
Rscript mergeTiles.R

# Cluster points, via watershed, OPTICS, etc.:
# use OPTICS to identify outliers:
Rscript run_OPTICS.R
Rscript remove_OPTICS_outliers.R
# then run watershed on point cloud that doesn't have outliers:
Rscript watershedSegmentTrees.R

# set up training and validation data:
Rscript assignPointsToClusters.R

# Compute biomass of in situ data:
Rscript computeBiomass.R

# Extract Features:
Rscript extractFeatures.R
#Connect cluster features and biomass:
Rscript correspondWatershedClusters

# Train & validate model (report error statistics: RMSE):
Rscript crossValModel.R

# Run model to produce fine-scale, biomass-density raster:
Rscript runModel.R
