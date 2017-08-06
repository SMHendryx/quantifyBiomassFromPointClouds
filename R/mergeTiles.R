# merges all las tiles in a directory into a single las file
library("lidR")
library("data.table")


args = commandArgs(trailingOnly = TRUE)
#args should be (complete paths with '/' after directories) 1. directory containing las files to be merged, 2. original las file from which to pull las header 3. whether or not to plot (default is FALSE) 4. whether or not to write (default is TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)== 1) {
  stop("At least two arguments must be supplied: 1. directory containing las files to be merged, and 2. original las file from which to pull las header. ", call.=FALSE)
} else if (length(args)==2) {
  args[3] = FALSE
  args[4] = TRUE
} else if(length(args ==3)){
  args[4] = TRUE
}

directoryPath = args[1]
file = args[2]
plotControl = args[3]
writeControl = args[4]
#directoryPath = "/Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/classified/mcc-s_point20_-t_point05/tiles/"
#file = "/Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/Rectangular_MILDDEPTHFILTERINGOptimized_GeoreferencedWithUpdatealtizureImages.las"
#plotControl = TRUE
#writeControl = TRUE

setwd(directoryPath)
fileList = list.files()
fileList = fileList[grep("*.las", fileList)]
if(length(fileList) < 2){
  stop("Cannot merge less than two files.")
}

#Forked from https://psychwire.wordpress.com/2011/06/05/testing-different-methods-for-merging-a-set-of-files-into-a-dataframe/ 
func = function(file){
  las = readLAS(file)
  DT = as.data.table(las@data)
  return(DT)
}

print("Binding las files:")
print(fileList)

merged = do.call("rbind",lapply(fileList, func))

#get header:
original = readLAS(file)
head = original@header
rm(original)

mergedLas = LAS(merged, header = head)

if(writeControl){
  writeLAS(mergedLas, paste0(directoryPath, "../Merged_Ground_Classified.las"))
}

if(plotControl){
  plot(mergedLas, color = "Classification")
  #plot(mergedLas, color = "color")
}
