# Pipeline to quantify biomass from point clouds
# First argument should be input point cloud, second argument should be training data
# Script should be run in a directory within which processed files and directories will be created.
# File paths currently hardcoded inside scripts


cd R

# First, clip point cloud to study area if necessary:
Rscript clipPointCloudsToStudyArea.R /Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering MILDDEPTHFILTERINGOptimized_GeoreferencedWithUpdatealtizureImages.las 

#(I am here)
#decimate the point cloud if very dense: (what is "very dense"?)
#Rscript decimate_PointClouds.R /Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area Rectangular_MILDDEPTHFILTERINGOptimized_GeoreferencedWithUpdatealtizureImages.las
#only 256k points so let's try w/o decimation

#Plus, it's already ground classed

#Rscript removeGroundPoints.R 

# Then tile the point cloud: 
Rscript run_tileR.R /Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/tiles/ /Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/groundPointsRemoved_Rectangular_MILDDEPTHFILTERINGOptimized_GeoreferencedWithUpdatealtizureImages.las

# Classify ground points: 
# manually move files to cyberduck, then:
./move_tiles_to_Jetstream_from_Cyberduck.sh
./run_MCC_Lidar_on_Jetstream.sh
# if mcc lidar doesn't run, classify ground points with PMF in lidR:
#Script runs PMF on those files not run MCC-Lidar
#args should be 1. working directory, 2. inDirec: directory containing files that were input to the process, and 3. outDirec: directory containing files that were output by the process
Rscript PMF.R /Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/PMF/tiles/ /Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/tiles/ /Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/mcc-s_point20_-t_point05/tiles/
#move tiles from PMF and MCC into same directory:
cd /Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/
mkdir all_tiles
cp PMF/tiles/*.las all_tiles
cp mcc-s_point20_-t_point05/tiles/*.las all_tiles

# Merge now-classified tiles back together:
#args should be (complete paths) 1. directory containing las files to be merged, 2. original las file from which to pull las header 3. whether or not to plot
Rscript mergeTiles.R /Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/all_tiles/ /Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/belowGroundPointsRemoved_Rectangular_MILDDEPTHFILTERINGOptimized_GeoreferencedWithUpdatealtizureImages.las TRUE
Rscript mergeTiles.R /Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/PMF/tiles/ /Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/belowGroundPointsRemoved_Rectangular_MILDDEPTHFILTERINGOptimized_GeoreferencedWithUpdatealtizureImages.las TRUE

# Get nonground points 1m or greater height above ground: 
Rscript extractNonGroundPoints.R

# Cluster points, via watershed, OPTICS, etc.:
# use OPTICS to identify outliers:
python run_OPTICS.py
Rscript remove_OPTICS_outliers.R 

# then run watershed on point cloud that doesn't have outliers:
Rscript watershedSegmentTrees_afterOPTICSOutliersRemoved.R

# set up training and validation data:  # Need to rerun SfM from here:
Rscript run_assignPointsToClusters_on_watershedSegmentedTrees.R

# Compute biomass of in situ data:
Rscript computeBiomassOfIndividualTrees.R /Users/seanmhendryx/Data/thesis/Processed_Data/T-lidar/rerunWatershed/output_20171101 in_situ_points_with_cluster_assignments_buffer_10.feather

# Extract Features: 
extractFeatures.R
# Graph correspondences between cluster features and labels
correspondWatershedClusters

# Train & validate model (report error statistics: MAE and, for best model, RMSE): 
crossValidateModel.R

# Run model to produce fine-scale, biomass-density raster:
Rscript predictBiomassOfArea.R
