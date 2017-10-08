#Script removes outliers

library(feather)
library(lidR)
library(data.table)
library(ggplot2)
library(plotly)


#getdata:
setwd("/Users/seanhendryx/DATA/Lidar/SRER/AZ_Tucson_2011_000564/rectangular_study_area/GreaterThan1mHAG")

clusters = as.data.table(read_feather("OPTICS_clustered_points_eps_8.3_min_samples_15.feather"))

#remove outlier rows:
clusters = clusters[Label != -1,]

# remove Label columns
clusters[, Label := NULL]

write_feather(clusters, "OPTICS_outliers_removed_points_eps_8.3_min_samples_15.feather")
