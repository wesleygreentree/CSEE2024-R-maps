# ggplot() example using Palmer penguins dataset
# Palmer penguins dataset: https://allisonhorst.github.io/palmerpenguins/

# setup
library(palmerpenguins)
library(ggplot2)
library(rphylopic)

# load data and take a look at first 10 rows
data(penguins)
head(penguins)

# plot bill length vs bill depth, using ggplot defaults
ggplot() +
  geom_point(data = penguins,
             aes(x = bill_length_mm, bill_depth_mm, 
                 color = species, shape = species)) +
  theme_classic()

## moving beyond ggplot defaults ---

# instead of a legend, annotate the map with species names as labels
species.labels <- data.frame(species = c("Adelie", "Chinstrap", "Gentoo"),
                             x = c(35, 56.5, 54.5),
                             y = c(20, 18.7, 15))

ggplot() +
  geom_point(data = penguins,
             aes(x = bill_length_mm, bill_depth_mm, color = species),
             size = 2.7, alpha = 0.7) +
  
  # instead of a legend, place species names on plot
  geom_text(data = species.labels, 
             aes(x = x, y = y, label = species, color = species),
             size = 7) +
  
  # label axes
  xlab("Bill length (mm)") + ylab("Bill depth (mm)") +
  
  # choose your own colours!
  scale_colour_manual(values = c("#ff6700", "#c15ccb", "#057076")) +
  
  # use theme to customize plot appearance
  theme_classic() +
  theme(legend.position = "none",
        axis.title = element_text(size = 18, color = "black"),
        axis.text = element_text(size = 16, color = "black"))

# add phylopic

ggplot() +
  geom_point(data = penguins,
             aes(x = bill_length_mm, bill_depth_mm, color = species),
             size = 2.7, alpha = 0.7) +
  
  # instead of a legend, place species names on plot
  geom_text(data = species.labels, 
            aes(x = x, y = y, label = species, color = species),
            size = 7) +
  
  # label axes
  xlab("Bill length (mm)") + ylab("Bill depth (mm)") +
  
  # choose your own colours!
  scale_colour_manual(values = c("#ff6700", "#c15ccb", "#057076")) +
  
  # use theme to customize plot appearance
  theme_classic() +
  theme(legend.position = "none",
        axis.title = element_text(size = 18, color = "black"),
        axis.text = element_text(size = 16, color = "black")) +
  
  # add silhouette of gentoo penguin
  add_phylopic(name = "Pygoscelis papua", x = 58.6, y = 20.5,
               ysize = 2)
ggsave("figures/penguin-phylopic.PNG", width = 17, height = 15, units = "cm",
       dpi = 1600, background = "white")
