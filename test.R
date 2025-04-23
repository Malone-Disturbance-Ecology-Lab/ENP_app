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

