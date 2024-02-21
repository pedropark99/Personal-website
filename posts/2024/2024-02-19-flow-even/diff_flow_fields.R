library(tidyverse)
library(ambient)

p_dir <- "~/Documents/Personal-website/posts/2024/2024-02-19-flow-even/"
p_starts <- "~/Documents/Personal-website/posts/2024/2024-02-19-flow-even/curves_starts.csv"
p_curves <- "~/Documents/Personal-website/posts/2024/2024-02-19-flow-even/curves.csv"
p_field <- "~/Documents/Personal-website/posts/2024/2024-02-19-flow-even/flow_field.csv"
curves_starts <- read_delim(p_starts, delim = ";")
curves_starts$curve_id <- as.integer(curves_starts$curve_id)
curves_non_overlap <- read_delim(p_curves, delim = ";")
flow_field <- read_delim(
  p_field, delim = ";",
  col_types = cols(x = col_integer(), y = col_integer(), value = col_double())
)


n <- 120
grid_height <- n
grid_width <- n
cartesian <- coord_cartesian(
  xlim = c(0, grid_width),
  ylim = c(0, grid_height),
  expand = FALSE
)

angles <- matrix(NA_real_, ncol = n, nrow = n)
for (i in seq_along(flow_field$x)) {
  x <- flow_field$x[i] + 1
  y <- flow_field$y[i] + 1
  v <- flow_field$value[i]
  angles[x, y] <- v
}

pallete <- c(
  "#8ecae6",
  "#219ebc",
  "#023047",
  "#ffb703",
  "#fb8500"
)


# Drawing curves =========================
off_boundaries <- function(x, y, limit = grid_width){
  x <= 0 ||
    y <= 0 ||
    x >= limit ||
    y >= limit
}


n_curves <- 1500
xs <- curves_starts$x
ys <- curves_starts$y
starts <- map2(xs, ys, \(x,y) c(x, y))


n_steps <- 30
step_length <- 0.01 * grid_width
curves <- list(
  curve_id = vector("integer", length = n_steps * n_curves),
  x = rep(-50, times = n_steps * n_curves),
  y = rep(-50, times = n_steps * n_curves)
)

for (curve_id in seq_len(n_curves)) {
  start <- starts[[curve_id]]
  x <- start[1]
  y <- start[2]
  
  for (i in seq_len(n_steps)) {
    ff_column_index <- as.integer(x)
    ff_row_index <- as.integer(y)
    
    if (off_boundaries(ff_column_index, ff_row_index)) {
      break
    }
    
    angle <- angles[ff_row_index, ff_column_index]
    x_step <- step_length * cos(angle)
    y_step <- step_length * sin(angle)
    x <- x + x_step
    y <- y + y_step

    curve_index <- (n_steps * (curve_id - 1)) + i
    curves$curve_id[curve_index] <- curve_id
    curves$x[curve_index] <- x
    curves$y[curve_index] <- y
  }
}


curve_ids <- unique(curves_non_overlap$curve_id)
set.seed(50)
colors <- tibble(
  curve_id = curve_ids,
  color = sample(
    pallete, size = length(curve_ids), replace = TRUE
  )
)

curves_df <- curves %>% 
  as_tibble() %>% 
  filter(x > -50)

curves_df <- curves_df %>% 
  left_join(colors)

curves_non_overlap <- curves_non_overlap %>% 
  filter(x > 0) %>% 
  left_join(colors)


p_curves_overlap <- curves_df %>%
  ggplot() +
  geom_path(
    aes(x, y, group = curve_id, color = color),
    linewidth = 1
  ) +
  cartesian +
  theme_void() +
  scale_color_identity() +
  theme(
    legend.position = "none",
    plot.background = element_rect(fill = "#fae9be")
  )

p_curves_non_overlap <- curves_non_overlap %>%
  ggplot() +
  geom_path(
    aes(x, y, group = curve_id, color = color),
    linewidth = 1
  ) +
  cartesian +
  theme_void() +
  scale_color_identity() +
  theme(
    legend.position = "none",
    plot.background = element_rect(fill = "#fae9be")
  )


print(p_curves_overlap)
print(p_curves_non_overlap)


filename_overlap <- paste0(p_dir, "overlap.png")
filename_non_overlap <- paste0(p_dir, "non_overlap.png")

ragg::agg_png(filename_overlap, width = 2000, height = 1200, res = 200)
print(p_curves_overlap)
dev.off()

ragg::agg_png(filename_non_overlap, width = 2000, height = 1200, res = 200)
print(p_curves_non_overlap)
dev.off()
