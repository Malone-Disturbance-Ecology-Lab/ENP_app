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

# -------------------------
library(rmapshaper)
library(sf)

# With a simple geojson object
poly <- structure('{
 "type": "Feature",
 "properties": {},
 "geometry": {
   "type": "Polygon",
   "coordinates": [[
     [-70.603637, -33.399918],
     [-70.614624, -33.395332],
     [-70.639343, -33.392466],
     [-70.659942, -33.394759],
     [-70.683975, -33.404504],
     [-70.697021, -33.419406],
     [-70.701141, -33.434306],
     [-70.700454, -33.446339],
     [-70.694274, -33.458369],
     [-70.682601, -33.465816],
     [-70.668869, -33.472117],
     [-70.646209, -33.473835],
     [-70.624923, -33.472117],
     [-70.609817, -33.468107],
     [-70.595397, -33.458369],
     [-70.587158, -33.442901],
     [-70.587158, -33.426283],
     [-70.590591, -33.414248],
     [-70.594711, -33.406224],
     [-70.603637, -33.399918]
   ]]
 }
}', class = c("geojson", "json"))

ms_simplify(poly, keep = 0.1)

# With an sf object

poly_sf <- geojsonsf::geojson_sf(poly)
poly_sf_sim1 <- ms_simplify(poly_sf, keep = 0.5)
poly_sf_sim2 <- ms_simplify(poly_sf, keep = 0.1)

# -------------------
library(sf)
library(leaflet)
# Load vegetation data
load("data/EVERGLADES_VEGETATION_L1_L2.RDATA")
rm(Everglades_veg_l1n)

# Make it into an sf object
EVG.L2 <- sf::st_as_sf(Everglades_veg_l2n)
# Reproject
EVG.L2_4326 <- EVG.L2 %>% sf::st_transform("epsg:4326")

# Simplify the shapes to reduce size
EVG.L2_sim <- EVG.L2_4326 %>%
  rmapshaper::ms_simplify(keep = 0.03)

pal3 <- colorFactor(palette = c("#4E79A7FF", "#A0CBE8FF", "#F28E2BFF",
                                "#FFBE7DFF", "#59A14FFF", "#8CD17DFF",
                                "#B6992DFF", "#F1CE63FF","#499894FF"),
                    domain = EVG.L2_sim$L2.new)

leaflet() %>%
  # Add Leaflet-provided gray background map
  leaflet::addProviderTiles(providers$CartoDB.Positron, group = "Gray background") %>%
  addPolygons(group = "test", data = EVG.L2_sim, color = ~pal3(L2.new), weight= 0.2,
              fillColor = ~pal3(L2.new), fillOpacity = .7)

sf::st_write(EVG.L2_sim, "EVG.L2_sim_TEST.shp")

# -----------
library(tidyverse)

# Read in summary calculations
summary_calculations <- read_csv(file.path("data", "summary_calculations.csv")) 

summary_calculations.ma <- summary_calculations %>% 
  mutate(ma.total_area_burned = zoo::rollmean(total_area_burned, 5, fill = NA),
         ma.total_WF_burned = zoo::rollmean(total_WF_burned, 5, fill = NA),
         ma.total_RX_burned = zoo::rollmean(total_RX_burned, 5, fill = NA),
         ma.mean_fire_size = zoo::rollmean(mean_fire_size, 5, fill = NA),
         ma.mean_area_over_perim = zoo::rollmean(mean_area_over_perim, 5, fill = NA)) 


p.total.area <- ggplot(summary_calculations.ma) + 
  geom_col(aes(
    x = Year, 
    y = total_area_burned/1000000, 
    text = paste("Area burned:", scales::comma(total_area_burned/1000000), "km<sup>2</sup>"))) + 
  geom_line(aes(
    x = Year, 
    y = ma.total_area_burned/1000000, 
    group = 1, 
    text = paste("Rolling mean:", scales::comma(ma.total_area_burned/1000000), "km<sup>2</sup>")), 
    col = "goldenrod",
    linewidth = 1) +
  theme_bw() + 
  ylab('Total Area Burned (km<sup>2</sup>)') + xlab('')

p.total.area %>% plotly::ggplotly(tooltip = c("x", "text"))

p.total.area.WF <- ggplot(summary_calculations.ma) + 
  geom_col(aes(
    x = Year, 
    y = total_WF_burned/1000000,
    text = paste("Area burned:", scales::comma(total_WF_burned/1000000), "km<sup>2</sup>"))) + 
  geom_line(aes(
    x = Year, 
    y = ma.total_WF_burned/1000000,
    group = 1, 
    text = paste("Rolling mean:", scales::comma(ma.total_WF_burned/1000000), "km<sup>2</sup>")), 
    col = "goldenrod", 
    linewidth = 1) + 
  theme_bw() + 
  ylab('Wildfire Area Burned (km<sup>2</sup>)') + xlab('')

p.total.area.WF %>% plotly::ggplotly(tooltip = c("x", "text"))

p.total.area.RX <- ggplot(summary_calculations.ma) + 
  geom_col(aes(
    x = Year, 
    y = total_RX_burned/1000000,
    text = paste("Area burned:", scales::comma(total_RX_burned/1000000), "km<sup>2</sup>"))) + 
  geom_line(aes(
    x = Year, 
    y = ma.total_RX_burned/1000000,
    group = 1, 
    text = paste("Rolling mean:", scales::comma(ma.total_RX_burned/1000000), "km<sup>2</sup>")), 
    col = "goldenrod", 
    linewidth = 1) + 
  theme_bw() + 
  ylab('Prescribed Area Burned (km<sup>2</sup>)') + xlab('')

p.total.area.RX %>% plotly::ggplotly(tooltip = c("x", "text"))

p.mean_fire_size <- ggplot(summary_calculations.ma) + 
  geom_col(aes(
    x = Year, 
    y = mean_fire_size/1000000,
    text = paste("Area burned:", scales::comma(mean_fire_size/1000000), "km<sup>2</sup>"))) + 
  geom_line(aes(
    x = Year, 
    y = ma.mean_fire_size/1000000,
    group = 1, 
    text = paste("Rolling mean:", scales::comma(ma.mean_fire_size/1000000), "km<sup>2</sup>")), 
    col = "goldenrod", 
    linewidth = 1) + 
  theme_bw() + 
  ylab('Mean Fire Size (km<sup>2</sup>)') + xlab('')

p.mean_fire_size %>% plotly::ggplotly(tooltip = c("x", "text"))

p.mean_area_over_perim <- ggplot(summary_calculations.ma) + 
  geom_col(aes(
    x = Year, 
    y = mean_area_over_perim,
    text = paste("Area burned:", scales::comma(mean_area_over_perim)))) + 
  geom_line(aes(
    x = Year, 
    y = ma.mean_area_over_perim,
    group = 1, 
    text = paste("Rolling mean:", scales::comma(ma.mean_area_over_perim))), 
    col = "goldenrod", 
    linewidth = 1) + 
  theme_bw() + 
  ylab('Mean Fire Area/Perimeter') + xlab('')

p.mean_area_over_perim %>% plotly::ggplotly(tooltip = c("x", "text"))

# ----------------
library(dplyr)
library(leaflet)
library(terra)
library(raster)
library(leafem)
library(htmltools)
library(plotly)
# Read in simplified versions of the rasters (due to large size)
total_fires <- terra::rast(file.path("data", "EVER_BICY_1978_2023_total_fires_trim_simp.tif")) 
time_since <- terra::rast(file.path("data", "EVER_BICY_1978_2023_time_since_trim_simp.tif"))

# Read in vegetation shapefile and its simplified version
#veg_orig <- terra::vect(file.path("data", "EVG.L2_4326.shp"))
veg <- terra::vect(file.path("data", "EVG.L2_sim_4326.shp"))

pal1 <- leaflet::colorNumeric(
  palette = "magma",
  domain = terra::values(total_fires),
  na.color = "transparent",
  reverse = T
)

pal2 <- leaflet::colorNumeric(
  palette = "viridis",
  domain = terra::values(time_since),
  na.color = "transparent"
)

pal3 <- colorFactor(palette = c("#4E79A7FF", "#A0CBE8FF", "#F28E2BFF",
                                "#FFBE7DFF", "#59A14FFF", "#8CD17DFF",
                                "#B6992DFF", "#F1CE63FF","#499894FF"),
                    domain = veg$L2_new)

# Render the foundational Leaflet map
leaflet() %>%
    # Add Leaflet-provided gray background map
    leaflet::addProviderTiles(providers$CartoDB.Positron, group = "Gray background") %>%
    # Add Leaflet-provided terrain map
    leaflet::addProviderTiles("Esri.WorldImagery", group = "Imagery") %>%
    # Add vegetation layer
    leaflet::addPolygons(group = "Ecosystem", data = veg, color = ~pal3(L2_new), weight= 0.2,
                         fillColor = ~pal3(L2_new), fillOpacity = .7,
                         label = ~htmlEscape(paste("Ecosystem:", L2_new))) %>%
    # Add legend for vegetation layer
    leaflet::addLegend(
      group = "Ecosystem",
      data = veg,
      pal = pal3,
      values = veg$L2_new,
      position = "bottomleft",
      title = "Ecosystem"
    ) %>%
    # Add raster layer plot
    leaflet::addRasterImage(group = "Total Fires", total_fires, colors = pal1, project = F) %>%
    # Add legend for raster layer
    leaflet::addLegend(
      group = "Total Fires",
      data = total_fires,
      pal = pal1,
      values = terra::values(total_fires),
      position = "bottomleft",
      title = "Total Fires"
    ) %>%
    # Add a second layer
    leaflet::addRasterImage(group = "Years Since Last Fire", time_since, colors = pal2, project = F) %>%
    # Add another legend for the second layer
    leaflet::addLegend(
      group = "Years Since Last Fire",
      data = time_since,
      pal = pal2,
      values = terra::values(time_since),
      position = "bottomleft",
      title = "Years Since Last Fire"
    ) %>%
    # Add lat/lon coordinate indicator
    leafem::addMouseCoordinates() %>%
    # Add mouseover popup that shows the value of the raster layers
    leafem::addImageQuery(
      x = raster::raster(total_fires),
      group = "Total Fires",
      position = "bottomright"
    ) %>%
    leafem::addImageQuery(
      x = raster::raster(time_since),
      group = "Years Since Last Fire",
      position = "bottomright"
    ) %>%
    # Set the layer control
    leaflet::addLayersControl(
      baseGroups = c("Gray background", "Imagery"),
      overlayGroups = c("Total Fires", "Years Since Last Fire", "Ecosystem"),
      options = layersControlOptions(collapsed = FALSE)
    ) %>%
    # Hide these groups by default
    hideGroup(c("Years Since Last Fire", "Ecosystem"))
