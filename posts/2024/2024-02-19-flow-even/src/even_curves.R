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


pallete <- c(
  "#8ecae6",
  "#219ebc",
  "#023047",
  "#ffb703",
  "#fb8500"
)
curve_ids <- unique(curves$curve_id)
set.seed(50)
colors <- tibble(
  curve_id = curve_ids,
  color = sample(
    pallete, size = length(curve_ids), replace = TRUE
  )
)
curves <- curves %>% 
  left_join(colors)



cartesian = coord_cartesian(
  xlim = c(0, 120),
  ylim = c(0, 120),
  expand =  FALSE
)

pl <- curves %>% 
  ggplot() +
  geom_path(
    aes(x, y, group = curve_id, color = color),
    linewidth = 1
  ) +
  cartesian +
  scale_color_identity() +
  theme_void() +
  theme(
    legend.position = "none",
    plot.background = element_rect(fill = "#fae9be")
  )


ragg::agg_png("even_curves2.png", width = 2000, height = 1200, res = 200)
print(pl)
dev.off()



curves %>% filter(curve_id == 5) %>% 
  ggplot() +
  geom_path(
    aes(x, y, group = curve_id, color = as.factor(curve_id))
  ) +
  geom_point(
    aes(x = 44.39, y = 34.05)
  )
