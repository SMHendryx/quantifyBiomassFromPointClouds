# Ranks models by error and computes error percentage redcution from the worst (highest error) to the best (lowest error).

library(data.table)
library(feather)


####---------------------------------------------------------------------------------------------------####
#         FUNCTION DEFINITIONS                                                                         ####
####---------------------------------------------------------------------------------------------------####

rmse = function(errors){
  # Computes Root Mean Square Error
  # will work on a list of error values or a single error value (in which case, the same value is returned)
  return(sqrt(mean(errors^2)))
}

mae = function(errors){
  # Computes Mean Absolute Error
  # will work on a list of error values or a single error value (in which case, the same value is returned)
  return(mean(abs(errors)))
}


####---------------------------------------------------------------------------------------------------####
#         MAIN                	                                                                         ####
####---------------------------------------------------------------------------------------------------####

# Get data:
direc = "/Users/seanmhendryx/Data/thesis/thesisResults"
setwd(direc)

dt = as.data.table(read_feather("Model_Errors.feather"))
cdt =  as.data.table(read_feather("Cumulative_Model_Errors.feather"))

datasets = unique(dt[,dataset])
models = unique(dt[,model])

# Save maes and rmses:
errorMetrics = data.table(dataset = expand.grid(models, datasets)[[2]], model  = expand.grid(models, datasets)[[1]], MAE = NA_real_, RMSE = NA_real_)

i = 1
for(dataset_i in datasets){
  for(model_i in models){
      errors = dt[dataset == dataset_i & model == model_i, error]
      mae_i = mae(errors)
      rmse_i = rmse(errors)
      print(paste0("Mean Absolute Error of dataset: ", dataset_i, " model: ", model_i))
      print(mae_i)
      print(paste0("RMS Error of dataset: ", dataset_i, " model: ", model_i))
      print(rmse_i)
      errorMetrics[dataset == dataset_i & model == model_i, MAE := mae_i]
      errorMetrics[dataset == dataset_i & model == model_i, RMSE := rmse_i]
      print(i)
      i = i +1
  }
}

write.csv(errorMetrics, "errorMetrics.csv")
