library(lidR)
library(data.table)
library(ggplot2)
library(grid)


#Read in ground-classifed las file (mergedLas)
mergedLas = readLAS("/Users/seanhendryx/Data/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/PMF/Merged_Ground_Classified.las")

allTiles = readLAS("/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/below_ground_points_removed/classified/Merged_Ground_Classified.las")

mu = mean(allTiles@data[Classification==2, Z])

sigma = sd(allTiles@data[Classification==2, Z])

#plotting:
p = ggplot(mapping = aes(x = mergedLas@data[,Z])) + geom_density() + theme_bw() + labs(x = "Distribution of Inaccurately PMF-Ground-Classified Points")

p = p +
 annotation_custom(textGrob(expression(bar(x)), gp = gpar(col = "red")), 
        xmin=mu, xmax=mu,ymin=-.016, ymax=-.016) +
 annotation_custom(segmentsGrob(gp = gpar(col = "red", lwd = 2)), 
        xmin=mu, xmax=mu,ymin=-.005, ymax=0.01)

 p = p +
 annotation_custom(textGrob(expression(3 * sigma), gp = gpar(col = "dark green")), 
        xmin=mu -(3*sigma), xmax=mu-(3*sigma),ymin=-.016, ymax=-.016) +
 annotation_custom(segmentsGrob(gp = gpar(col = "dark green", lwd = 2)), 
        xmin=mu-(3*sigma), xmax=mu-(3*sigma),ymin=-.005, ymax=0.01)

  p = p +
 annotation_custom(textGrob(expression(sigma), gp = gpar(col = "orange")), 
        xmin=mu -(sigma), xmax=mu-(sigma),ymin=-.016, ymax=-.016) +
 annotation_custom(segmentsGrob(gp = gpar(col = "dark green", lwd = 2)), 
        xmin=mu-(sigma), xmax=mu-(sigma),ymin=-.005, ymax=0.01)

g = ggplotGrob(p)
g$layout$clip[g$layout$name=="panel"] <- "off"
grid.draw(g)


# Apply lasfilter to create new las object including points only within 3sd of ground points as classified by MCC-lidar:
allTiles = allTiles %>% lasfilter(Z > (mu - (3 * sigma)))

#trying min of tlidar:
tlas = readLAS("/Users/seanhendryx/DATA/Lidar/SRER/maxLeafAreaOctober2015/rectangular_study_area/classified/all20TilesGroundClassified.las")

allSfMTiles = allTiles %>% lasfilter(Z > min(tlas@data[,Z]))

#removing classification for ground classification:
allSfMTiles@data[,Classification := 0]

writeLAS(allSfMTiles, "~")
