# Code to make plots to investigate differing methods of quantifying biomass.

library(feather)
library(lidR)
library(data.table)
library(ggplot2)
library(plotly)


# To compute RMSE, first get errors:
getErrors = function(measured, predicted){
  return(measured - predicted)
}

#Define functions:
rmse = function(errors){
  return(sqrt(mean(errors^2)))
}

mae = function(errors){
	return(mean(abs(errors),na.rm = TRUE))
}

#getdata:
setwd("/Users/seanhendryx/DATA/Lidar/SRER/AZ_Tucson_2011_000564/rectangular_study_area/watershed_after_remove_OPTICS_outliers/buffer3/")
#setwd("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/OPTICS_Param_Tests/study-area")
#DT of features:
DT = as.data.table(read_feather("cluster_features_with_label.feather"))
# Tree column is the cluster label (points$cluster_ID)
# Convert it to cluster_ID:
#setnames(DT, "Tree", "Cluster_ID")
# ^ should already have been done in extractFeatures.R.  "Tree" is the output column from watershed segmentation in lidR


# read in points (labeled data):
points = as.data.table(read_feather("in_situ_biomass_points_with_cluster_assignments.feather"))

#These next three lines of code should be moved to extractFeatures.R:
#First, connect labels and features:
LF = merge(DT, points, by.x = "Cluster_ID", by.y = "cluster_ID")
#remove points outside of threshold:
LF = LF[closest_cluster_outside_threshold == FALSE]
#Sum in situ mass by cluster (i.e. "Cluster_ID" column)
LF[,in_situ_AGB_summed_by_cluster := sum(AGB), by = Cluster_ID]

#compute RS PC estimated biomass based off clustering:
source("~/githublocal/quantifyBiomassFromPointClouds/R/allometricEqns.R")

#compute PC cluster mean axis:
LF[,Cluster_Mean_Axis := ((EWIDTH + NWIDTH)/2)]

#compute Canopy Area:
circArea = function(r){return(pi * (r^2))}
# divide Mean_Axis by two to get radius:
LF[,Cluster_CA := circArea(Cluster_Mean_Axis/2)]

#get species distributions for training ecosystem allometric eqn:
npv = nrow(LF[Species == "pv"])
ncp = nrow(LF[Species == "cp"])
totaln = npv + ncp
ppv = npv/totaln
#0.8271605
pcp = ncp/totaln
# 0.1728395

#Get CA statistics:
max(LF[Species == "pv",Canopy_Area])
max(LF[Species == "cp",Canopy_Area])

#Plot distribution of true canopy areas:
distrDT = LF[,.(Canopy_Area, Species)]
density = ggplot(data = distrDT, mapping = aes(x = Canopy_Area)) + geom_density(aes(fill = Species), alpha = .75) + theme_bw()
# When generating data, respect distribution around Canopy Area sizes?
# - NO, we are trying to model the relationship between Mass ~ CA, not Mass ~ CA + size pattern

#I am here:  Edit this, AGB of cluster should be computed using ecosystem allometry eqn:


# compute estimated biomass (Above Ground Biomass (AGB)) from cluster measurements:
LF[Species == "pv", cluster_measurements_AGB := mesqAllom(Cluster_CA)]
LF[Species == "cp", cluster_measurements_AGB := hackAllom(Cluster_CA)]
LF[Species == "it", cluster_measurements_AGB := burrAllom(Cluster_CA)]

#if we assume all clusters are mesquite:
LF[,assume_mesq_AGB_cluster_measurements := mesqAllom(Cluster_CA)]
#vs if we assume all clusters are hackberry:
LF[,assume_hack_AGB_cluster_measurements := hackAllom(Cluster_CA)]
#vs ecosystem-state allometric equation computed using cross-validation and data generated from the measured species distribution
LF[,ecoAllom_AGB_cluster_measurements := ecoAllom(Cluster_CA)]





LF = LF[!is.na(in_situ_AGB_summed_by_cluster)]



#PLOTTING
#make plot of differing assumed species:
assumeSpecDT = LF[,.(assume_mesq_AGB_cluster_measurements, assume_hack_AGB_cluster_measurements, ecoAllom_AGB_cluster_measurements, Cluster_CA)]
melted = melt(assumeSpecDT, measure.vars = c("assume_mesq_AGB_cluster_measurements", "assume_hack_AGB_cluster_measurements", "ecoAllom_AGB_cluster_measurements"), value.name = "Estimated_AGB")
pSpec = ggplot(data = melted, mapping = aes(x = Cluster_CA,Estimated_AGB)) + geom_point(mapping = aes(color = variable)) + theme_bw() + labs(x = expression(paste("Cluster Canopy Area (", {m^2}, ")")), y = "Estimated AGB (kg)", color = "Allometric Equation") + scale_color_hue(labels = c("Prosopis Velutina", "Celtis Pallida", "Ecosystem State Allometry"))


#make plots of differing assumed species:
pHack = ggplot(data = LF[closest_cluster_outside_threshold==FALSE,], mapping = aes(x = Cluster_CA, y= assume_hack_AGB_cluster_measurements)) + geom_point() + theme_bw()
pMesq = ggplot(data = LF[closest_cluster_outside_threshold==FALSE,], mapping = aes(x = Cluster_CA, y= assume_mesq_AGB_cluster_measurements)) + geom_point() + theme_bw()
pHack
dev.new()
pMesq

histDT = LF[,.(assume_hack_AGB_cluster_measurements, assume_mesq_AGB_cluster_measurements, Cluster_CA)]
melted = melt(histDT, measure.vars = c("assume_hack_AGB_cluster_measurements", "assume_mesq_AGB_cluster_measurements"), value.name = "AGB")

#both point series:
p = ggplot(data = melted, aes(x = Cluster_CA, y = AGB, color = variable)) + geom_point() + theme_bw()+ labs(x = expression(paste("Canopy Area of Cluster (", m^{2},")")), y = "AGB Estimated from Cluster Dimensions (kg)", color = "Allometric Equation") + scale_color_manual(labels = c("Hackberry", "Mesquite"), values = c("blue", "red"))
#box plot of same data:
boxplot <- ggplot(data = melted, aes(x = factor(variable), AGB)) + geom_boxplot() + theme_bw() + labs(x = "Assumed Species", y = "Above Ground Biomass (kg)")
boxplot

density = ggplot(data = melted, mapping = aes(x = AGB)) + geom_density(aes(fill = variable)) + theme_bw()

#both 

#plotting correspondence of insitu and RS-estimated mass:

LF[,Cluster_ID := as.factor(Cluster_ID)]

# without assigning points to clusters, this is what you get:
# when we don't specify the species of the allometric equation
#first compute RMSE:
errors = getErrors(LF$cluster_measurements_AGB, LF$AGB)
MAE = mae(errors)
p = ggplot(data = LF, mapping = aes(x = AGB,y = cluster_measurements_AGB)) + geom_point(size = 2) + theme_bw() + geom_smooth(method = "lm", se = FALSE) + guides(color=FALSE) #guides(fill=FALSE) removes legend
p = p + labs(x = "In Situ AGB of Individual Trees(kg)", y = "AGB Estimated from Cluster Dimensions (kg)")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
m = lm(LF[,cluster_measurements_AGB] ~ LF[closest_cluster_outside_threshold==FALSE ,AGB])
#r2 = format(summary(m)$r.squared, digits = 3)
#text = paste("r^2 == ", r2)
text = paste("MAE == ", MAE)
p = p + annotate("text",x = 450, y = 250, label = text, parse = TRUE)
p = p + geom_abline(color = "red")

#specifying mesquite allometric eqn:
p = ggplot(data = LF, mapping = aes(x = AGB,y = assume_mesq_AGB_cluster_measurements)) + geom_point(size = 2) + theme_bw() + geom_smooth(method = "lm", se = FALSE) + guides(color=FALSE) #guides(fill=FALSE) removes legend
p = p + labs(x = "In Situ AGB of Individual Trees(kg)", y = "AGB Estimated from Cluster Dimensions Assuming Mesquite Allometry (kg)")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
m = lm(LF[,assume_mesq_AGB_cluster_measurements] ~ LF[,AGB])
r2 = format(summary(m)$r.squared, digits = 3)
text = paste("r^2=", r2)
p = p + annotate("text",x = 275, y = 200, label = text, parse = TRUE)
p = p + geom_abline(color = "red")


# and now plotting summed in situ mass by cluster, coloring by species to show the variance in prediction:
errors = getErrors(LF$cluster_measurements_AGB, LF$in_situ_AGB_summed_by_cluster)
MAE = mae(errors)
p = ggplot(data = LF, mapping = aes(x = in_situ_AGB_summed_by_cluster,y = cluster_measurements_AGB)) + geom_point(mapping = aes(color = Species), size = 2) + theme_bw() + geom_smooth(method = "lm", se = FALSE)# + guides(color=FALSE) #guides(fill=FALSE) removes legend
p = p + labs(x = "In Situ AGB of Cluster (kg)", y = "AGB Estimated from Cluster Dimensions (kg)")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
m = lm(LF[,cluster_measurements_AGB] ~ LF[closest_cluster_outside_threshold==FALSE ,in_situ_AGB_summed_by_cluster])
#r2 = format(summary(m)$r.squared, digits = 3)
#text = paste("r^2 == ", r2)
text = paste("MAE == ", MAE)
p = p + annotate("text",x = 370, y = 300, label = text, parse = TRUE)
p = p + geom_abline(color = "red")



# and now plotting summed in situ mass by cluster:
errors = getErrors(LF$cluster_measurements_AGB, LF$AGB)
RMSE = rmse(errors)
p = ggplot(data = LF, mapping = aes(x = in_situ_AGB_summed_by_cluster,y = cluster_measurements_AGB)) + geom_point(mapping = aes(color = Cluster_ID), size = 2) + theme_bw() + geom_smooth(method = "lm", se = FALSE) + guides(color=FALSE) #guides(fill=FALSE) removes legend
p = p + labs(x = "In Situ AGB of Cluster (kg)", y = "AGB Estimated from Cluster Dimensions (kg)")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
m = lm(LF[,cluster_measurements_AGB] ~ LF[closest_cluster_outside_threshold==FALSE ,in_situ_AGB_summed_by_cluster])
#r2 = format(summary(m)$r.squared, digits = 3)
#text = paste("r^2 == ", r2)
text = paste("RMSE == ", RMSE)
p = p + annotate("text",x = 300, y = 3500, label = text)
p = p + geom_abline(color = "red")



# and now assuming all clusters are mesquite:
errors = getErrors(LF$assume_mesq_AGB_cluster_measurements, LF$in_situ_AGB_summed_by_cluster)
RMSE = rmse(errors)
p = ggplot(data = LF, mapping = aes(x = in_situ_AGB_summed_by_cluster,y = assume_mesq_AGB_cluster_measurements)) + geom_point(mapping = aes(color = Cluster_ID), size = 2) + theme_bw() + geom_smooth(method = "lm", se = FALSE) + guides(color=FALSE) #guides(fill=FALSE) removes legend
p = p + labs(x = "In Situ AGB of Cluster (kg)", y = "AGB Estimated from Cluster Dimensions Assuming Mesquite Allometry (kg)")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
#m = lm(LF[,assume_mesq_AGB_cluster_measurements] ~ LF[,in_situ_AGB_summed_by_cluster])
#r2 = format(summary(m)$r.squared, digits = 3)
#text = paste("r^2 == ", r2)
text = paste("RMSE == ", RMSE)
p = p + annotate("text",x = 300, y = 3500, label = text, parse = TRUE)
p = p + geom_abline(color = "red")

ply = ggplotly(p)
ply

#Same as last with no point colors
# and now plotting summed in situ mass by cluster:
#ANNOTATE WITH MAE INSTEAD OF RMSE
errors = getErrors(LF$assume_mesq_AGB_cluster_measurements, LF$in_situ_AGB_summed_by_cluster)
MAE = mae(errors)
p = ggplot(data = LF, mapping = aes(x = in_situ_AGB_summed_by_cluster,y = assume_mesq_AGB_cluster_measurements)) + geom_point(size = 2) + theme_bw() + geom_smooth(method = "lm", se = FALSE) + guides(color=FALSE) #guides(fill=FALSE) removes legend
p = p + labs(x = "AGB Estimate of Cluster from In Situ Tree Measurements (kg)", y = "AGB Estimate from Cluster Dimensions & Mesquite Allometry (kg)")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
#m = lm(LF[,assume_mesq_AGB_cluster_measurements] ~ LF[,in_situ_AGB_summed_by_cluster])
#r2 = format(summary(m)$r.squared, digits = 3)
#text = paste("r^2 == ", r2)
text = paste("MAE == ", MAE)
p = p + annotate("text",x = 100, y = 300, label = text, parse = TRUE)
p = p + geom_abline(color = "red")# + coord_equal()
p = p + theme(axis.text=element_text(size=9), axis.title=element_text(size=12))

# Now using ecosystem allometry:
errors = getErrors(LF$ecoAllom_AGB_cluster_measurements, LF$in_situ_AGB_summed_by_cluster)
MAE = mae(errors)
p = ggplot(data = LF, mapping = aes(x = in_situ_AGB_summed_by_cluster,y = ecoAllom_AGB_cluster_measurements)) + geom_point(size = 2) + theme_bw() + geom_smooth(method = "lm", se = FALSE) + guides(color=FALSE) #guides(fill=FALSE) removes legend
p = p + labs(x = "In Situ AGB of Cluster (kg)", y = "AGB Estimated from Cluster Dimensions & Ecosystem-State Allometry (kg)")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
#m = lm(LF[,ecoAllom_AGB_cluster_measurements] ~ LF[,in_situ_AGB_summed_by_cluster])
#r2 = format(summary(m)$r.squared, digits = 3)
#text = paste("r^2 == ", r2)
text = paste("MAE == ", MAE)
p = p + annotate("text",x = 350, y = 250, label = text, parse = TRUE)
p = p + geom_abline(color = "red")

ply = ggplotly(p)
ply

# Same as last but with colored points. using ecosystem allometry:
RMSE = rmse(errors)
p = ggplot(data = LF, mapping = aes(x = in_situ_AGB_summed_by_cluster,y = ecoAllom_AGB_cluster_measurements)) + geom_point(mapping = aes(color = Cluster_ID),size = 2) + theme_bw() + geom_smooth(method = "lm", se = FALSE) + guides(color=FALSE) #guides(fill=FALSE) removes legend
p = p + labs(x = "In Situ AGB of Cluster (kg)", y = "AGB Estimated from Cluster Dimensions & Ecosystem-State Allometry (kg)")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
#m = lm(LF[,ecoAllom_AGB_cluster_measurements] ~ LF[,in_situ_AGB_summed_by_cluster])
#r2 = format(summary(m)$r.squared, digits = 3)
#text = paste("r^2 == ", r2)
text = paste("RMSE == ", RMSE)
p = p + annotate("text",x = 300, y = 3500, label = text, parse = TRUE)
p = p + geom_abline(color = "red")

ply = ggplotly(p)
ply






p = ggplot(data = LF[closest_cluster_outside_threshold==FALSE,], mapping = aes(x = in_situ_AGB_summed_by_cluster,y = cluster_measurements_AGB)) + geom_point( size = 2) + theme_bw() + geom_smooth(method = "lm", se = FALSE) + guides(color=FALSE) #guides(fill=FALSE) removes legend
p = p + labs(x = "In Situ AGB of Cluster (kg)", y = "AGB Estimated from Cluster Dimensions (kg)")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
m = lm(LF[closest_cluster_outside_threshold==FALSE,cluster_measurements_AGB] ~ LF[closest_cluster_outside_threshold==FALSE ,in_situ_AGB_summed_by_cluster])
r = format(summary(m)$r.squared ^ .5, digits = 3)
text = paste0("r = ", r)
p = p + annotate("text",x = 300, y = 2500, label = text)
p = p + geom_abline(color = "red")


p = ggplot(data = LF[closest_cluster_outside_threshold==FALSE,], mapping = aes(x = in_situ_AGB_summed_by_cluster,y = cluster_measurements_AGB)) + geom_point() + theme_bw() + geom_smooth(method = "lm", se = FALSE) + guides(color=FALSE) #guides(fill=FALSE) removes legend
p = p + labs(x = "In Situ AGB of Cluster (kg)", y = "AGB Estimated from Cluster Dimensions (kg)")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
m = lm(LF[closest_cluster_outside_threshold==FALSE,cluster_measurements_AGB] ~ LF[closest_cluster_outside_threshold==FALSE ,in_situ_AGB_summed_by_cluster])
r = format(summary(m)$r.squared ^ .5, digits = 3)
text = paste0("r = ", r)
p = p + annotate("text",x = 75, y = 450, label = text)
p = p + geom_abline(color = "red")




p = ggplot(data = LF[closest_cluster_outside_threshold==FALSE,], mapping = aes(x = Mean_Axis,y = Cluster_Mean_Axis)) + geom_point(mapping = aes(color = Sample_ID)) + theme_bw() + geom_smooth(method = "lm", se = FALSE)
p = p + labs(x = "In Situ Mean Tree Axis", y = "Point Cloud Cluster Mean Axis")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
m = lm(LF[closest_cluster_outside_threshold==FALSE,Cluster_Mean_Axis] ~ LF[closest_cluster_outside_threshold==FALSE ,Mean_Axis])
r = format(summary(m)$r.squared ^ .5, digits = 3)
text = paste0("r = ", r)
p = p + annotate("text",x = 1, y = 19, label = text)
p = p + geom_abline(color = "red")

ply = ggplotly(p)
ply


cluster757 = ggplot(data = LF[closest_cluster_outside_threshold==FALSE & Cluster_ID == 757,], mapping = aes(x = Mean_Axis,y = Cluster_Mean_Axis)) + geom_point(mapping = aes(color = Sample_ID)) + theme_bw() + geom_smooth(method = "lm", se = FALSE)
cluster757= cluster757+ labs(x = "In Situ Mean Tree Axis", y = "Point Cloud Cluster Mean Axis")# + ggtitle("Feature Family Subset Classification Performance")
cluster757= cluster757+ theme(plot.title = element_text(hjust = 0.5))
m = lm(LF[closest_cluster_outside_threshold==FALSE & Cluster_ID == 757,Cluster_Mean_Axis] ~ LF[closest_cluster_outside_threshold==FALSE & Cluster_ID == 757,Mean_Axis])
r = format(summary(m)$r.squared ^ .5, digits = 3)
text = paste0("r = ", r)
#cluster757= cluster757+ annotate("text",x = 1, y = 19, label = text)
cluster757= cluster757+ geom_abline(color = "red")
ply = ggplotly(cluster757)


p = ggplot(data = LF[, mapping = aes(x = Mean_Axis,y = Cluster_Mean_Axis)) + geom_point() + theme_bw() + geom_smooth(method = "lm", se = FALSE)
p = p + labs(x = "In Situ Mean Tree Axis", y = "Point Cloud Cluster Mean Axis")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(plot.title = element_text(hjust = 0.5))
m = lm(LF$Cluster_Mean_Axis ~ LF$Mean_Axis)
r = format(summary(m)$r.squared ^ .5, digits = 3)
text = paste0("r = ", r)
p = p + annotate("text",x = 1, y = 19, label = text)
p = p + geom_abline(color = "red")
p
