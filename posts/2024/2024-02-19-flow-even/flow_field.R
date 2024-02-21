library(tidyverse)

path <- "~/Documents/Personal-website/posts/2024/2024-02-19-flow-even/curves.csv"
path2 <- "~/Documents/Personal-website/posts/2024/2024-02-19-flow-even/flow_field.csv"
curves <- read_delim(path, delim = ";")
flow_field <- read_delim(path2, delim = ";")
curves$curve_id <- as.integer(curves$curve_id)
curves <- curves %>% 
  filter(x > 0)


curves %>%
  filter(curve_id %in% c(258, 56)) %>% 
  ggplot() +
  geom_path(aes(x, y, group = curve_id)) +
  coord_cartesian(
    xlim = c(0, 120),
    ylim = c(0, 120)
  )



curves %>% 
  filter(curve_id == 258)

curves %>% 
  filter(between(x, 88, 93), between(y, 55,58))


visualize_grid <- function(grid, n){
  # Calculate the n^2 lines
  grid <- grid %>% 
    mutate(
      line_id = seq_len(nrow(grid)),
      xend = cos(value),
      yend = sin(value),
    )
  
  # Spread the lines across the grid
  grid <- grid %>% 
    mutate(
      xend = xend + x,
      yend = yend + y
    )
  
  # Plot these lines
  u <- "inches"
  a <- arrow(length = unit(0.025, u))
  ggplot(grid) +
    geom_segment(
      aes(
        x = x, y = y,
        xend = xend,yend = yend,
        group = line_id
      ),
      arrow = a
    ) +
    coord_cartesian(
      xlim = c(0,n), ylim = c(0,n)
    ) +
    theme_void()
}

build_grid_df <- function(angles, n) {
  tibble(
    x = rep(seq_len(n), each = n),
    y = rep(seq_len(n), times = n),
    value = angles |> as.vector()
  )
}

# flow_field %>% 
#   visualize_grid(n = 120)
# 
# angles %>% 
#   build_grid_df(n = 120) %>% 
#   visualize_grid(n = 120)


### Teste
angles <- matrix(NA_real_, nrow = grid_width, ncol = grid_width)
for(i in seq_along(flow_field$x)) {
  x <- flow_field$x[i]
  y <- flow_field$y[i]
  v <- flow_field$value[i]
  angles[x, y] <- v
}

off_boundaries <- function(x, y, limit = grid_width){
  x <= 0 ||
    y <= 0 ||
    x >= limit ||
    y >= limit
}


grid_width <- 120
step_length <- 0.01 * grid_width
n_steps = 30
x = 78.813140200829665
y = 47.606804877336515

for (i in seq_len(n_steps)) {
  ff_column_index <- as.integer(x)
  ff_row_index <- as.integer(y)
  
  if (off_boundaries(ff_column_index, ff_row_index)) {
    print(sprintf("[INFO]: Out of boundaries at x: %f | y: %f", x, y))
    break
  }
  
  angle <- angles[ff_row_index, ff_column_index]
  print(sprintf("x: %f | y: %f | a: %f", x, y, angle))
  x_step <- step_length * cos(angle)
  y_step <- step_length * sin(angle)
  x <- x + x_step
  y <- y + y_step
  
}



distance <- function(x1, y1, x2, y2){
  s1 <- (x2 - x1)^2
  s2 <- (y2 - y1)^2
  return(sqrt(s1 + s2))
}

curves %>%
  filter(curve_id %in% c(258, 56)) %>% 
  mutate(
    dist = distance(
      91.682406842372131,
      56.134913138987564,
      x,
      y
    )
  ) %>% 
  arrange(dist)



get_density_col <- function(x){
  as.integer(x / 1.2) + 1L
}
get_density_row <- function(y){
  as.integer(y / 1.2) + 1L
}
