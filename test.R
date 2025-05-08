librarian::shelf(leaflet,
                 htmltools, ggplot2,
                 plotly,
                 quiet = T)

pal <- colorFactor(palette = c("#4E79A7FF", "#A0CBE8FF", "#F28E2BFF", "#FFBE7DFF", "#59A14FFF", "#8CD17DFF", "#B6992DFF", "#F1CE63FF","#499894FF"),
                   domain = test$L2.new)

leaflet() %>%
  # Add Leaflet-provided gray background map
  leaflet::addProviderTiles(providers$CartoDB.Positron, group = "Gray background") %>%
  addPolygons(group = "test", data = test, color = ~pal(L2_new), weight= 0.2,
              fillColor = ~pal(L2_new), fillOpacity = .7)


# ------------------------------------------------
library(sf)
library(tidyverse)
library(terra)
# Read in vegetation shapefile
veg_orig <- terra::vect(file.path("data", "EVG.L2_4326.shp"))
e <- terra::ext(veg_orig)
p <- terra::as.polygons(e, crs = "epsg:4326")

#plot(p, reset=F)
#plot(veg_orig, add=T)

int <- terra::intersect(veg_orig, p)

int_area <- terra::expanse(int)

# ----------------------------------------------

mean_values <- terra::extract(total_fires_orig_4326, int, mean, na.rm=T, ID = FALSE) %>%
  dplyr::rename(mean_fires = sum)
mean_values2 <- terra::extract(time_since_orig_4326, int, min, na.rm=T, ID = T)
