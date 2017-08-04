library(lidR)
library(data.table)
library(ggplot2)

p = ggplot(mapping = aes(x = mergedLas@data[Classification==2, Z])) + geom_density() + theme_bw() + labs(x = "Distribution of MCC-Ground-Classified Points")

p

quartz.save("/Users/seanhendryx/Google Drive/THE UNIVERSITY OF ARIZONA (UA)/THESIS/Graphs/SfM/Ground Delineation/SfM Distribution of MCC-Ground-Classified Points")


mu = mean(mergedLas@data[Classification==2, Z])

sigma = sd(mergedLas@data[Classification==2, Z])


#https://stackoverflow.com/questions/29824773/annotate-ggplot-with-an-extra-tick-and-label
## annotation_custom then turn off clipping
library(ggplot2)
library(grid)

p = p +
 annotation_custom(textGrob(expression(bar(x)), gp = gpar(col = "red")), 
        xmin=mu, xmax=mu,ymin=-.15, ymax=-.15) +
 annotation_custom(segmentsGrob(gp = gpar(col = "red", lwd = 2)), 
        xmin=mu, xmax=mu,ymin=-.05, ymax=0.05)

g = ggplotGrob(p)
g$layout$clip[g$layout$name=="panel"] <- "off"
grid.draw(g)

quartz.save("/Users/seanhendryx/Google Drive/THE UNIVERSITY OF ARIZONA (UA)/THESIS/Graphs/SfM/Ground Delineation/SfM Distribution After Removing Outliers of MCC-Ground-Classified Points")
