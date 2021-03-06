# Computes the biomass of individual trees using deterministic allometric equations

library(feather)
library(lidR)
library(data.table)
library(ggplot2)
source("~/githublocal/quantifyBiomassFromPointClouds/quantifyBiomassFromPointClouds/R/allometricEqns.R")



argsControl = TRUE

if(argsControl){
  args = commandArgs(trailingOnly = TRUE)
  #args: 1. directory in which to write (and from which to read if second argument is not specified), 2. input file
  #args should be (complete paths with '/' after directories) 

  # test if there is at least one argument: if not, return an error
  if (length(args) < 1) {
    stop("At least one argument must be supplied: working directory including .feather file of points.", call.=FALSE)
  } else if (length(args)== 1) {
    args[2] = "in_situ_points_with_cluster_assignments.feather"
  }
  direc = args[1]
  inFile = args[2]
}


#getdata:
setwd(direc)

# read in points (labeled data):
points = as.data.table(read_feather(inFile))

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
