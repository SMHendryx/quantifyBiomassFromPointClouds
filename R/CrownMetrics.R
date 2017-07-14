#'LiDAR-derived individual tree crown metrics
#'
#'@description Compute individual tree crown metrics from lidar data
#'
#'@usage CrownMetrics(xyziId)
#'
#'@param xyziId A 5-column matrix with the x, y, z coordinates, intensity and the tree id classification for the LiDAR point cloud.
#'@return Returns A matrix of the LiDAR-based metrics for the individual tree detected.
# Forked from: 
#'@author Carlos Alberto Silva
# Edited by Sean M. Hendryx
#'@details
#' 
#'# List of the individual tree crown metrics:
#'\itemize{ 
#'\item TotalReturns: Total number of returns   
#'\item ETOP - UTM Easting coordinate of the tree top
#'\item NTOP - UTM Northing coordinate of the tree top
#'\item EMIN - Minimum UTM Easting coordinate
#'\item NMIN - Minimum UTM Northing coordinate
#'\item EMAX - Maximum UTM Easting coordinate
#'\item NMAX - Maxmium UTM Northing coordinate
#'\item EWIDTH - Tree crown width 01
#'\item NWIDTH - Tree crown width 02
#'\item HMAX - Maximum Height
#'\item HMEAN - Mean height
#'\item HSD - Standard deviation of height
#'\item HCV - Coefficient of variation of height
#'\item HMOD - Mode of height
#'\item H5TH - 5th percentile of height
#'\item H10TH - 10th percentile of height
#'\item H20TH - 20th percentile of height
#'\item H25TH - 25th percentile of height
#'\item H30TH - 30th percentile of height
#'\item H40TH - 40th percentile of height
#'\item H50TH - 50th percentile of height
#'\item H60TH - 60th percentile of height
#'\item H70TH - 70th percentile of height
#'\item H75TH - 75th percentile of height
#'\item H80TH - 80th percentile of height
#'\item H90TH - 90th percentile of height
#'\item H95TH - 95th percentile of height
#'\item H99TH - 99th percentile of height
#'\item IMAX - Maximum intensity
#'\item IMEAN - Mean intensity
#'\item ISD - Standard deviation of intensity
#'\item ICV - Coefficient of variation of intensity
#'\item IMOD - Mode of intensity
#'\item I5TH - 5th percentile of intensity
#'\item I10TH - 10th percentile of intensity
#'\item I20TH - 20th percentile of intensity
#'\item I25TH - 25th percentile of intensity
#'\item I30TH - 30th percentile of intensity
#'\item I40TH - 40th percentile of intensity
#'\item I50TH - 50th percentile of intensity
#'\item I60TH - 60th percentile of intensity
#'\item I70TH - 70th percentile of intensity
#'\item I75TH - 75th percentile of intensity
#'\item I80TH - 80th percentile of intensity
#'\item I90TH - 90th percentile of intensity
#'\item I95TH - 95th percentile of intensity
#'\item I99TH - 99th percentile of intensity
#'}
#'
#'@examples
#'
#'#=======================================================================#
#'# Individual tree detection using K-means cluster
#'#=======================================================================#
#'# Importing LAS file:
#'LASfile <- system.file("extdata", "LASexample1.las", package="rLiDAR")
#'
#'# Reading LAS file
#'LAS<-readLAS(LASfile,short=TRUE)
#'
#'# Setting the xyz coordinates and subsetting the data
#'xyzi<-subset(LAS[,1:4],LAS[,3] >= 1.37)
#'
#'# Finding clusters (trees)
#'clLAS<-kmeans(xyzi[,1:2], 32)
#'
#'# Set the tree id vector
#'Id<-as.factor(clLAS$cluster)
#'
#'# Combining xyzi and tree id 
#'xyziId<-cbind(xyzi,Id)
#'
#'#=======================================================================#
#'#  Computing individual tree LiDAR metrics 
#'#=======================================================================#
#'
#'TreesMetrics<-CrownMetrics(xyziId)
#'head(TreesMetrics)
#'@importFrom stats median na.omit quantile sd var
#'@export
CrownMetrics<-function(xyziId, na_rm = FALSE, digits = 5) {  
  
  # ----from moments package: Lukasz Komsta et al.(2015) ---#
  "skewness" <-
    function (x, na.rm = na_rm) 
    {
      if (is.matrix(x)) 
        apply(x, 2, skewness, na.rm = na.rm)
      else if (is.vector(x)) {
        if (na.rm) x <- x[!is.na(x)] 
        n <- length(x)
        (sum((x-mean(x))^3)/n)/(sum((x-mean(x))^2)/n)^(3/2)
      }
      else if (is.data.frame(x)) 
        sapply(x, skewness, na.rm = na.rm)
      else skewness(as.vector(x), na.rm = na.rm)
    }
  
  "kurtosis" <-
    function (x, na.rm = na_rm) 
    {
      if (is.matrix(x)) 
        apply(x, 2, kurtosis, na.rm = na.rm)
      else if (is.vector(x)) {
        if (na.rm) x <- x[!is.na(x)] 
        n <- length(x)
        n*sum( (x-mean(x))^4 )/(sum( (x-mean(x))^2 )^2)
      }
      else if (is.data.frame(x)) 
        sapply(x, kurtosis, na.rm = na.rm)
      else kurtosis(as.vector(x), na.rm = na.rm)
    }
  #-----------------------------------------------------------#
  MetricsList<-matrix(ncol=68)[-1,]
  nlevels<-as.numeric(levels(factor(xyziId[,5])))
  
  for ( i in nlevels){
    #print(i)
    cat (".");utils::flush.console()
    
    xyz.c<-subset(xyziId[,1:4],xyziId[,5]==i)
    
    if (nrow(xyz.c) <= 1) { 
      xRange<-round(range(xyz.c[,1]), digits = digits)
      yRange<-round(range(xyz.c[,2]), digits = digits)
      MaxZ<-max(xyz.c[,3])  # fild the max point
      XY<-as.data.frame(subset(xyz.c,xyz.c[,3]==MaxZ)) # get the x and y from the max point
      maxPoint<-round(XY[1,1:2],digits = digits)
      
      Metrics<-c(
        npoits<-round(nrow(xyz.c), digits = digits),
        maxPoint,
        xRangeMin<-xRange[1],
        xRangeMax<-xRange[2],
        yRangeMin<-yRange[1],
        yRangeMax<-yRange[2],
        xWidth<-round(xRangeMax-xRangeMin,digits = digits),
        yWidth<-round(yRangeMax-yRangeMin,digits = digits),
        rep(0,61))
      MetricsList<-rbind(MetricsList,c(i,Metrics))
    } else {
      
      MaxZ<-max(xyz.c[,3])  # fild the max point
      XY<-as.data.frame(subset(xyz.c,xyz.c[,3]==MaxZ)) # get the x and y from the max point
      maxPoint<-round(XY[1,1:2],digits = digits)
      xRange<-round(range(xyz.c[,1]), digits = digits)
      yRange<-round(range(xyz.c[,2]), digits = digits)
      
      Metrics<-c( 
        
        # Number of points
        npoits<-round(nrow(xyz.c), digits = digits),
        maxPoint,
        # Range UTM E,N
        xRangeMin<-xRange[1],
        xRangeMax<-xRange[2],
        yRangeMin<-yRange[1],
        yRangeMax<-yRange[2],
        xWidth<-round(xRangeMax-xRangeMin,digits = digits),
        yWidth<-round(yRangeMax-yRangeMin,digits = digits),
        
        # hieght metrics
        hmax=round(max(xyz.c[,3]), digits = digits),
        hmin=round(min(xyz.c[,3]), digits = digits),
        hmean=round(mean(xyz.c[,3]),digits = digits),
        hmedian=round(median(xyz.c[,3]),digits = digits),
        hmode = round(as.numeric(names(table(xyz.c[,3]))[which.max(table(xyz.c[,3]))]), digits = digits),
        hvar=round(var(xyz.c[,3]),digits = digits),
        hsd=round(sd(xyz.c[,3]),digits = digits),
        hcv=round((sd(xyz.c[,3])/mean(xyz.c[,3]))*100,digits = digits),
        hkurtosis=round(kurtosis(xyz.c[,3]),digits = digits),
        hskewness=round(skewness(xyz.c[,3]),digits = digits),
        h5=round(quantile(xyz.c[,3],0.05, na.rm = na_rm),digits = digits),
        h10=round(quantile(xyz.c[,3],0.1, na.rm = na_rm),digits = digits),
        h15=round(quantile(xyz.c[,3],0.15, na.rm = na_rm),digits = digits),
        h20=round(quantile(xyz.c[,3],0.20, na.rm = na_rm),digits = digits),
        h25=round(quantile(xyz.c[,3],0.25, na.rm = na_rm),digits = digits),
        h30=round(quantile(xyz.c[,3],0.30, na.rm = na_rm),digits = digits),
        h35=round(quantile(xyz.c[,3],0.35, na.rm = na_rm),digits = digits),
        h40=round(quantile(xyz.c[,3],0.40, na.rm = na_rm),digits = digits),
        h45=round(quantile(xyz.c[,3],0.45, na.rm = na_rm),digits = digits),
        h50=round(quantile(xyz.c[,3],0.50, na.rm = na_rm),digits = digits),
        h55=round(quantile(xyz.c[,3],0.55, na.rm = na_rm),digits = digits),
        h60=round(quantile(xyz.c[,3],0.60, na.rm = na_rm),digits = digits),
        h65=round(quantile(xyz.c[,3],0.65, na.rm = na_rm),digits = digits),
        h70=round(quantile(xyz.c[,3],0.70, na.rm = na_rm),digits = digits),
        h75=round(quantile(xyz.c[,3],0.75, na.rm = na_rm),digits = digits),
        h80=round(quantile(xyz.c[,3],0.85, na.rm = na_rm),digits = digits),
        h90=round(quantile(xyz.c[,3],0.90, na.rm = na_rm),digits = digits),
        h95=round(quantile(xyz.c[,3],0.95, na.rm = na_rm),digits = digits),
        h99=round(quantile(xyz.c[,3],0.99, na.rm = na_rm),digits = digits),
        imax=round(max(xyz.c[,4], na.rm = na_rm), digits = digits),
        imin=round(min(xyz.c[,4], na.rm = na_rm), digits = digits),
        imean=round(mean(xyz.c[,4], na.rm = na_rm),digits = digits),
        imedian=round(median(xyz.c[,4], na.rm = na_rm),digits = digits),
        # from which.max docs: "Missing and ‘NaN’ values are discarded.":
        imode = round(as.numeric(names(table(xyz.c[,4]))[which.max(table(xyz.c[,4]))]), digits = digits),
        ivar=round(var(xyz.c[,4], na.rm = na_rm),digits = digits),
        isd=round(sd(xyz.c[,4], na.rm = na_rm),digits = digits),
        icv=round((sd(xyz.c[,4], na.rm = na_rm)/mean(xyz.c[,4], na.rm = na_rm))*100,digits = digits),
        ikurtosis=round(kurtosis(xyz.c[,4], na.rm = na_rm),digits = digits),
        iskewness=round(skewness(xyz.c[,4], na.rm = na_rm),digits = digits),
        i5=round(quantile(xyz.c[,4],0.05, na.rm = na_rm),digits = digits),
        i10=round(quantile(xyz.c[,4],0.1, na.rm = na_rm),digits = digits),
        i15=round(quantile(xyz.c[,4],0.15, na.rm = na_rm),digits = digits),
        i20=round(quantile(xyz.c[,4],0.20, na.rm = na_rm),digits = digits),
        i25=round(quantile(xyz.c[,4],0.25, na.rm = na_rm),digits = digits),
        i30=round(quantile(xyz.c[,4],0.30, na.rm = na_rm),digits = digits),
        i35=round(quantile(xyz.c[,4],0.35, na.rm = na_rm),digits = digits),
        i40=round(quantile(xyz.c[,4],0.40, na.rm = na_rm),digits = digits),
        i45=round(quantile(xyz.c[,4],0.45, na.rm = na_rm),digits = digits),
        i50=round(quantile(xyz.c[,4],0.50, na.rm = na_rm),digits = digits),
        i55=round(quantile(xyz.c[,4],0.55, na.rm = na_rm),digits = digits),
        i60=round(quantile(xyz.c[,4],0.60, na.rm = na_rm),digits = digits),
        i65=round(quantile(xyz.c[,4],0.65, na.rm = na_rm),digits = digits),
        i70=round(quantile(xyz.c[,4],0.70, na.rm = na_rm),digits = digits),
        i75=round(quantile(xyz.c[,4],0.75, na.rm = na_rm),digits = digits),
        i80=round(quantile(xyz.c[,4],0.85, na.rm = na_rm),digits = digits),
        i90=round(quantile(xyz.c[,4],0.90, na.rm = na_rm),digits = digits),
        i95=round(quantile(xyz.c[,4],0.95, na.rm = na_rm),digits = digits),
        i99=round(quantile(xyz.c[,4],0.99, na.rm = na_rm),digits = digits))
      
      MetricsList<-rbind(MetricsList,c(i,Metrics))
    }
  }
  
  colnames(MetricsList)<-c("Tree","TotalReturns","ETOP","NTOP","EMIN","NMIN","EMAX","NMAX","EWIDTH","NWIDTH","HMAX","HMIN","HMEAN","HMEDIAN","HMODE",
                           "HVAR","HSD","HCV","HKUR","HSKE","H05TH","H10TH","H15TH","H20TH","H25TH","H30TH","H35TH","H40TH",
                           "H45TH","H50TH","H55TH","H60TH","H65TH","H70TH","H75TH","H80TH","H90TH","H95TH","H99TH","IMAX","IMIN","IMEAN","IMEDIAN","IMODE",
                           "IVAR","ISD","ICV","IKUR","ISKE","I05TH","I10TH","I15TH","I20TH","I25TH","I30TH","I35TH","I40TH",
                           "I45TH","I50TH","I55TH","I60TH","I65TH","I70TH","I75TH","I80TH","I90TH","I95TH","I99TH")
  return(data.frame(MetricsList))
}