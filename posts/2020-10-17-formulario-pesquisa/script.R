library(readxl)
library(tidyverse)
library(rnaturalearth)
library(rnaturalearthdata)
library(rgeos)

world <- ne_countries(scale = "medium", returnclass = "sf")


respostas <- read_excel("C:/Users/Pedro/Documents/formulario_pesquisa_interesse.xlsx")


source("C:/Users/Pedro/Documents/Personal-website/content/pt/post/2020-10-17-resultados-do-formulário-de-pesquisa-de-interesse-curso-introdutório-de-r/fix_instituicoes.R", encoding = "UTF-8")


instituicoes <- unique(instituicoes$abbrev)

instituicoes

distri_inst <- data.frame(
  inst = instituicoes,
  regiao = NA,
  estado = NA
)


brasil <- read_state()


respostas %>%
  left_join()


contagem <- instituicoes %>%
  filter(!is.na(Estado)) %>%
  group_by(Estado) %>%
  count()



world$marca <- NA
world$marca[world$name == "Mozambique"] <- "Mozambique"
world$marca[world$name == "Peru"] <- "Peru"
world$marca[world$name == "Brazil"] <- "Brazil"
world$marca[world$name == "Cuba"] <- "Cuba"
world$marca[world$name == "Venezuela"] <- "Venezuela"
world$marca[world$name == "Portugal"] <- "Portugal"
world$marca[is.na(world$marca)] <- "Não foi atingido"

cores <- c(
  "Brazil" = "#F8766D",
  "Cuba" = "#BB9D00",
  "Mozambique" = "#7CAE00",
  "Venezuela" = "#00A5FF",
  "Peru" = "#E76BF3",
  "Portugal" = "#4fc953",
  "Não foi atingido" = "#d4d4d4"
)

world$cores <- unname(cores[world$marca])

ggplot(data = world) +
  geom_sf(aes(fill = cores)) +
  coord_sf(xlim = c(-100, 50), ylim = c(-60, 40)) +
  theme_void() +
  labs(
    title = "Países atingidos pelo formulário",
    fill = "País de referência"
  ) +
  theme(legend.position = "bottom") +
  scale_fill_identity(
    guide = "legend",
    labels = names(cores),
    breaks = unname(cores)
  )






brasil <- brasil %>%
  left_join(contagem, by = c("name_state" = "Estado"))

ggplot(data = brasil) +
  geom_sf(aes(fill = name_region)) +
  stat_sf_coordinates(
    aes(label = n),
    geom = "text"
  ) +
  theme_void() +
  labs(fill = "Região")





resp_sum <- respostas %>%
  select(Regiao, Instituicao, abbrev, Estado) %>%
  group_by(Estado, Regiao) %>%
  summarise(contagem = n())

brasil <- brasil %>%
  left_join(resp_sum, by = c("name_state" = "Estado"))

ggplot(data = brasil) +
  geom_sf(aes(fill = Regiao)) +
  stat_sf_coordinates(
    aes(label = contagem),
    geom = "text"
  ) +
  theme_void() +
  labs(fill = "Região")








library(wordcloud)
library(RColorBrewer)

assuntos <- respostas %>%
  filter(!is.na(Assunto)) %>%
  group_by(Assunto) %>%
  count() %>%
  arrange(n)


cor <- brewer.pal(6, "Dark2")
names(cor) <- c("1", "3", "5", "8", "2", "4")
assuntos$color <- cor[as.character(assuntos$n)]

png("wordcloud.png", width = 900, height = 800, res = 280, type = "cairo")

set.seed(5)
wordcloud(
  words = assuntos$Assunto,
  freq = assuntos$n,
  min.freq = 1,
  max.words = 200,
  ordered.colors = TRUE,
  rot.per = 0.35,
  use.r.layout = FALSE,
  scale = c(2,0.1),
  colors = assuntos$color
)

dev.off()



library(lubridate)

respostas <- respostas %>%
  mutate(
    hora = hour(Carimbo),
    periodo_dia = case_when(
      between(hora, 5, 12) ~ "Manhã",
      between(hora, 13, 18) ~ "Tarde",
      between(hora, 19, 23) | between(hora, 0, 4) ~ "Noite"
    )
  )


plot(table(respostas$hora))

plot(table(respostas$Periodo))

areas <- respostas %>%
  filter(Area != "Economia") %>%
  group_by(Area) %>%
  count() %>%
  arrange(n)

cor <- brewer.pal(5, "Dark2")
names(cor) <- unique(areas$n)
areas$color <- unname(cor[as.character(areas$n)])


png("wordcloud.png", width = 1400, height = 1200, res = 280, type = "cairo")

wordcloud(

  words = areas$Area,
  freq = areas$n,
  min.freq = 1,
  max.words = 200,
  ordered.colors = TRUE,
  rot.per = 0.35,
  use.r.layout = FALSE,
  scale = c(2,0.5),
  color = areas$color
)

dev.off()
