## --------------------------------------------------------------- ##
## Graph theory analysis of larval connectivity experiments
## Developer: Andres Ospina-Alvarez (aospina.co@me.com)
## Project: Mejoramiento de interfaz web para modelación biofísica
## de especies bentónicas y modelación hidrodinámica (IFOP 2020)
## --------------------------------------------------------------- ##


#### Loading netcdf output ####
library(ncdf4) # package for netcdf manipulation
source("opendrift_read.R")

ls_1 <- opendrift_read(filename = "A1_2020-12-02_09-31-25_673999.nc", metadata = TRUE)

#### Loading geographical coordinates of predefined zones ####
#### The file should have three columns named "lon", "lat" and "name"
AMERBS <- read.table("AMERS_LOCO.txt", quote="\"", comment.char="")
names(AMERBS) <- c("lon", "lat")
AMERBS$name <- 1:nrow(AMERBS)

#### Assigning the initial and final positions of the particles to one of the predefined zones ####
source("zone_assign.R")
data <- zone_assign(amerbs_points = AMERBS,
            data_from = ls_1$data_from,
            data_to = ls_1$data_to,
            treshold_km = 2, # Minimum distance a particle must be to be assigned to a predefined area
            min_lon_ppp = ls_1$min_lon_ppp - 2,
            max_lon_ppp = ls_1$max_lon_ppp + 1,
            min_lat_ppp = ls_1$min_lat_ppp,
            max_lat_ppp = ls_1$max_lat_ppp
            )

#### Creating the dataframe that contains all the information to generate the heat maps and graphs of the network ####
source("opd_matrix.R")
df.matrices <- opd_matrix(data = data)

#### Plotting the connectivity matrices ####
library(ggplot2)
# library(hrbrthemes)
library(ggExtra)
# Count Matrix Figure
ggplot(data = df.matrices, aes(from, to, fill=value)) +
#  theme_ipsum() + 
  geom_raster() +
  scale_fill_distiller(palette = "Spectral",
                       direction = -1,
                       na.value = "transparent"
  ) +
  removeGrid(x = TRUE, y = TRUE) +
  xlab("Source cell") +
  ylab("Destination cell") +
  labs(fill="Individuals") +
  theme(axis.title.x = element_text(face="bold", size=rel(2)),
        axis.text.x  = element_text(size=rel(2))) +
  theme(axis.title.y = element_text(face="bold", size=rel(2)),
        axis.text.y  = element_text(size=rel(2))) +
  theme(legend.text = element_text(size=rel(1.5)),
        legend.title = element_text(size=rel(1.5), face="bold"),
        legend.position="right") +
  theme(strip.text = element_text(face="bold", size=rel(1.5)))


# Potential matrix Figure
ggplot(data = df.matrices, aes(from, to, fill=probability)) +
  theme_ipsum() + 
  geom_raster() +
  scale_fill_distiller(palette = "Spectral",
                       direction = -1,
                       na.value = "transparent") +
  removeGrid(x = TRUE, y = TRUE) +
  xlab("Source cell") +
  ylab("Destination cell") +
  labs(fill="Probability") +
  theme(axis.title.x = element_text(face="bold", size=rel(2)),
        axis.text.x  = element_text(size=rel(2))) +
  theme(axis.title.y = element_text(face="bold", size=rel(2)),
        axis.text.y  = element_text(size=rel(2))) +
  theme(legend.text = element_text(size=rel(1.5)),
        legend.title = element_text(size=rel(1.5), face="bold"),
        legend.position="right") +
  theme(strip.text = element_text(face="bold", size=rel(1.5)))


#### Generating the network graph ####
source("opd_network_graph.R")
con.plot <- opd_network_graph(df.matrices = df.matrices, amerbs_points = AMERBS)

source("normalize_fun.R")
source("opd_centrality.R")
con.plot <- opd_centrality(graph = con.plot)



##### Graph with geographical positions assigned to zones ####
library(mapdata)
maptheme <-
  theme_minimal(base_size = 20) %+replace% #Relative size of plot
  theme(
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    legend.position = c(0, 0),
    legend.justification = c(0, 0),
    legend.background = element_blank(),
    # Remove overall border
    legend.key = element_blank(),
    # Remove border around each item
    panel.background = element_rect(fill = "#F2F2F2"),
    plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), 'cm')
  )

country_shapes <-
  geom_polygon(
    aes(x = long, y = lat, group = group),
    data = map_data('worldHires'),
    fill = "#CECECE",
    color = "#515151",
    size = 0.15
  )

# This is where the corners of the map are defined.
mapcoords <-
  coord_fixed(xlim = c(-72.0, -70.5), ylim = c(-30.8, -28.5))


library(ggraph)
library(RColorBrewer)
library(scales)


### What color palettes for nodes and arcs do you want to use?
cbpalette_arcs_low <- "#87CEFF" # Light blue
cbpalette_arcs_high <- "#27408B" # Dark blue
cbpalette_nodes <- "YlOrRd"

### Legend position (up, down, right, left, or a euclidean coordinate)
# legend_pos <- "right"
legend_pos <- c(0.50, 0.05)


##### A graph with the connection strength (probability) for the arcs and the weighed degree (strength) for the nodes #####
g <- con.plot
ggraph(g,
       layout = "manual",
       x = V(g)$x,
       y = V(g)$y) +
  country_shapes +
  
  geom_edge_arc(
    aes(
      edge_color = strength,
      edge_alpha = strength,
      edge_width = strength
    ),
    arrow = arrow(length = unit(1, 'mm'), type = "closed"),
    start_cap = circle(1, 'mm'),
    end_cap = circle(1.5, 'mm'),
    strength = 1
  ) +
  
  scale_edge_colour_gradient(low = cbpalette_arcs_low,
                             high = cbpalette_arcs_high) +
  
  scale_edge_alpha(range = c(0.3, 1)) +
  
  scale_edge_width_continuous(range = c(0.4, 1)) +
  
  geom_node_point(aes(size = strength, color = strength)) +
  scale_color_gradientn(colours = brewer_pal(palette = cbpalette_nodes)(5)) +
  scale_size_continuous(range = c(0.3, 3)) +
  scale_alpha_continuous(range = c(0.4, 1)) +
  
  guides(
    size       = guide_legend("node strength"),
    color      = guide_legend("node strength"),
    edge_alpha = guide_legend("edge strength"),
    edge_width = guide_legend("edge strength"),
    edge_color = guide_legend("edge strength")
  ) +
  mapcoords +
  maptheme +
  theme(
    legend.position = legend_pos,
    legend.text = element_text(size = 8, lineheight = 0.5),
    legend.key.height = unit(0.5, "cm")
  )

##### Another graph with the edge betweenness (normalized) for the arcs and the node betweenness (normalized) for the nodes #####
g <- con.plot
ggraph(g,
       layout = "manual",
       x = V(g)$x,
       y = V(g)$y) +
  country_shapes +
  
  geom_edge_arc(
    aes(
      edge_color = n.edge_betweenness,
      edge_alpha = n.edge_betweenness,
      edge_width = n.edge_betweenness
    ),
    arrow = arrow(length = unit(1, 'mm'), type = "closed"),
    start_cap = circle(1, 'mm'),
    end_cap = circle(1.5, 'mm'),
    strength = 1
  ) +
  
  scale_edge_colour_gradient(low = cbpalette_arcs_low,
                             high = cbpalette_arcs_high) +
  
  scale_edge_alpha(range = c(0.3, 1)) +
  
  scale_edge_width_continuous(range = c(0.4, 1)) +
  
  geom_node_point(aes(size = n.betweenness, color = n.betweenness)) +
  scale_color_gradientn(colours = brewer_pal(palette = cbpalette_nodes)(5)) +
  scale_size_continuous(range = c(0.3, 3)) +
  scale_alpha_continuous(range = c(0.4, 1)) +
  
  guides(
    size       = guide_legend("norm. node\n betweenness"),
    color      = guide_legend("norm. node\n betweenness"),
    edge_alpha = guide_legend("norm. edge\n betweenness"),
    edge_width = guide_legend("norm. edge\n betweenness"),
    edge_color = guide_legend("norm. edge\n betweenness")
  ) +
  mapcoords +
  maptheme +
  theme(
    legend.position = legend_pos,
    legend.text = element_text(size = 8, lineheight = 0.5),
    legend.key.height = unit(0.5, "cm")
  )

