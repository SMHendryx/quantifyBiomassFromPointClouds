# plotCHM.R
# Clear workspace:
rm(list=ls())
library(lidR) #detach("package:lidR", unload=TRUE)
library(data.table) #detach("package:data.table", unload=TRUE)
library(raster) #detach("package:raster", unload=TRUE)
library(ggplot2)


args = commandArgs(trailingOnly = TRUE)
#args should be 1. directory, 2. input las file to clip, and 3. whether or not to plot

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==2) {
  args[3] = FALSE
}

directoryPath = args[1]
file = args[2]
plotControl = args[3]

#directoryPath = "/Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area"
#file = "Rectangular_MILDDEPTHFILTERINGOptimized_GeoreferencedWithUpdatealtizureImages.las"
setwd(directoryPath)
studyArea = readLAS(file)

#studyArea %>% grid_density(res = 1) %>% plot

# lasdecimate doesn't seem to work if pulseID all equal 1 or if pulseID or gpstime columns are missing
# So set pulse id to sequence
dims = dim(studyArea$data)
length = dims[1]
studyArea$data[,pulseID := as.numeric(seq(length.out = length))]
studyArea$data[,gpstime := seq(length.out = length)]
thinned = lasdecimate(studyArea, density = 1000,res = 1)
# Works!
writeLAS(thinned, paste0("Decimated_", file))


if(plotControl == TRUE){
  plot(studyArea)
}

print("EXIT_SUCCESS")

