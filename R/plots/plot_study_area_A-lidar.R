# Making and plotting catalog of las tiles on local machine

# Clear workspace:
rm(list=ls())
library(lidR) #detach("package:lidR", unload=TRUE)
#library(ggplot2)


direc = "/Users/seanmhendryx/Data/thesis/Processed_Data/A-lidar/rerunWatershed/"
file = "Rectangular_UTMAZ_Tucson_2011_000564.las"
setwd(direc)

las = readLAS(file)

plot(las)






files = list.files()

#plot one:
#las = readLAS(files[11])
#plot(las)


for (file in files){
    tile = readLAS(file)
    plot(tile)
}


for (file in files){
    tile = readLAS(file)
    plot(tile, color = "Classification")
}

#"File with most ground points: tile-20_PMF_MWS7Sp5IDp05CSp1.las"
