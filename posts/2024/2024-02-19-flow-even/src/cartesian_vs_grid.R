library(tidyverse)
cartesian_width <- 100
cartesian <- coord_cartesian(
  xlim = c(0, cartesian_width),
  ylim = c(0, cartesian_width)
)

th <- theme(
  panel.background = element_rect(fill = "white"),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  axis.title = element_blank(),
  axis.ticks = element_blank(),
  axis.text = element_text(color = "#222222", size = 16)
  # panel.grid.minor = element_line(colour = "#222222"),
  # panel.grid.major = element_line(colour = "#222222")
)

c <- ggplot() +
  geom_vline(xintercept = 0) +
  geom_hline(yintercept = 0) +
  geom_point(
    aes(x = 42.312, y = 72.112),
    size = 4,
    color = "red"
  ) +
  annotate(
    geom = "text", label = "Coordinate x = 42.312 and y = 72.112",
    x = 50, y = 28,
    size = 18 / .pt,
    family = "Inconsolata"
  ) +
  geom_curve(
    aes(x = 57, y = 33, xend = 45, yend = 69),
    arrow = arrow(),
    linewidth = 2,
    curvature = 0.2
  ) +
  scale_x_continuous(
    breaks = c(0, 50, 100),
    limits = c(0, cartesian_width)
  ) +
  scale_y_continuous(
    breaks = c(0, 50, 100),
    limits = c(0, cartesian_width)
  ) +
  cartesian +
  th




dsep <- 2
density_width <- as.integer(cartesian_width / dsep)
get_density_col <- function(x){
  as.integer(x / dsep) + 1L
}
get_density_row <- function(y){
  as.integer(y / dsep) + 1L
}
x1 <- 42.312
y1 <- 72.112
x2 <- get_density_col(x1)
y2 <- get_density_row(y1)


density_grid <- ggplot() +
  geom_vline(xintercept = 0) +
  geom_hline(yintercept = 0) +
  geom_line(
    aes(x, y, group = id),
    data = tibble(
      id = rep(seq_len(density_width), each = 2),
      x = rep(c(0, 50), times = density_width),
      y = rep(seq_len(density_width), each = 2)
    )
  ) +
  geom_line(
    aes(x, y, group = id),
    data = tibble(
      id = rep(seq_len(density_width), each = 2),
      x = rep(seq_len(density_width), each = 2),
      y = rep(c(0, 50), times = density_width)
    )
  ) +
  geom_rect(
    aes(xmin = x2, ymin = y2, xmax = x2 + 1L, ymax = y2 + 1L),
    fill = "red"
  ) +
  scale_x_continuous(
    breaks = c(0, 25, density_width),
    limits = c(0, density_width)
  ) +
  scale_y_continuous(
    breaks = c(0, 25, density_width),
    limits = c(0, density_width)
  ) +
  labs(subtitle = "With dsep = 2, coordinate x = 42.312 and y = 72.112 from Cartesian plane\nis mapped to the cell at position x = 22 and y = 37 in the density grid\n(rectangle painted in red)") +
  th +
  theme(
    plot.subtitle = element_text(size = 16)
  )


ragg::agg_png("cartesian_plane.png", res = 200, width = 1600, height = 1200)
print(c)
dev.off()

ragg::agg_png("density_grid.png", res = 200, width = 1900, height = 1400)
print(density_grid)
dev.off()
