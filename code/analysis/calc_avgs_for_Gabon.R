# Calculating average values for Gabon
library(chelsaDL)
library(rgeos)
library(rgdal)
library(raster)
library(tidyr)

# Load shapefile for Gabon
gabon <- readOGR("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/human/GAB_adm", "GAB_adm0")
crs(gabon) # check projection
ext <- extent(gabon)

# Build a list of files
GCMs <- c("CESM1-BGC", "MPI-ESM-MR", "MIROC5", "CMCC-CM", "CESM1-CAM5", "IPSL-CM5A-MR", "FIO-ESM", "inmcm4", "GISS-E2-H", "ACCESS1-0")
months <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12")

files <- ch_queries(variables = c("temp", "prec"),
                    models = GCMs, 
                    scenarios = c("rcp85"), 
                    timeframes = c("2061-2080", "1979–2013"), 
                    layers = 1:12) 

files$file <- basename(files$file)
files$file <- sub("\\*", 1, files$file)
files$histdir[files$variable=="temp"] <- "/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/climate/future/temp"
files$histdir[files$variable=="prec"] <- "/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/climate/future/prec"
files$histdir[files$timeframe=="1979–2013"] <- "/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/climate/recent/avg_crop"

for (m in months){
  files$file[files$timeframe=="1979–2013" & files$variable=="prec" & files$layer==as.numeric(m)] <- paste0("CHELSA_prec_", m, "_V1.2_land.tif")
  files$file[files$timeframe=="1979–2013" & files$variable=="temp" & files$layer==as.numeric(m)] <- paste0("CHELSA_temp10_", m, "_1979-2013_V1.2_land.tif")
}

files$path <- paste0(files$histdir, "/", files$file)
write.csv(files, "/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/climate/climate_file_structure.csv")

# Set up dataframe & calculate delta
delta_df <- files[files$timeframe=="2061-2080",]
delta_df$future_avg <- NA
delta_df$baseline_avg <- NA
delta_df$delta_avg <- NA

# Calculate average delta values of Gabon for each GCM
for (row in 1:240){
  future_ras <- raster(delta_df$path[row])
  future_ras <- future_ras/10
  baseline_ras <- raster(files$path[files$timeframe=="1979–2013" &
                                      files$variable==as.character(delta_df$variable[row]) &
                                      files$layer==delta_df$layer[row] &
                                      files$model==delta_df$model[row]
                                    ])
  baseline_ras <- baseline_ras/10
  delta <- future_ras - baseline_ras
  
  future_avg <- raster::extract(future_ras, gabon, fun=mean, na.rm=TRUE)[1]
  baseline_avg <- raster::extract(baseline_ras, gabon, fun=mean, na.rm=TRUE)[1]
  delta_avg <- future_avg - baseline_avg
  
  delta_df$future_avg[row] <- future_avg
  delta_df$baseline_avg[row] <- baseline_avg
  delta_df$delta_avg[row] <- delta_avg
  print(paste0(row, " out of ", 240))
}

write.csv(delta_df, "/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/delta_df.csv")

# Calculate z-scores and add to delta dataframe
delta_df <- read.csv("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/delta_df.csv", stringsAsFactors = FALSE)
z_files <- list.files("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/z_scores", full.names = TRUE, recursive = TRUE)

delta_df$zscore <- NA

for (row in 1:240){
  z_path <- z_files[grepl(delta_df$file[row], basename(z_files))]
  z <- raster(z_path)
  
  z_avg <- raster::extract(z, gabon, fun=mean, na.rm=TRUE)[1]
  delta_df$zscore[row] <- z_avg
  print(paste0(row, " out of ", 240))
}

delta_df$zscore <- round(delta_df$zscore, 2)
write.csv(delta_df, "/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/analysis/delta_df.csv", row.names = FALSE)
