# Plots for visualizing cross-validated model results

##Load packages:
packages = c('ggplot2', 'data.table', 'feather')
lapply(packages, library, character.only = TRUE)


setwd("/Users/seanmhendryx/Data/thesis/crossValResults")

# Read in cross val results:
cDT = as.data.table(read_feather("Cumulative_Model_Errors.feather"))
DT = as.data.table(read_feather("Model_Errors.feather"))

cDT[model == "RFCF_ESA", model := "RFCFESA"]

# set order of facets:
cDT[,dataset := factor(dataset, levels = c('T-lidar', 'A-lidar', 'SfM'))]
#cDT[,model := factor(model, levels = c('PV', 'ESA', 'RFCF', 'RFCF_ESA'))]

p = ggplot(data = cDT, mapping = aes(x = fold, y = error, color = model)) + geom_line() + theme_bw() +  labs(x = "Fold", y = "Cumulative Difference from Test Data (kg)")# + ggtitle("Feature Family Subset Classification Performance")
p = p + theme(strip.background = element_rect(fill="white"))
p = p + facet_grid(. ~ dataset)
p

c = ggplot(data = cDT, mapping = aes(x = fold, y = absolute_error, color = model)) + geom_line() + theme_bw() +  labs(x = "Fold", y = "Cumulative Absolute Difference from Test Data (kg)")# + ggtitle("Feature Family Subset Classification Performance")
c = c + theme(strip.background = element_rect(fill="white"))
c = c + facet_grid(. ~ dataset)
dev.new()
c

b = ggplot(data = cDT, mapping = aes(x = model, y = error, color = model)) + geom_boxplot() + theme_bw() +  labs(x = "Model", y = "Difference from Test Data (kg)")# + ggtitle("Feature Family Subset Classification Performance")
b = b + theme(strip.background = element_rect(fill="white"))
b = b + facet_grid(. ~ dataset)
b

ab = ggplot(data = cDT, mapping = aes(x = model, y = absolute_error, color = model)) + geom_boxplot() + theme_bw() +  labs(x = "Model", y = "Absolute Difference from Test Data (kg)")# + ggtitle("Feature Family Subset Classification Performance")
ab = ab + theme(strip.background = element_rect(fill="white"))
ab = ab + facet_grid(. ~ dataset)
ab
