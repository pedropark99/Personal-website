library(ggfunnel)
library(ggplot2)
library(ragg)
library(tibble)

rotulos <- c(
    "Entry point of sales flow",
    "Get social ID from the user",
    "Validate criterias",
    "Display loan options to user",
    "User confirmed the loan"
)

n_users <- c(
    13000, 1295, 3210, 3005, 1126
)

dados <- tibble(rotulos=rotulos, n_users=n_users)
plot <- funnel(dados, values=n_users, levels=rotulos, text_specs = list(colour = "white", size = 11/.pt))
plot <- plot +  labs(
    title = "Number of unique users that reached each step of the sales path",
    subtitle = "The biggest loss of users is at the \"Validate criterias\" step, where\nwe check if the user meet all the criterias.",
    y = NULL
  ) +
  theme(
    text = element_text(family = "Roboto"),
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(face = "italic", size = 13),
    plot.title.position = "plot",
    axis.text.y = element_text(hjust = 0)
  )

agg_png(
    "./posts/2023/2023-08-31-data-decisions/funnel-chart.png",
    res = 300, width = 2200, height = 1700
)
print(plot)
dev.off()




rotulos_br <- c(
    "Entrada do fluxo de vendas",
    "Coletar o CPF do usuário",
    "Validar todos os critérios",
    "Mostrar as opções de empréstimo",
    "Usuário confirmou o empréstimo"
)
dados_br <- tibble(rotulos=rotulos_br, n_users=n_users)
plot <- funnel(dados_br, values=n_users, levels=rotulos, text_specs = list(colour = "white", size = 10/.pt))
plot <- plot +  labs(
    title = "Número de usuários únicos em cada ponto do fluxo de vendas",
    subtitle = "A maior perda de usuários ocorre no ponto \"Validar todos os critérios\" que é o ponto\nonde checamos se o usuário se encaixa em todos os critérios.",
    y = NULL
  ) +
  theme(
    text = element_text(family = "Roboto"),
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(face = "italic", size = 12),
    plot.title.position = "plot",
    axis.text.y = element_text(hjust = 0)
  )

agg_png(
    "./posts/2023/2023-08-31-data-decisions/funnel-chart-pt.png",
    res = 300, width = 2200, height = 1700
)
print(plot)
dev.off()