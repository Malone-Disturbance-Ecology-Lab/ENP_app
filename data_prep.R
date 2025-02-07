# Read in invading model raster
total_fires_trimmed <- terra::rast("EVER_BICY_1978_2023_total_fires.tif") %>%
  terra::trim(padding = 50)

# Read in established model raster
time_since_trimmed <- terra::rast("EVER_BICY_1978_2023_time_since.tif") %>%
  terra::trim(padding = 50)


terra::writeRaster(total_fires_trimmed, 
                   "EVER_BICY_1978_2023_total_fires_trimmed.tif",
                   overwrite = T)

terra::writeRaster(time_since_trimmed, 
                   "EVER_BICY_1978_2023_time_since_trimmed.tif",
                   overwrite = T)
