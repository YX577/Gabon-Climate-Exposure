# This script downloads time-series data from CHELSA for Gabon

library(rgeos)
library(rgdal)
library(raster)

gabon <- readOGR("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/human/GAB_adm", "GAB_adm0")
crs(gabon) # check projection
ext <- extent(gabon)

base_url <- "https://envidatrepo.wsl.ch/uploads/chelsa/chelsa_V1/timeseries/"

output_dir <- "/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/climate/recent/timeseries/"

variables <- c("tmean", "prec") 
years <- 1979:2013
months <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12")

for (variable in variables){
  for (year in years){
    for (month in months){
      
      # format url and output path name
      clim_url <- paste0(base_url, variable,"/", "CHELSA_", variable, "_", year, "_", month, "_V1.2.1.tif")
      output_name <- paste0(output_dir, variable, "/", basename(clim_url))
      
      # If file exists skip process
      if(file.exists(output_name)) {
        next
      }
      
      # Download file - if there is an error print message and continue
      tryCatch({
        download.file(clim_url, destfile = output_name, method = "curl", quiet = TRUE)
        
        # clip to gabon and re-write raster
        clim_ras <- raster(output_name)
        crop_ras <- crop(clim_ras, gabon)
        writeRaster(crop_ras, filename = output_name, format="GTiff", overwrite=TRUE)
        
      }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
      
      print(paste0(variable, "-", year, "-", month))
      
    }
  }
}
  

