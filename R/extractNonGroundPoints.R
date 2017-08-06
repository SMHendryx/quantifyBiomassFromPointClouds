# Script gets all poins 1m or greater Height Above Ground and writes to feather file.
# 
# Created by Sean Hendryx
# seanmhendryx@email.arizona.edu https://github.com/SMHendryx/assignPointsToClusters
# Copyright (c)  2017 Sean Hendryx
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
####################################################################################################################################################################################
# Clear workspace:
rm(list=ls())

library(lidR)
library(ggplot2)
library(feather)


argsControl = FALSE

if(argsControl){
  args = commandArgs(trailingOnly = TRUE)
  #args should be (complete paths with '/' after directories) 1. file from which to extract nonground points, 2. directory in which to write output point cloud files, 3. whether or not to plot (default is FALSE) 4. whether or not to write (default is TRUE)

  # test if there is at least one argument: if not, return an error
  if (length(args)== 1) {
    stop("At least two arguments must be supplied: 1. file from which to extract nonground points and 2. directory in which to write output point cloud files. ", call.=FALSE)
  } else if (length(args)==2) {
    args[3] = FALSE
    args[4] = TRUE
  } else if(length(args ==3)){
    args[4] = TRUE
  }
  
  inFile = args[1]
  outDirec = args[2]
  plotControl = args[3]
  writeControl = args[4]
}

inFile = "/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/mcc-s_point20_-t_point05/Merged_Ground_Classified.las"
outDirec = "/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/mcc-s_point20_-t_point05/"
plotControl = TRUE
writeControl = FALSE

setwd(outDirec)
#Read in las file:
las = readLAS(inFile)

dtm = grid_terrain(las, res = .1, method = "knnidw")
plot(dtm, main="SRER Mesquite Tower SfM DTM")
quartz.save("/Users/seanhendryx/Google Drive/THE UNIVERSITY OF ARIZONA (UA)/THESIS/Graphs/SfM/Ground Delineation/SRER Mesquite Tower SfM DTM.png")
dev.off()

lasnorm = lasnormalize(las, dtm)
writeLAS(lasnorm, "SfM_study-area_HAG-Normalized.las")
#plot(lasnorm)

#remove classified ground points:
#lasfilter returns points with matching conditions.
nonground = lasnorm %>% lasfilter(Classification == 1 & Z >= 1.0)
plot(nonground)

# Create GreaterThan1mHAG direc if doesn't exist:
dir.create(file.path(outDirec, "GreaterThan1mHAG"))
writeLAS(nonground, "GreaterThan1mHAG/SfM_nonground_points.las")

# Get csv
ngPoints = nonground@data
write.csv(ngPoints, "GreaterThan1mHAG/SfM_nonground_points.csv")
write_feather(ngPoints, "GreaterThan1mHAG/SfM_nonground_points.feather")


