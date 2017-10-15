# Plots for visualizing cross-validated model results

##Load packages:
packages = c('ggplot2', 'data.table', 'feather')
lapply(packages, library, character.only = TRUE)


setwd("/Users/seanmhendryx/Data/thesis/thesisResults")

# Read in cross val results:
cDT = as.data.table(read_feather("Cumulative_Model_Errors_on_SfM_Data.feather"))
DT = as.data.table(read_feather("Model_Errors_on_SfM_Data.feather"))

p = ggplot(data = cDT, mapping = aes(x = fold, y = error, color = model)) + geom_line() + theme_bw() +  labs(x = "Fold", y = "Cumulative Difference from Test Data (kg)")# + ggtitle("Feature Family Subset Classification Performance")
p = + theme(strip.background = element_rect(fill="white"))
p = p + facet_grid(. ~ dataset)
p

c = ggplot(data = cDT, mapping = aes(x = fold, y = absolute_error, color = model)) + geom_line() + theme_bw() +  labs(x = "Fold", y = "Cumulative Difference from Test Data (kg)")# + ggtitle("Feature Family Subset Classification Performance")
c = c + facet_grid(. ~ dataset)
c