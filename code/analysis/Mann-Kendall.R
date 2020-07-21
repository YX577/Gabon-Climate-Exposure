# Mann-Kendall trend test

library(raster)
library(spatialEco)
library(stringr)
library(rgeos)
library(rgdal)
library(Kendall)
library(ggplot2)

library(rasterVis)
library(RColorBrewer)
library(ggthemes)


fun_kendall=function(x){ return(unlist(MannKendall(x)))}
ras_kendall <- function(x){return(unlist(raster.kendall(x)))}

# Load shapefile for Gabon
gabon <- readOGR("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/human/GAB_adm", "GAB_adm0")
crs(gabon) # check projection

files <- list.files("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/climate/recent/timeseries/prec/", full.names = TRUE)
precip_file_df <- data.frame(month=NA, path=files)

for(row in 1:420){
  precip_file_df$month[row] <- substr(basename(files)[row], 18, 19)
}

files <- list.files("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/climate/recent/timeseries/tmean_c", full.names = TRUE)
temp_file_df <- data.frame(month=NA, path=files)
for(row in 1:420){
  temp_file_df$month[row] <- substr(basename(files)[row], 19, 20)
}


# stack rasters
for (m in unique(precip_file_df$month)){
  s <- as.character(precip_file_df$path[precip_file_df$month==m])
  precip <- stack(s)
  trend  <- calc(precip, fun_kendall)
  trend <- mask(trend, gabon)
  names(trend) <- c("tau", "sl", "s", "D", "variance")
  writeRaster(trend, filename=paste0("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/mann_kendall/precip_", m), format="GTiff")
}

for (m in unique(temp_file_df$month)){
  s <- as.character(temp_file_df$path[temp_file_df$month==m])
  temp <- stack(s)
  trend  <- calc(temp, fun_kendall)
  trend <- mask(trend, gabon)
  names(trend) <- c("tau", "sl", "s", "D", "variance")
  writeRaster(trend, filename=paste0("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/mann_kendall/temp_", m), format="GTiff")
}

# Map Monotonic trends for annual rainfall (mm year-1) for 1979–2013 period 
# and zones with significant (p<0.1) increase or decrease in rainfall

# stack months
precip_trends <- list.files("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/mann_kendall", 
                            pattern = "precip", full.names = TRUE)

precip_trends <- stack(precip_trends, bands=2)
names(precip_trends) <- c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")

# Calculate temperature trends
temp_trends <- list.files("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/mann_kendall", 
                            pattern = "temp", full.names = TRUE)
temp_trends <- stack(temp_trends, bands=2)
names(temp_trends) <- c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")

# mask out insignificant values where p>0.1
temp_trends[temp_trends > .01] <- NA
temp_trends[temp_trends < .01] <- 1
names(temp_trends) <- c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")
plt <- rasterVis::levelplot(temp_trends , pretty=T)
plt + latticeExtra::layer(sp.lines(gabon, col="black", lwd=0.5)) 

# Calculate Precipitation trends
precip_trends[precip_trends > .01] <- NA
precip_trends[precip_trends < .01] <- 1
names(precip_trends) <- c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")
plt <- rasterVis::levelplot(precip_trends , pretty=T)
plt + latticeExtra::layer(sp.lines(gabon, col="black", lwd=0.5)) 

pngfile <- "precip_monthly_trend.png"
png(pngfile, width=729, height=729) # open the file

cutpts <- c(-50,-40,-30,-20,-10,0,10,20,30,40,50)
plt <- rasterVis::levelplot(temp_trends , at=cutpts, cuts=11, pretty=T, 
                 col.regions=(rev(brewer.pal(10,"RdBu"))))
plt + latticeExtra::layer(sp.lines(gabon, col="black", lwd=0.5))  

cutpts <- c(-300,-200,-100,0,100,200,300)
plt <- rasterVis::levelplot(precip_trends , at=cutpts, cuts=7, pretty=T, 
                            col.regions=(rev(brewer.pal(7,"BrBG"))))
plt + latticeExtra::layer(sp.lines(gabon, col="black", lwd=0.5))
ggsave("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/Visualization/charts/kendall_precip.png", plt, width=6, height=5, units="in", dpi = 300)
