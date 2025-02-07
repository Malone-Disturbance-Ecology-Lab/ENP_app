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
