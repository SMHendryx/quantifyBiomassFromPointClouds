# simplifed fork of lasnormalize.r from lidR without error checking (since error check in lidR's func is currently buggy)
library(lidR)
library(data.table)

lasNormalizeR = function(.las, dtm = NULL, method = "none", k = 10L, model = gstat::vgm(.59, "Sph", 874))
{
  . <- Z <- Zn <- X <- Y <- Classification <- NULL

  #stopifnotlas(.las)

  #if(is.null(dtm))
  #{
  #  normalized = LAS(data.table::copy(.las@data), .las@header)
  #  Zground = interpolate(.las@data[Classification == 2, .(X,Y,Z)], .las@data[, .(X,Y)], method = method, k = k, model = model)
  #  normalized@data[, Zn := Zground][]
  #  isna = is.na(Zground)
  #}
  #else
  #{
  if(is(dtm, "lasmetrics"))
    dtm = as.raster(dtm)

  if(!is(dtm, "RasterLayer"))
    stop("The terrain model is not a RasterLayer or a lasmetrics", call. = F)

  normalized = LAS(data.table::copy(.las@data), .las@header)
  lasclassify(normalized, dtm, "Zn")
  isna = is.na(normalized@data$Zn)
  #}

  if(sum(isna) > 0)
    warning(paste0(sum(isna), " points outside of the convex hull were removed."), call. = F)

  normalized@data[, Z := round(Z - Zn, 3)][, Zn := NULL][]
  normalized = lasfilter(normalized, !isna)

  return(normalized)
}
