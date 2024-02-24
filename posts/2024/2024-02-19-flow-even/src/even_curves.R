library(tidyverse)

p_dir <- "~/Documents/Personal-website/posts/2024/2024-02-19-flow-even/src/"
p_curves <- paste0(p_dir, "even_curves.csv")
curves <- read_delim(p_curves, delim = ";") |>
  filter(x != 0)
curves$curve_id <- as.integer(curves$curve_id)

cartesian = coord_cartesian(
  xlim = c(0, 120),
  ylim = c(0, 120)
)

curves %>% 
  ggplot() +
  geom_path(
    aes(x, y, group = curve_id)
  ) +
  cartesian



curves %>% filter(curve_id == 5) %>% 
  ggplot() +
  geom_path(
    aes(x, y, group = curve_id, color = as.factor(curve_id))
  ) +
  geom_point(
    aes(x = 44.39, y = 34.05)
  )
