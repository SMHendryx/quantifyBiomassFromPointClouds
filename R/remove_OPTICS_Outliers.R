#Script removes outliers

library(feather)
library(lidR)
library(data.table)
library(ggplot2)
library(plotly)

#getdata:
setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/rectangular_study_area/classified/watershed_after_remove_OPTICS_outliers")

clusters = as.data.table(read_feather("OPTICS_clustered_points_eps_8.3_min_samples_150.feather"))

#remove outlier rows:
clusters = clusters[Label != -1,]

# remove Label columns
clusters[, Label := NULL]

write_feather(clusters, "OPTICS_outliers_removed_points_eps_8.3_min_samples_150.feather")
