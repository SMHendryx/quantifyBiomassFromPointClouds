# Algorithms for assigning points in one dataset to clusters in another dataset, flagging unlikely correspondences based on a distance threshold, 
# and "merging" clusters that have been over-segmented by the clustering algorithm.
# Ideally, if we have a dataset of points, where each point represents a cluster in another data set, there would be a one-to-one 
# correspondence between the two data sets, such that for each point there is one and only one cluster to which it corresponds and
# such that it is unmistakable which point corresponds to which cluster.  
# Though, this is not usually the case.  These algorithms present one approach to resolving the differences in representation. 
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

#time it:
startTime = Sys.time()

#load packages:
library(data.table)
library(ggplot2)
library(feather)
library(lidR)
source("/Users/seanhendryx/githublocal/quantifyBiomassFromPointClouds/R/assignPointsToClusters.R")


#Run
outDirec = "/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/mcc-s_point20_-t_point05"
setwd(outDirec)

# read in clustered point cloud:
clusters = as.data.table(read_feather("SfM_allTilesGroundClassified_and_Clustered_By_Watershed_Segmentation.feather"))
# add column named "Label", since that is what assignPointsToClusters is looking for:
clusters[,Label := treeID]

# read in points:
points = as.data.table(read.csv("/Users/seanhendryx/DATA/SRERInSituData/SRER_Mesq_Tower_In_Situ_Allometry/inSituCoordinatesAndMeasurements.csv"))

# Make sure column cluster_ID does not exist:
points[,cluster_ID := NULL]
#first remove unnecessary points points:
validIDs = c(1:170)
validIDs = as.character(validIDs)
points = points[Sample_ID %in% validIDs,]

# RUN THESIS ALGORITHMS:
#buffer equal to 3 qualitative best from graphs:
buff = 3
assignedPoints = assignPointsToExistingClusters(points, clusters, buffer = buff)
numPointsWithInThresh = nrow(assignedPoints[closest_cluster_outside_threshold==FALSE])
numPointsWithInThresh

setwd(paste0("/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/mcc-s_point20_-t_point05/buffer", buff))
write_feather(assignedPoints, paste0("in_situ_points_with_cluster_assignments_buffer_", buff, ".feather"))

# Now run checkIfPointRepresentsMoreThanOneCluster
#I am here:
startTime2 = Sys.time()
#assignedPoints = checkIfPointRepresentsMoreThanOneCluster(assignedPoints, clusters)
endTime = Sys.time()
endTime - startTime2

endTime - startTime


#Plotting density threshold:
closestPoints = assignedPoints[,.SD[which.min(distance_to_closest_cluster_member)], by = cluster_ID]
g = ggplot(data = closestPoints, mapping = aes(x = distance_to_closest_cluster_member)) + geom_density() + theme_bw()
dMode = dmode(closestPoints$distance_to_closest_cluster_member)
g = g + geom_vline(xintercept = dMode, linetype="dotted", 
                color = "blue") + geom_vline(xintercept = buff * dMode,color = "red")



#write.csv(assignedPoints, "in_situ_points_with_cluster_assignments.csv")

#get cluster dictionary for points:
#clusterDict = buildClusterDict(assignedPoints)

#clusters = assignMergedIDsToClusters(clusterDict, clusters)

#Next re-extract cluster metrics with merged cluster IDs

################################################################################################################################################################################################################################################
#####  PLOTS ##################################################################################################################################################################################################################################################################################################################################################################################
################################################################################################################################################################################################################################################

# Plot assigned & threshed Points over clusters:
clusters$Label = factor(clusters$Label)
# make qualitative color palette:
# 82 "color blind friendly" colors from: 
# http://tools.medialab.sciences-po.fr/iwanthue/
# with outliers set to black: "#000000",

colorRamp79 = c("#e59758",
  "#4a52cd",
  "#60d249",
  "#955ce4",
  "#9dc721",
  "#b33bbd",
  "#44af29",
  "#732b9e",
  "#c6c120",
  "#d277ec",
  "#59ca61",
  "#e94cbf",
  "#509822",
  "#b42a91",
  "#95ce51",
  "#995cc4",
  "#8ab72f",
  "#6382e7",
  "#e3b434",
  "#4c54a5",
  "#bdbb47",
  "#8e3b86",
  "#3ecb88",
  "#e83381",
  "#429945",
  "#da65ab",
  "#799625",
  "#dd93e4",
  "#a6bf55",
  "#a0295e",
  "#8bc876",
  "#dd3652",
  "#55cabc",
  "#ee4731",
  "#56b7c6",
  "#bc2d1f",
  "#5faed8",
  "#e78e25",
  "#9e82cb",
  "#a59229",
  "#87a0d6",
  "#e36531",
  "#3f9a79",
  "#dd5a81",
  "#72c593",
  "#9f3233",
  "#79c09f",
  "#9d4314",
  "#45638c",
  "#b78028",
  "#6f4a7a",
  "#b4bf77",
  "#ba71a2",
  "#346016",
  "#cfa5d2",
  "#68701a",
  "#d47d90",
  "#3a8147",
  "#dc6b64",
  "#317674",
  "#d07248",
  "#31613f",
  "#924355",
  "#76994e",
  "#8d5d6b",
  "#d9b164",
  "#514e24",
  "#db9fa7",
  "#627140",
  "#e59b81",
  "#789674",
  "#864633",
  "#9cbfa1",
  "#935822",
  "#ceb089",
  "#84651e",
  "#ab7b5a",
  "#9a8e52",
  "#745a36")

cbf = c(#"#000000", 
  "#be408c",
  "#4cdc8b",
  "#b1379e",
  "#90d15e",
  "#442986",
  "#dab528",
  "#577ceb",
  "#cba815",
  "#424cad",
  "#acbd3d",
  "#745bc4",
  "#7bcf6e",
  "#863c9f",
  "#4eaa4c",
  "#e768c5",
  "#669b2c",
  "#9e7ee9",
  "#2e7c23",
  "#c180e2",
  "#a6bf55",
  "#6d1b66",
  "#37d8b0",
  "#c42a6d",
  "#5dba6f",
  "#8d3f90",
  "#af9a23",
  "#6d7ddb",
  "#e7af45",
  "#468ae0",
  "#dd8026",
  "#4e62aa",
  "#c1851b",
  "#3d3072",
  "#bdb553",
  "#835fb5",
  "#70851b",
  "#e592e6",
  "#255719",
  "#b765b8",
  "#3eac74",
  "#992963",
  "#77daa9",
  "#ab2540",
  "#36dee6",
  "#cd3e43",
  "#3aad8c",
  "#e25968",
  "#458541",
  "#db81c4",
  "#516f1d",
  "#c093db",
  "#817614",
  "#7199e0",
  "#a54909",
  "#894f8e",
  "#9fc069",
  "#6b1740",
  "#8cbf79",
  "#d95987",
  "#b9b567",
  "#97436d",
  "#e0b75e",
  "#de7bae",
  "#818035",
  "#d04c6c",
  "#b18b34",
  "#e67d9f",
  "#a06919",
  "#822131",
  "#d0a865",
  "#7d2716",
  "#e29249",
  "#c76674",
  "#80591b",
  "#e77162",
  "#9e3119",
  "#e1925d",
  "#d26c69",
  "#d16c2f",
  "#c46d53",
  "#e26a4a",
  "#aa612f")

cbf240 = c("#9367d4",
  "#2dae15",
  "#724fe2",
  "#8dce23",
  "#3f3ac2",
  "#5ae869",
  "#a053e1",
  "#3cbe3a",
  "#6f2bae",
  "#9be04c",
  "#9f6bf8",
  "#61b928",
  "#c947cd",
  "#b3d029",
  "#5969f0",
  "#c6cc27",
  "#8f1ea3",
  "#40ca6a",
  "#e83bbc",
  "#359721",
  "#b152d3",
  "#73ae22",
  "#b91ea2",
  "#8edf74",
  "#e66eec",
  "#71c050",
  "#5b3dac",
  "#d7c629",
  "#4250c2",
  "#ecc02b",
  "#7f73ed",
  "#87aa23",
  "#ba71ea",
  "#bbd14f",
  "#7f2d93",
  "#57e298",
  "#ef3ba5",
  "#539322",
  "#aa329c",
  "#479e46",
  "#ce268c",
  "#30af6a",
  "#f33a81",
  "#5cdfb5",
  "#e72525",
  "#48e5d5",
  "#e52740",
  "#45dbf1",
  "#ef4e25",
  "#436ed7",
  "#e9a226",
  "#695dbf",
  "#b7d165",
  "#8f4ab1",
  "#7eab3e",
  "#f570d4",
  "#297627",
  "#d55bc0",
  "#98a633",
  "#8c7ce2",
  "#eac252",
  "#5c3e94",
  "#d4c95c",
  "#3f4b9b",
  "#e9902b",
  "#458ee8",
  "#e9711f",
  "#778aed",
  "#c77715",
  "#2f63ac",
  "#cf4b15",
  "#53a4e5",
  "#d73a2d",
  "#45ccbc",
  "#e3245f",
  "#33b18b",
  "#a6186a",
  "#a7d479",
  "#872b83",
  "#90db9e",
  "#ae3388",
  "#688620",
  "#cc88ef",
  "#37661e",
  "#ea88e2",
  "#596d18",
  "#af6bcc",
  "#b19c31",
  "#af95f6",
  "#d19d37",
  "#7565b4",
  "#7b9b47",
  "#b85ab2",
  "#6cba7d",
  "#b61e5c",
  "#4cbe9e",
  "#ad2716",
  "#6ed7d8",
  "#c12f39",
  "#38b4be",
  "#f35656",
  "#298e5f",
  "#e15890",
  "#b8d88d",
  "#8d2973",
  "#95bc75",
  "#763174",
  "#dec775",
  "#334a84",
  "#eb8d4a",
  "#367bbb",
  "#f56d4a",
  "#68c3ef",
  "#d85537",
  "#41a7c5",
  "#ab4c0e",
  "#89cce7",
  "#c62f4d",
  "#379e93",
  "#e45a75",
  "#93d8bf",
  "#941b38",
  "#96d4d4",
  "#912320",
  "#a2bcf2",
  "#d97236",
  "#15729c",
  "#e77852",
  "#154975",
  "#f0b66e",
  "#a181d7",
  "#7e7318",
  "#e89ff0",
  "#415a1f",
  "#ea80ca",
  "#326034",
  "#ce5da7",
  "#769e5d",
  "#bd4383",
  "#569160",
  "#932764",
  "#afb46a",
  "#8c559d",
  "#938b34",
  "#8f8dd9",
  "#b08028",
  "#5d4480",
  "#ce883c",
  "#3585b0",
  "#a23e1d",
  "#5e9abd",
  "#87370d",
  "#939cdc",
  "#9d621e",
  "#c2aff0",
  "#616117",
  "#e7b1f1",
  "#4c501a",
  "#e89ddb",
  "#618042",
  "#b66eb7",
  "#b49c55",
  "#b386cd",
  "#64531b",
  "#cc7fc4",
  "#326b50",
  "#ee76aa",
  "#2e543c",
  "#ef7971",
  "#145a6a",
  "#e98e5d",
  "#3b5b8b",
  "#b75f30",
  "#6777b3",
  "#cd9659",
  "#7f6daa",
  "#c3d09f",
  "#972554",
  "#7cb89b",
  "#ba3f4c",
  "#448e99",
  "#c95449",
  "#34758f",
  "#a84535",
  "#b1c8eb",
  "#7a4618",
  "#dec6f1",
  "#6b6e37",
  "#94548c",
  "#93ac80",
  "#b94365",
  "#588f74",
  "#a14e7c",
  "#607f54",
  "#df90bb",
  "#20554c",
  "#ed93ac",
  "#35776f",
  "#bc5857",
  "#75afaa",
  "#92353d",
  "#7090bb",
  "#863c2c",
  "#9ea2c8",
  "#8a632f",
  "#bfa0d0",
  "#806d35",
  "#ab7fb1",
  "#9a7d42",
  "#54739a",
  "#ee9f81",
  "#485172",
  "#e3c18f",
  "#79345d",
  "#ddc7a5",
  "#66426a",
  "#8d9260",
  "#bd739c",
  "#504e2d",
  "#dfacce",
  "#724b31",
  "#f0b8c3",
  "#7e3443",
  "#b79c6e",
  "#93577c",
  "#6e6c49",
  "#ba6882",
  "#e0ae95",
  "#777399",
  "#c27c54",
  "#886587",
  "#a25f48",
  "#bc899c",
  "#a38366",
  "#92465f",
  "#da9896",
  "#7d4f55",
  "#d27a78",
  "#af796f",
  "#b25e68"
)

colorRamp291 = c(
  "#aa8e27",
  "#3e50ec",
  "#8dea37",
  "#4e2ac0",
  "#b9ed3a",
  "#8e49e9",
  "#3ce85f",
  "#b631cf",
  "#70ea60",
  "#e152ed",
  "#87c618",
  "#724fe2",
  "#cde83c",
  "#293bbe",
  "#e3dd27",
  "#3e57da",
  "#aad02d",
  "#8b2cbb",
  "#33ba3d",
  "#b25aed",
  "#89e35f",
  "#e043ce",
  "#6ee982",
  "#e321b2",
  "#5bb132",
  "#9867f6",
  "#d6dc44",
  "#7468ef",
  "#f6c519",
  "#513eb4",
  "#afed6d",
  "#83169a",
  "#73ae22",
  "#864bcc",
  "#b2ba1a",
  "#6c2ea7",
  "#8ecd51",
  "#b91ea2",
  "#54e492",
  "#f128a4",
  "#59f6bd",
  "#fa53ce",
  "#45921e",
  "#ba61df",
  "#88aa16",
  "#9b75f6",
  "#cebe21",
  "#3447b4",
  "#eede59",
  "#6371eb",
  "#bde267",
  "#a835a7",
  "#9abf46",
  "#633ca3",
  "#dcb832",
  "#3770df",
  "#ee921e",
  "#478fed",
  "#f04514",
  "#4be9dd",
  "#e6262f",
  "#4ed1f8",
  "#eb4b2f",
  "#2baad3",
  "#b12714",
  "#61d8a8",
  "#e349b8",
  "#40a149",
  "#ce268c",
  "#6ac572",
  "#c14ab3",
  "#abec94",
  "#7f2d93",
  "#ccd966",
  "#855ece",
  "#a8b334",
  "#b780f3",
  "#2a731a",
  "#dc7be9",
  "#8ca336",
  "#473f9c",
  "#c7bb43",
  "#6f3a93",
  "#95cf73",
  "#e66dd5",
  "#1f7330",
  "#f04ba6",
  "#41b178",
  "#e83381",
  "#4b934d",
  "#eb67bc",
  "#44701b",
  "#a05abc",
  "#eaae3b",
  "#7a8ef4",
  "#d6791f",
  "#467dd3",
  "#e26428",
  "#589fe9",
  "#cb8a24",
  "#7373d4",
  "#e5c35d",
  "#274994",
  "#dad06d",
  "#8a2783",
  "#a5e6a8",
  "#eb2b5b",
  "#3cafa1",
  "#ea3772",
  "#50ac88",
  "#d42f3d",
  "#63d1e7",
  "#ab440b",
  "#43a2da",
  "#ec5d51",
  "#68c8ca",
  "#c32a46",
  "#92e5e9",
  "#951a28",
  "#a9ead1",
  "#9a1d70",
  "#7faf62",
  "#c54091",
  "#6b8623",
  "#c186e6",
  "#a69e34",
  "#715cb6",
  "#b6cc7f",
  "#72327c",
  "#d7df99",
  "#545daf",
  "#a17018",
  "#2c61af",
  "#c48738",
  "#9a82e0",
  "#255719",
  "#e990e7",
  "#457636",
  "#e95fa4",
  "#3b8554",
  "#be2c60",
  "#328867",
  "#ef6174",
  "#235e31",
  "#be68bd",
  "#9ca756",
  "#a752a6",
  "#8a8731",
  "#b594ed",
  "#6c7121",
  "#cc7dcf",
  "#4f6621",
  "#dc73bc",
  "#3b541a",
  "#f0a1e8",
  "#5c5309",
  "#a19ced",
  "#9e5309",
  "#68b8ec",
  "#c04137",
  "#3f81c2",
  "#c16a2d",
  "#1668a6",
  "#ec8451",
  "#154975",
  "#dfaf62",
  "#4c4284",
  "#f1d095",
  "#633c7c",
  "#c5e0b1",
  "#8c1f5d",
  "#86af7c",
  "#ac4385",
  "#1a6447",
  "#e4659b",
  "#304e26",
  "#d4adf4",
  "#796518",
  "#829ce5",
  "#c15730",
  "#4592be",
  "#913b14",
  "#97caf2",
  "#783019",
  "#b4bcf7",
  "#76480d",
  "#5f74bb",
  "#eb9e61",
  "#2178a3",
  "#f08073",
  "#13526c",
  "#f0a07e",
  "#2e5b88",
  "#be7541",
  "#8c83cd",
  "#957731",
  "#6f5096",
  "#c7b572",
  "#985095",
  "#78884c",
  "#9a2054",
  "#97d0bc",
  "#9a2340",
  "#78baa4",
  "#cb5061",
  "#54aab9",
  "#a84535",
  "#318691",
  "#8c3724",
  "#bacaef",
  "#862a33",
  "#3d8376",
  "#d16289",
  "#284e37",
  "#ec8dbe",
  "#426037",
  "#efb4e8",
  "#4c501a",
  "#b69cde",
  "#646831",
  "#c776b0",
  "#3f674d",
  "#f288aa",
  "#215e5a",
  "#e77a8b",
  "#6a957d",
  "#a23a50",
  "#d3cfa8",
  "#793c73",
  "#b58949",
  "#5179aa",
  "#8e5425",
  "#84aacd",
  "#bd644c",
  "#558aa6",
  "#cb6563",
  "#406b87",
  "#cf8f69",
  "#3f436d",
  "#c09669",
  "#575e8e",
  "#a19d6e",
  "#863563",
  "#6a7d54",
  "#a575b4",
  "#605121",
  "#dbbbec",
  "#6d421d",
  "#b9b4dd",
  "#7d372f",
  "#9099cb",
  "#895d35",
  "#7973a9",
  "#887543",
  "#8d6797",
  "#4e5632",
  "#e4bad9",
  "#5d5132",
  "#f0b8c7",
  "#65462d",
  "#bb90bb",
  "#9d764a",
  "#485475",
  "#edb8a6",
  "#684266",
  "#caaa89",
  "#7d2f4c",
  "#7387ac",
  "#a04a45",
  "#db9eb9",
  "#784533",
  "#af668f",
  "#7e6749",
  "#b45475",
  "#9c7e61",
  "#855575",
  "#e79691",
  "#70444a",
  "#d0978a",
  "#8b435b",
  "#a3694d",
  "#986d81",
  "#bd6e63",
  "#823d44",
  "#bc848e",
  "#b95968",
  "#b67c68",
  "#a66378",
  "#8f5e5b",
  "#c0757a",
  "#a45c61")

# Plot only those points inside threshold:
#organize data to be rbinded:
#first remove unnecessary points from assigned and thresholded Points:
validIDs = c(1:170)
validIDs = as.character(validIDs)
assignedPoints = assignedPoints[Sample_ID %in% validIDs,]

#remove outliers (coded -1) in clusters data.table:
plotDT = clusters[Label != -1,]
plotDT = droplevels(plotDT)

# removing in situ points outside of study area:
maxX = max(plotDT[,X])
minX = min(plotDT[,X])
maxY = max(plotDT[,Y])
minY = min(plotDT[,Y])
assignedPoints = assignedPoints[X < maxX & X > minX & Y < maxY & Y > minY]


#plotting XY cluster-points and ALL in situ points
renderStartTime = Sys.time()
ggp1 = ggplot() + geom_point(mapping = aes(x = X, y = Y, color = factor(Label)), data = plotDT, size = .75) + theme_bw() + theme(legend.position="none") + coord_equal() + scale_colour_manual(values = cbf240)
ggp1 = ggp1 + geom_point(data = assignedPoints, mapping = aes(x = X, y = Y), shape = 8)
ggp1
Sys.time() - renderStartTime

#plotting XY cluster-points and assigned points within threshold
renderStartTime = Sys.time()
ggp = ggplot() + geom_point(mapping = aes(x = X, y = Y, color = factor(Label)), data = plotDT, size = .75) + theme_bw() + theme(legend.position="none") + coord_equal() + scale_colour_manual(values = cbf240)
ggp = ggp + geom_point(data = assignedPoints[closest_cluster_outside_threshold == FALSE,], mapping = aes(x = X, y = Y), shape = 8)
dev.new()
ggp
Sys.time() - renderStartTime

#testing adding assigned_to_point column to clusters:
#ggp = ggplot() + geom_point(mapping = aes(x = X, y = Y, color = factor(assigned_to_point)), data = plotDT, size = .75) + theme_bw() + theme(legend.position="none") + scale_colour_manual(values = cbf) 



#plotting density threshold:
closestPoints = assignedPoints[,.SD[which.min(distance_to_closest_cluster_member)], by = cluster_ID]
plot(density(closestPoints$distance_to_closest_cluster_member, kernel=c("gaussian")), main = NULL, xlab = NULL)
abline(v = dmode(closestPoints$distance_to_closest_cluster_member), col = "red")
abline(v = 10 * dmode(closestPoints$distance_to_closest_cluster_member), col = "darkgreen")






#PLOTTING ONLY THOSE POINTS THAT REPRESENT CLUSTERS WHICH HAVE BEEN MERGED:
#plotting XY cluster-points and assigned points within threshold
renderStartTime = Sys.time()
ggp = ggplot() + geom_point(data = plotDT,mapping = aes(x = X, y = Y, color = factor(mergedClusterID)), size = .75) + theme_bw() + theme(legend.position="none") + scale_colour_manual(values = cbf240) + coord_equal()
ggp = ggp + geom_point(data = assignedPoints, mapping = aes(x = X, y = Y), shape = 8)
ggp
#testing adding assigned_to_point column to clusters:
#ggp = ggplot() + geom_point(mapping = aes(x = X, y = Y, color = factor(assigned_to_point)), data = plotDT, size = .75) + theme_bw() + theme(legend.position="none") + scale_colour_manual(values = cbf) 


ggp = ggp + geom_point(data = assignedPoints[closest_cluster_outside_threshold == FALSE & merged == TRUE,], mapping = aes(x = X, y = Y), shape = 8)
#ggp = ggp + geom_point(data = assignedPoints[closest_cluster_outside_threshold == FALSE,], mapping = aes(x = X_closest_cluster_centroid, y = Y_closest_cluster_centroid), shape = 13)
ggp

# Plotting all assigned points:
ggp = ggplot() + geom_point(mapping = aes(x = X, y = Y, color = factor(Label)), data = plotDT, size = .75) + theme_bw() + theme(legend.position="none") + scale_colour_manual(values = cbf) 
ggp = ggp + geom_point(data = assignedPoints[closest_cluster_outside_threshold == FALSE,], mapping = aes(x = X, y = Y), shape = 8)
ggp = ggp + geom_point(data = assignedPoints[closest_cluster_outside_threshold == FALSE,], mapping = aes(x = X_closest_cluster_centroid, y = Y_closest_cluster_centroid), shape = 13)
ggp

endTime = Sys.time()
renderTimeTaken = endTime - renderStartTime
timeTaken = endTime - startTime
print("Time taken to render graph: ")
print(renderTimeTaken)

print("Total Time Taken: ")
print(timeTaken)














######################################################################################################################################################################################################################################################

#plot distance translation distribution:
p = ggplot(testAssignedPoints, aes(x = distance_to_closest_cluster_member)) + geom_density(fill = "#3ec09a", alpha = 0.5) + theme_bw() + labs(x = "Distance from Point to Closest Cluster Member (m)", y = "Density")
p

######################################################################################################################################################################################################################################################

#plot all clusters:
ggp = ggplot(plotDT, aes(x = X, y = Y, color = Label)) + geom_point() + theme_bw() + theme(legend.position="none") + scale_colour_manual(values = cbf) 
ggp

######################################################################################################################################################################################################################################################
#Making plot showing assignment of points to clusters:

#organize data to be rbinded:
#first remove unnecessary points from assignedPoints:
validIDs = c(1:170)
validIDs = as.character(validIDs)

assignedPoints = assignedPoints[Sample_ID %in% validIDs,]

ggp = ggplot() + geom_point(mapping = aes(x = X, y = Y, color = Label), data = plotDT) + theme_bw() + theme(legend.position="none") + scale_colour_manual(values = cbf) 

ggp = ggp + geom_point(mapping = aes(x = X, y = Y),data = assignedPoints, shape = 8)

# removing in situ points outside of study area:
# NOW COMPLETED BEFORE RUNNING assignPointsToClusters()
#maxX = max(plotDT[,X])
#minX = min(plotDT[,X])
#maxY = max(plotDT[,Y])
#minY = min(plotDT[,Y])
#assignedPoints = assignedPoints[X < maxX & X > minX & Y < maxY & Y > minY]




###########################################################################################################################


p = ggplot(threshedPoints[closest_cluster_outside_threshold == FALSE,], aes(x = distance_to_centroid)) + geom_density(fill = "gray41", alpha = 0.5) + theme_bw() + labs(x = "Distance from Point to Cluster Centroid (m)", y = "Density")
p






