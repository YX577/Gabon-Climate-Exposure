## Z-score rasters
library(raster)
library(dplyr)

output.dir <- "/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/z_scores/"
std_files <- list.files("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/climate/recent/timeseries/std", full.names = TRUE)
files <- read.csv("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/climate/climate_file_structure.csv", stringsAsFactors = FALSE)

# for every climate model calculate the z-score (temp only)
files <- files[files$variable=="temp",]
delta_df <- files[files$timeframe=="2061-2080",]
delta_df$month <- paste0("0", as.character(delta_df$layer))
delta_df$month <- sub("010", "10", delta_df$month)
delta_df$month <- sub("011", "11", delta_df$month)
delta_df$month <- sub("012", "12", delta_df$month)

for (row in 1:120){
  name <- delta_df$file[row]
  future_ras <- raster(delta_df$path[row])
  future_ras <- future_ras/10
  baseline_ras <- raster(files$path[files$timeframe=="1979–2013" &
                                      files$variable==as.character(delta_df$variable[row]) &
                                      files$layer==delta_df$layer[row] &
                                      files$model==delta_df$model[row]
                                    ])
  baseline_ras <- baseline_ras/10
  delta <- future_ras - baseline_ras
  writeRaster(delta, paste0("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/deltas/temp/delta_", name), format="GTiff")
  
  m <- paste0("_",delta_df$month[row], "_")
  std <- raster(std_files[grepl(paste0("tmean", m), std_files)])
  zscore <- delta/std
  writeRaster(zscore, paste0(output.dir, "temp/zscore_", name), format="GTiff")
  
  print(paste0(row, " out of ", 120))
}

# Precipitation
# for every climate model calculate the z-score (precip only)
files <- read.csv("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/climate/climate_file_structure.csv", stringsAsFactors = FALSE)
files <- files[files$variable=="prec",]
delta_df <- files[files$timeframe=="2061-2080",]
delta_df$month <- paste0("0", as.character(delta_df$layer))
delta_df$month <- sub("010", "10", delta_df$month)
delta_df$month <- sub("011", "11", delta_df$month)
delta_df$month <- sub("012", "12", delta_df$month)

for (row in 1:120){
  name <- delta_df$file[row]
  future_ras <- raster(delta_df$path[row])
  future_ras <- future_ras/10
  baseline_ras <- raster(files$path[files$timeframe=="1979–2013" &
                                      files$variable==as.character(delta_df$variable[row]) &
                                      files$layer==delta_df$layer[row] &
                                      files$model==delta_df$model[row]
                                    ])
  baseline_ras <- baseline_ras/10
  delta <- future_ras - baseline_ras
  writeRaster(delta, paste0("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/deltas/prec/delta_", name), format="GTiff")
  
  m <- paste0("_",delta_df$month[row], "_")
  std <- raster(std_files[grepl(paste0("prec", m), std_files)])
  zscore <- delta/std
  writeRaster(zscore, paste0(output.dir, "prec/zscore_", name), format="GTiff")
  
  print(paste0(row, " out of ", 120))
}