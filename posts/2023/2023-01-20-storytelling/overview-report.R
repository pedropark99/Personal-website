library(tidyverse)
library(lubridate)

datas <- seq.Date(as.Date("2022-01-01"), as.Date("2022-12-09"), by = "day")

set.seed(40)
y <- c(1, 0.9, 0.82, 0.79, 0.6, 0.45, 0.3)
y <- y * rnorm(length(datas), mean = 320, sd = 50)
y <- abs(y)

df <- tibble(
  Data = datas,
  UsuariosAtivos = y,
  UsuariosEngajados = 0.75 * y
)

por_mes <- df |>
  group_by(Mes = month(Data)) |>
  summarise(
    UsuariosAtivos = as.integer(sum(UsuariosAtivos)),
    UsuariosEngajados = as.integer(sum(UsuariosEngajados))
  )

tema_grafico <- theme(
  axis.title = element_blank(),
  axis.text = element_text(size = 16, family = "Nunito Sans", face = "bold", colour = "#222222"),
  text = element_text(size = 16, family = "Nunito Sans", face = "bold", colour = "#222222"),
  plot.title.position = "plot",
  plot.title = element_text(size = 25, hjust = 0.5),
  panel.background = element_rect(fill = "white"),
  panel.grid.major.y = element_line(colour = "#d6d6d6", size = 1),
  panel.grid.minor = element_blank(),
  panel.grid.major.x = element_blank(),
  legend.position = "top",
  legend.title = element_blank()
)

cores <- c("#e63946", "#1d3557")


pl <- df |>
  filter(month(Data) == 11) |>
  ggplot() +
  geom_line(
    aes(x = Data, y = UsuariosAtivos, color = "Usuários ativos"),
    size = 1
  ) +
  geom_line(
    aes(x = Data, y = UsuariosEngajados, color = "Usuários engajados"),
    size = 1
  ) +
  labs(title = "Evolução diária de usuários ativos") +
  scale_color_manual(values = cores) +
  tema_grafico

ragg::agg_png(
  "posts/2023/2023-01-20-storytelling/usuarios-ativos-diario.png",
  width = 2000, height = 1000, res = 200
)
print(pl)
dev.off()





y <- c(
  0.05, 0.05, 0.25, 0.25, 0.27, 0.36, 0.42, 0.7, 0.78,
  0.95, 0.98, 0.98, 0.9, 0.8, 0.78, 0.75, 0.74, 0.7,
  0.5, 0.4, 0.4, 0.38, 0.35, 0.34
)

set.seed(40)
taxa_perdidos <- rnorm(24, 0.1, 0.02)
taxa_perdidos <- abs(taxa_perdidos)

df <- tibble(
  Hora = 0:23,
  `Tickets Atendidos` = y * 2400,
  `Tickets Perdidos` = y * 2400 * 0.1
)


pl <- df |>
  pivot_longer(
    cols = c("Tickets Atendidos", "Tickets Perdidos"),
    names_to = "Indicador",
    values_to = "Valor"
  ) |>
  ggplot() +
  geom_bar(
    aes(x = Hora, y = Valor, fill = Indicador),
    position = "stack", stat = "sum"
  ) +
  scale_fill_manual(values = cores) +
  tema_grafico +
  labs(title = "Número de tickets atendidos e perdidos por hora") +
  guides(size = "none")




ragg::agg_png(
  "posts/2023/2023-01-20-storytelling/tickets-hora.png",
  width = 2000, height = 1000, res = 200
)
print(pl)
dev.off()



