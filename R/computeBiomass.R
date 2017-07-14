# Trains a real-valued prediction model

library(feather)
library(lidR)
library(data.table)
library(randomForest)
library(ggplot2)
source("~/githublocal/quantifyBiomassFromPointClouds/R/allometricEqns.R")


#getdata:
setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/OPTICS_Param_Tests/study-area")

# read in points (labeled data):
points = as.data.table(read.csv("in_situ_points_with_cluster_assignments.csv"))

#compute mean axis:
points[,Mean_Axis := ((Major_Axis + Minor_Axis)/2)]

#compute Canopy Area:
circArea = function(r){return(pi * (r^2))}
# divide Mean_Axis by two to get radius:
points[,Canopy_Area := circArea(Mean_Axis/2)]

# compute biomass (Above Ground Biomass (AGB)):
points[Species == "pv", AGB := mesqAllom(Canopy_Area)]
points[Species == "cp", AGB := hackAllom(Canopy_Area)]
points[Species == "it", AGB := burrAllom(Canopy_Area)]

write.csv(points, "in_situ_biomass_points_with_cluster_assignments.csv")
write_feather(points, "in_situ_biomass_points_with_cluster_assignments.feather")
