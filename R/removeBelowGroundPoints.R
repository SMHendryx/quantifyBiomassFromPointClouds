library(lidR)
library(data.table)
library(ggplot2)


#Read in ground-classifed las file (mergedLas)

mu = mean(mergedLas@data[Classification==2, Z])

sigma = sd(mergedLas@data[Classification==2, Z])

# Apply lasfilter to create new las object including points only within 3sd of ground points as classified by MCC-lidar:
mergedLas = mergedLas %>% lasfilter(Z > (mu - (3 * sigma)))
