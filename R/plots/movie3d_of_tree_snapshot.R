# Make 3d movie of a cluster in a point cloud

# Clear workspace:
rm(list=ls())
# Load packages:
library(lidR) 
library(data.table) 
library(ggplot2)
library(plotly)
library(feather)
library(rgl)
source("~/githublocal/quantifyBiomassFromPointClouds/quantifyBiomassFromPointClouds/R/utils_colors.R")


#–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-#
#                         FUNCTION DEFINITIONS                                                                                                             #
#–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-#
rgl.openWindow = function(new.device = TRUE, bg = "black", width = 1280, height = 720) { 
  if( new.device | rgl.cur() == 0 ) {
    rgl.open()
    par3d(windowRect = 50 + c( 0, 0, width, height ) )
    rgl.bg(color = bg )
  }
  rgl.clear(type = c("shapes", "bboxdeco"))
  rgl.viewpoint(theta = 15, phi = 20, zoom = 10.0)
}

getXYExtents = function(tile){
  # @param tile = A LidR las object
  # Returns a 4 element tuple of xMin, xMax, yMin, yMax
  xMin = min(tile@data$X)
  xMax = max(tile@data$X)
  yMin = min(tile@data$Y)
  yMax = max(tile@data$Y)
  extents = c(xMin, xMax, yMin, yMax)
  return(extents)
}

clipToExtents = function(inCloud, shapeCloud){
  # @param inCloud = a LidR las object. The larger point cloud to be clipped to extents of shapeCloud
  # @param shapeCloud = a LidR las object. The smaller point cloud by which to clip inCloud
  # Returns an las object HEADER IGNORED
  extents = getXYExtents(shapeCloud)
  clipped = LAS(inCloud@data[X >= extents[1] & X <= extents[2] & Y >= extents[3] & Y <= extents[4]])
  return(clipped)
}

save3dMovie = function(las, displayDims = c(2880, 1800), seconds = 12){
  # saves 3d movie in current working direc. Does not return object. Will overwrite movie.gif and movie.mov if existing
  lasData = las@data
  rgl.openWindow(width = displayDims[1], height = displayDims[2])
  rgl.viewpoint(phi = -90, zoom = .475)
  rgl.points(lasData$X, lasData$Y, lasData$Z, color = set.colors(lasData$Z, palette = height.colors(unique(lasData$Z))))
  movie3d(f = spin3d(axis = c(0, 0, 1)), duration = seconds, dev = rgl.cur(), fps = 20,
    movie = "movie", frames = "movie", dir = tempdir(),
    convert = NULL, clean = TRUE, verbose = TRUE,
    top = TRUE, type = "gif", startTime = 0)

  # ^ will save movie to temp
  system(paste0("mv ",  tempdir(), "/movie.gif ", getwd()))
  system("convert movie.gif movie.mov")
}

play3dTree = function(las,  displayDims = c(2880, 1800)){
  lasData = las@data
  rgl.openWindow(width = displayDims[1], height = displayDims[2])
  rgl.viewpoint(phi = -90, zoom = .475)
  rgl.points(lasData$X, lasData$Y, lasData$Z, color = set.colors(lasData$Z, palette = height.colors(unique(lasData$Z))))
  play3d(f = spin3d(axis = c(0, 0, 1)))

}

plot3dTree = function(las, )

save3dMovieFrames = function(las, displayDims = c(2880, 1800), axis = c(.25, .75, 1)){
  # saves 3d movie in current working direc. Does not return object. Will overwrite movie.gif and movie.mov if existing
  lasData = las@data
  rgl.openWindow(width = displayDims[1], height = displayDims[2])
  rgl.viewpoint(phi = -90, zoom = .475)
  rgl.points(lasData$X, lasData$Y, lasData$Z, color = set.colors(lasData$Z, palette = height.colors(unique(lasData$Z))))
  dir.create("animation")
  for (i in 1:90) {
    view3d(userMatrix=rotationMatrix(2*pi * i/90, axis[1], axis[2], axis[3]))
    rgl.snapshot(filename=paste("animation/frame-",
      sprintf("%03d", i), ".png", sep=""))
  }
}

save3dMovieRGBFrames = function(las, displayDims = c(2880, 1800), axis = c(.25, .75, 1), zoomFactor = .75, numFrames = 180){
  # saves 3d movie in current working direc. Does not return object. Will overwrite movie.gif and movie.mov if existing
  lasData = las@data
  rgl.openWindow(width = displayDims[1], height = displayDims[2])
  rgl.viewpoint(zoom = zoomFactor)
  hexColors = rgb(lasData$R, lasData$G, lasData$B, maxColorValue = max(lasData[,.(R,G,B)]))
  #rglargs = list()
  #rglargs$col = hexColors
  rgl.points(lasData$X, lasData$Y, lasData$Z, color = hexColors)
  dir.create("animation")
  for (i in 1:numFrames) {
    view3d(userMatrix=rotationMatrix(2*pi * i/numFrames, axis[1], axis[2], axis[3]), zoom = zoomFactor)
    rgl.snapshot(filename=paste("animation/frame-",
      sprintf("%03d", i), ".png", sep=""))
  }
}

save3dMovieRGB = function(las, displayDims = c(2880, 1800), seconds = 12, axis = c(.25, .75, 1)){
  # saves 3d movie in current working direc. Does not return object. Will overwrite movie.gif and movie.mov if existing
  lasData = las@data
  rgl.openWindow(width = displayDims[1], height = displayDims[2])
  rgl.viewpoint(phi = -90, zoom = .475)
  rgl.points(lasData$X, lasData$Y, lasData$Z, color = set.colors(lasData$Z, palette = height.colors(unique(lasData$Z))))
  dir.create("animation")
  for (i in 1:90) {
    view3d(userMatrix=rotationMatrix(2*pi * i/90, axis[1], axis[2], axis[3]))
    rgl.snapshot(filename=paste("animation/frame-",
      sprintf("%03d", i), ".png", sep=""))
  }
}


makeMovieFromFrames = function(){
  system("cd animation")
  system("convert -delay 5 -loop 0 frame*.png animated.gif")
}

#–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-#
#                         MAIN                                                                                                                             #
#–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-–––––––––––––––––––––-#

# Run:
setwd("/Users/seanmhendryx/Data/thesis/Processed_Data/T-lidar")

# read in original las file
#las = readLAS("all20TilesGroundClassified.las")
# get header:
#oheader = las@header

# read in clustered point cloud:
clusters = as.data.table(read_feather("all20TilesGroundClassified_and_Clustered_By_Watershed_Segmentation.feather"))
colnames(clusters)[1] = 'X'

las = LAS(clusters)
#plot(las)

selecter = FALSE
if(selecter){
  bigTree = lasroi(las)
  densSampedTree = lasroi(las)
  twoClusters = lasroi(las)

  lass = c(bigTree, densSampedTree, twoClusters)
  lasStrings = c('bigTree', 'densSampedTree', 'twoClusters')
  i = 1
  for(las_i in lass){
    write_feather(las_i@data, paste0("trees_for_movie3d/", lasStrings[i], ".feather"))
    i = i + 1
  }
}else{
  #use for loop with assign()?
  twoClusters = LAS(read_feather("trees_for_movie3d/twoClusters.feather"))
  bigTree = LAS(read_feather("trees_for_movie3d/bigTree.feather"))
}
#p = ggplot(data = clusters, mapping = aes(x = X, y = Y)) + geom_point() + theme_bw() + coord_fixed()
#ply = ggplotly(p)
#ply

#play 3d plot:
dims = c(2880, 1800)

#make vid of two clusters:
#rgl.openWindow(width = dims[1], height = dims[2])
#rgl.viewpoint(phi = -90, zoom = .475)
#rgl.points(twoClusters@data$X, twoClusters@data$Y, twoClusters@data$Z, color = set.colors(twoClusters@data$treeID, palette = height.colors(unique(twoClusters@data$treeID))))
#play3d(spin3d(axis = c(0, 0, 1)),duration = 120)

# Save movie of two clusters:
# FRIST MAKE SURE ALL GRAPHICS DEVICES ARE CLOSED
plotTwoClusters = FALSE
if(plotTwoClusters){
  twoClusters = twoClusters@data
  rgl.openWindow(width = dims[1], height = dims[2])
  rgl.viewpoint(phi = -90, zoom = .475)
  rgl.points(twoClusters$X, twoClusters$Y, twoClusters$Z, color = set.colors(twoClusters$treeID, palette = height.colors(unique(twoClusters$treeID))))
  movie3d(f = spin3d(axis = c(0, 0, 1)), duration = 12, dev = rgl.cur(), fps = 20,
    movie = "movie", frames = "movie", dir = tempdir(),
    convert = NULL, clean = TRUE, verbose = TRUE,
    top = TRUE, type = "gif", startTime = 0)

  # ^ will save movie to temp
  system(paste0("mv ",  tempdir(), "/movie.gif ", getwd()))
  system("convert movie.gif movie.mov")
}

# Get bigTree from undecimated point cloud:
# Test functions for clipping: 
test = clipToExtents(las, bigTree)
all.equal(test, bigTree)


#do the same for A-lidar and SfM:
paths = c("/Users/seanmhendryx/Data/thesis/Processed_Data/A-lidar/rerunWatershed", "/Users/seanmhendryx/Data/thesis/Processed_Data/SfM")
files = c("Rectangular_UTMAZ_Tucson_2011_000564.las", "belowGroundPointsRemoved_Rectangular_MILDDEPTHFILTERINGOptimized_GeoreferencedWithUpdatealtizureImages.las")

#just SfM:
setwd(paths[2])
fullSfMCloud = readLAS(files[2])

denseBigTree = clipToExtents(fullSfMCloud, bigTree)

play3dTree(denseBigTree)

save3dMovieFrames(denseBigTree)

#save 3d frames with RGB color:
save3dMovieRGBFrames(fullSfMCloud)



plot(fullSfMCloud, color = hexColors)



# read in undecimated T-lidar
setwd("/Users/seanmhendryx/Data/thesis")

fullTCloud = readLAS("tLidarSRERMesTowerOct2015.las")

denseBigTree = clipToExtents(fullTCloud, bigTree)

save3dMovie_snapshot(denseBigTree)






save3dMovie(denseBigTree)

for(i in 1:2){
  setwd(paths[i])
  fullTCloud = readLAS(files[i])

  denseBigTree = clipToExtents(fullTCloud, bigTree)

  save3dMovie(denseBigTree)
}

#now do the same with SfM with RGB color instead of height:

