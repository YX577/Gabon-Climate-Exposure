## This script downloads future climate data from CHELSA for the region of Gabon

#library(devtools)
#install_github("matthewkling/chelsaDL")
library(chelsaDL)
library(rgeos)
library(rgdal)
library(raster)
library(stringr)

# Load shapefile for Gabon
gabon <- readOGR("/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/GAB_adm", "GAB_adm0")
crs(gabon) # check projection
ext <- extent(gabon)

# Build a list of files to download
GCMs <- c("CESM1-BGC", "MPI-ESM-MR", "MIROC5", "CMCC-CM", "CESM1-CAM5", "IPSL-CM5A-MR", "FIO-ESM", "inmcm4", "GISS-E2-H", "ACCESS1-0")

files <- ch_queries(variables = c("temp", "prec"),
                    models = GCMs, 
                    scenarios = c("rcp85"), 
                    timeframes = c("2061-2080"), 
                    layers = 1:12) 

# For every row in files download data and crop to gabon and save to data directory
data_dir <- "/Users/AuerPower/Dropbox/Research Projects/Gabon_Climate/data/climate/future/temp/"

ch_dl(files, dest = data_dir, skip_existing = TRUE, crop = ext)
