library(tidyverse)

p_dir <- "~/Documents/Personal-website/posts/2024/2024-02-19-flow-even/src/"
p_curves <- paste0(p_dir, "even_curves.csv")
curves <- read_delim(p_curves, delim = ";") |>
  filter(x != 0)
curves$curve_id <- as.integer(curves$curve_id)

left <- curves %>% filter(direction == 0) %>% arrange(curve_id, desc(step_id))
right <- curves %>% filter(direction == 1)

curves <- left %>% 
  bind_rows(right)

cartesian = coord_cartesian(
  xlim = c(0, 120),
  ylim = c(0, 120),
  expand =  FALSE
)

curves %>% 
  ggplot() +
  geom_path(
    aes(x, y, group = curve_id)
  ) +
  cartesian +
  theme_void()



curves %>% filter(curve_id == 5) %>% 
  ggplot() +
  geom_path(
    aes(x, y, group = curve_id, color = as.factor(curve_id))
  ) +
  geom_point(
    aes(x = 44.39, y = 34.05)
  )
