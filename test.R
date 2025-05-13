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
