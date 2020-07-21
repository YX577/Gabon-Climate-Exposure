# Convert values to Celcius Calculate STD for time-series
library(ecoclim)
library(raster)
library(dplyr)

# Function to convert K to C
kelvin_to_celsius <- function(ras, digits){
  ras <- ras/10
  c <- ras - 273.15
  c <- round(c, digits)
  return(c)
}

output.dir <- "/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/climate/recent/timeseries/"
files <- list.files("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/climate/recent/timeseries/tmean", full.names = TRUE)

# convert to celcius and save
for(f in files){
  ras <- raster(f)
  celsius  <- kelvin_to_celsius(ras, 2)
  writeRaster(celsius, paste0(output.dir,"tmean_c/", basename(f)), overwrite=TRUE)
}


files <- list.files(c("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/climate/recent/timeseries/tmean_c", 
                      "/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/climate/recent/timeseries/prec") , full.names = TRUE)
months <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12")
variables <- c("tmean", "prec")

for (v in variables){
  for (m in months){
    m_char <- paste0("_", m, "_")
    name <- paste0(output.dir, "std/", "sd_", v, m_char, "1979_2013.tif")
    
    if(file.exists(name)) {
      next
    }
    
    files_subset <- files[grepl(v, basename(files))]
    m_series <- files_subset[grepl(m_char, basename(files_subset))]
    m_rasters <- stack(m_series)
    std <- calc(m_rasters, sd)
    writeRaster(std, name, format="GTiff", overwrite=TRUE)
  }
}


