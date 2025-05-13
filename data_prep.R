## --------------------------------------------- ##
#           Data prepping for ENP app
## --------------------------------------------- ##
# Script author(s): Angel Chen

# Purpose:
## This script creates simplified versions of the ENP rasters and vegetation shapefile in order to reduce their size

## --------------------------------------------- ##
#         Creating simplified rasters -----
## --------------------------------------------- ##
library(sf)
library(tidyverse)
library(terra)
library(rmapshaper)

# Read in total fires raster and trim empty edges to reduce size
total_fires_trimmed <- terra::rast(file.path("data", "EVER_BICY_1978_2023_total_fires.tif")) %>%
  terra::trim(padding = 50)

# Read in time since last fire raster and trim empty edges to reduce size
time_since_trimmed <- terra::rast(file.path("data", "EVER_BICY_1978_2023_time_since.tif")) %>%
  terra::trim(padding = 50)

# Export
terra::writeRaster(total_fires_trimmed, 
                   file.path("data", "EVER_BICY_1978_2023_total_fires_trimmed.tif"),
                   overwrite = T)

terra::writeRaster(time_since_trimmed, 
                   file.path("data", "EVER_BICY_1978_2023_time_since_trimmed.tif"),
                   overwrite = T)

# Reproject rasters (to do calculations with later)
total_fires_trim_4326 <- total_fires_trimmed %>%
  terra::project("epsg:4326")
time_since_trim_4326 <- time_since_trimmed %>%
  terra::project("epsg:4326")

# Export
terra::writeRaster(total_fires_trim_4326, 
                   file.path("data", "EVER_BICY_1978_2023_total_fires_trim_4326.tif"),
                   overwrite = T)

terra::writeRaster(time_since_trim_4326, 
                   file.path("data", "EVER_BICY_1978_2023_time_since_trim_4326.tif"),
                   overwrite = T)

# Create simplified versions of the rasters (due to large size)
total_fires <- terra::spatSample(total_fires_trimmed, 2000000, method = "regular", as.raster = TRUE)
time_since <- terra::spatSample(time_since_trimmed, 2000000, method = "regular", as.raster = TRUE)

# Export
terra::writeRaster(total_fires, 
                   file.path("data", "EVER_BICY_1978_2023_total_fires_trim_simp.tif"),
                   overwrite = T)

terra::writeRaster(time_since, 
                   file.path("data", "EVER_BICY_1978_2023_time_since_trim_simp.tif"),
                   overwrite = T)
## --------------------------------------------- ##
#        Creating simplified shapefile -----
## --------------------------------------------- ##
# Load vegetation data
load("data/EVERGLADES_VEGETATION_L1_L2.RDATA")
rm(Everglades_veg_l1n)

# Make it into an sf object
EVG.L2 <- sf::st_as_sf(Everglades_veg_l2n)
# Reproject
EVG.L2_4326 <- EVG.L2 %>% sf::st_transform("epsg:4326")
# Export as shapefile
sf::st_write(EVG.L2_4326, "EVG.L2_4326.shp")

# Simplify the shapes to reduce size
EVG.L2_sim <- EVG.L2_4326 %>%
  rmapshaper::ms_simplify(keep = 0.03)
# Export as shapefile
sf::st_write(EVG.L2_sim, "EVG.L2_sim.shp")

# Creating a column for area - area numbers are too large to export
# EVG.L2_4326 <- EVG.L2 %>% st_transform('epsg:4326') %>%
#   mutate(area = st_area(geometry))
# st_write(EVG.L2_4326, "EVG.L2_4326_area.shp")

# Another way to simplify shapes
# EVG.L2_sim <- EVG.L2_4326 %>%
#   st_simplify(dTolerance = 0.0001, preserveTopology = TRUE)
# st_write(EVG.L2_sim, "EVG.L2_sim.shp")
