library(lidR)
library(data.table)
library(ggplot2)
library(grid)


mergedLas = readLAS("/Users/seanhendryx/DATA/SfMData/SRER/20160519Flights/mildDepthFiltering/rectangular_study_area/classified/mcc-s_point20_-t_point05/Merged_Ground_Classified.las")

mu = mean(mergedLas@data[Classification==2, Z])

sigma = sd(mergedLas@data[Classification==2, Z])

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


quartz.save("/Users/seanhendryx/Google Drive/THE UNIVERSITY OF ARIZONA (UA)/THESIS/Graphs/SfM/Ground Delineation/SfM Distribution of Inaccurately PMF-Ground-Classified Points with mu and sigma.png")




#https://stackoverflow.com/questions/29824773/annotate-ggplot-with-an-extra-tick-and-label
## annotation_custom then turn off clipping



quartz.save("/Users/seanhendryx/Google Drive/THE UNIVERSITY OF ARIZONA (UA)/THESIS/Graphs/SfM/Ground Delineation/SfM Distribution After Removing Outliers of MCC-Ground-Classified Points with x bar.png")
