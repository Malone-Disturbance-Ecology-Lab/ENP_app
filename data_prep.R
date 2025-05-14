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
library(leaflet)

# Read in total fires raster and trim empty edges to reduce size
total_fires_trimmed <- terra::rast(file.path("data_not_deployed", "EVER_BICY_1978_2023_total_fires.tif")) %>%
  terra::trim(padding = 50)

# Read in time since last fire raster and trim empty edges to reduce size
time_since_trimmed <- terra::rast(file.path("data_not_deployed", "EVER_BICY_1978_2023_time_since.tif")) %>%
  terra::trim(padding = 50)

# Reproject rasters to leaflet crs
total_fires_trim_3857 <- total_fires_trimmed %>%
  leaflet::projectRasterForLeaflet(method = "bilinear")

time_since_trim_3857 <- time_since_trimmed %>%
  leaflet::projectRasterForLeaflet(method = "bilinear")

# Create simplified versions of the rasters (due to large size)
total_fires <- terra::spatSample(total_fires_trim_3857, 100000, method = "regular", as.raster = TRUE)
time_since <- terra::spatSample(time_since_trim_3857, 100000, method = "regular", as.raster = TRUE)

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
load("data_not_deployed/EVERGLADES_VEGETATION_L1_L2.RDATA")
rm(Everglades_veg_l1n)

# Make it into an sf object
EVG.L2 <- sf::st_as_sf(Everglades_veg_l2n)

# Reproject
EVG.L2_4326 <- EVG.L2 %>% sf::st_transform("epsg:4326")

# Simplify the shapes to reduce size
EVG.L2_sim_4326 <- EVG.L2_4326 %>%
  rmapshaper::ms_simplify(keep = 0.02) %>% sf::st_make_valid()
# Export as shapefile
sf::st_write(EVG.L2_sim_4326, file.path("data", "EVG.L2_sim_4326.shp"))

# Reproject
EVG.L2_3857 <- EVG.L2 %>% sf::st_transform("epsg:3857")

# Simplify the shapes to reduce size
EVG.L2_sim_3857 <- EVG.L2_3857 %>%
  rmapshaper::ms_simplify(keep = 0.02) %>% sf::st_make_valid()
# Export as shapefile
sf::st_write(EVG.L2_sim_3857, file.path("data", "EVG.L2_sim_3857.shp"))

# Creating a column for area - area numbers are too large to export
# EVG.L2_4326 <- EVG.L2 %>% st_transform('epsg:4326') %>%
#   mutate(area = st_area(geometry))
# st_write(EVG.L2_4326, "EVG.L2_4326_area.shp")

# Another way to simplify shapes
# EVG.L2_sim <- EVG.L2_4326 %>%
#   st_simplify(dTolerance = 0.0001, preserveTopology = TRUE)
# st_write(EVG.L2_sim, "EVG.L2_sim.shp")

pal3 <- colorFactor(palette = c("#4E79A7FF", "#A0CBE8FF", "#F28E2BFF",
                                "#FFBE7DFF", "#59A14FFF", "#8CD17DFF",
                                "#B6992DFF", "#F1CE63FF","#499894FF"),
                   domain = EVG.L2_sim$L2.new)
leaflet() %>%
  # Add Leaflet-provided gray background map
  leaflet::addProviderTiles(providers$CartoDB.Positron, group = "Gray background") %>%
  addPolygons(group = "test", data = EVG.L2_sim, color = ~pal3(L2.new), weight= 0.2,
              fillColor = ~pal3(L2.new), fillOpacity = .7)
