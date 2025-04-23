# Read in total fires raster
total_fires_trimmed <- terra::rast(file.path("data", "EVER_BICY_1978_2023_total_fires.tif")) %>%
  terra::trim(padding = 50)

# Read in time since last fire raster
time_since_trimmed <- terra::rast(file.path("data", "EVER_BICY_1978_2023_time_since.tif")) %>%
  terra::trim(padding = 50)

terra::writeRaster(total_fires_trimmed, 
                   file.path("data", "EVER_BICY_1978_2023_total_fires_trimmed.tif"),
                   overwrite = T)

terra::writeRaster(time_since_trimmed, 
                   file.path("data", "EVER_BICY_1978_2023_time_since_trimmed.tif"),
                   overwrite = T)
# ------
library(sf)
library(tidyverse)
library(rmapshaper)
library(terra)

load("EVERGLADES_VEGETATION_L1_L2.RDATA")
rm(Everglades_veg_l1n)
EVG.L2 <- sf::st_as_sf(Everglades_veg_l2n)
EVG.L2_4326 <- EVG.L2 %>% st_transform('+proj=longlat +datum=WGS84')
st_write(EVG.L2_4326, "EVG.L2_4326.shp")

# EVG.L2_sim <- EVG.L2_4326 %>%
#   st_simplify(dTolerance = 0.0001, preserveTopology = TRUE)
# st_write(EVG.L2_sim, "EVG.L2_sim.shp")

EVG.L2_sim <- EVG.L2_4326 %>%
  rmapshaper::ms_simplify()

st_write(EVG.L2_sim, "EVG.L2_sim.shp")

EVG.L2_4326_v <- terra::vect(EVG.L2_4326)
EVG.L2_4326_r <- terra::rast(EVG.L2_4326_v)
