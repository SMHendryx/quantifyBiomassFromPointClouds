# Run tileR
# Clear workspace:
rm(list=ls())
library(lidR)
#library(data.table)


args = commandArgs(trailingOnly = TRUE)
#args should be 1: directory, 2: input las file to tile, and 3: whether or not to plot

# test if there are at least two arguments: if not, return an error
if (length(args) < 2) {
  stop("At least two arguments must be supplied (working directory where to write tiles and input file (.las)).n", call.=FALSE)
} else if (length(args)==2) {
  args[3] = FALSE
}

directoryPath = args[1]
inputLasFile = args[2]
plotControl = args[3]

# I am here:
setwd(directoryPath)

las = readLAS(inputLasFile)

source("/Users/seanhendryx/githublocal/tileR/tileR.R")

tileR(las, c(4,5))

# merge with rbind in R or lasmerge lastools utility:
#mergedBackTogether = readLAS("merged.las")
#plot(mergedBackTogether)