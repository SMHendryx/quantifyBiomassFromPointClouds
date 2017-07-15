# Trains a real-valued prediction model

library(feather)
library(lidR)
library(data.table)
library(randomForest)
library(ggplot2)

#getdata:
setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/OPTICS_Param_Tests/study-area")
#DT of features:
DT = as.data.table(read_feather("cluster_features.feather"))
# Tree column is the cluster label (points$cluster_ID)

numColsToSave = ncol(DT) - 29
cols = names(DT)[1:numColsToSave]
DT = DT[,.SD, .SDcols = cols]

# read in points (labeled data):
points = as.data.table(read_feather("in_situ_biomass_points_with_cluster_assignments.feather"))

#First, connect labels and features:
LF = merge(DT, points, by.x = "Tree", by.y = "cluster_ID")

#plotting correspondences:
# compute CrownMetrics() Mean_Axis:
LF[,CrownMetrics_Mean_Axis := ((EWIDTH + NWIDTH)/2)]

p = ggplot(data = LF, mapping = aes(x = Mean_Axis,y = CrownMetrics_Mean_Axis)) + geom_point() + theme_bw() + geom_smooth(method = "lm", se = FALSE)
p = p + labs(x = "In Situ Mean Tree Axis", y = "Point Cloud Cluster Mean Axis")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
m = lm(LF$CrownMetrics_Mean_Axis ~ LF$Mean_Axis)
r = format(summary(m)$r.squared ^ .5, digits = 3)
text = paste0("r = ", r)
p = p + annotate("text",x = 1, y = 19, label = text)
p = p + geom_abline(color = "red")
p


p = ggplot(data = LF[, mapping = aes(x = Mean_Axis,y = CrownMetrics_Mean_Axis)) + geom_point() + theme_bw() + geom_smooth(method = "lm", se = FALSE)
p = p + labs(x = "In Situ Mean Tree Axis", y = "Point Cloud Cluster Mean Axis")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
m = lm(LF$CrownMetrics_Mean_Axis ~ LF$Mean_Axis)
r = format(summary(m)$r.squared ^ .5, digits = 3)
text = paste0("r = ", r)
p = p + annotate("text",x = 1, y = 19, label = text)
p = p + geom_abline(color = "red")
p
