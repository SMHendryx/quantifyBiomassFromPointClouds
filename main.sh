# Pipeline to quantify biomass from point clouds
# First argument should be input point cloud, second argument should be training data
# Script should be run in a directory within which processed files and directories will be created.
# File paths currently hardcoded inside scripts


# First, decimate the point cloud if very dense:
Rscript decimate_PointClouds.R

# Then tile the point cloud:
Rscript run_tileR.R

# Classify ground points:
./run_MCC_Lidar.sh
# if mcc lidar doesn't run, classify ground points with PMF in lidR:
#Here: write bash script to cp all original tiles that were not MCC-Lidared into new directory called "notSuccessfullyGroundClassifedByMCC"

# Merge now-classified tiles back together:
mergeTiles.R

# Cluster points, via watershed, OPTICS, etc.:
# use OPTICS to identify outliers:
run_OPTICS.R
remove_OPTICS_outliers.R
# then run watershed on point cloud that doesn't have outliers:
watershedSegmentTrees.R

# set up training and validation data:
Rscript assignPointsToClusters.R
Rscript extractFeatures.R

# Train & validate model (report error statistics: RMSE):
Rscript crossValModel.R

# Run model to produce fine-scale, biomass-density raster:
Rscript runModel.R
