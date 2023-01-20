library(stringr)


new_names <- c(
  "Carimbo de data/hora" = "DataHora",
  "Seu nome completo:" = "Nome",
  "Seu e-mail de contato:" = "Email",
  "Seu telefone (vamos criar um grupo de WhatsApp, onde alunos podem compartilhar dúvidas comigo, além de materiais e os links para as aulas):" = "Telefone",
  "Qual curso você faz? Ou caso já tenha formado, qual curso você fez?" = "Curso",
  "Em qual instituição de ensino você faz ou fez sua graduação?" = "Instituicao",
  "Qual é o seu período?" = "Periodo",
  "Qual o melhor período para você iniciar o curso?" = "MelhorPeriodo",
  "Que horário do dia, é o melhor para você? (Você pode escolher mais de um horário)" = "MelhorHorario",
  "Quantas aulas por semana? (Você pode escolher mais de uma opção)" = "QuantasAulas",
  "Quais são os melhores dias da semana? (Você pode escolher mais de uma opção)" = "MelhoresDias",
  "Você tem algum desejo ou sugestão para este curso? Ou para algum curso futuro? Tem um tema no R que lhe interessa, e gostaria de aprender mais?" = "Sugestao"
)


colnames(respostas) <- unname(new_names[colnames(respostas)])



inst_fix <- data.frame(
  inst = str_to_upper(respostas$Instituicao)
)

inst_fix$abbrev <- inst_fix$inst


teste <- grepl(
  pattern = "Ouro Preto",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UFOP"


teste <- grepl(
  pattern = "VIÇOSA",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UFV"


teste <- grepl(
  pattern = "GRANDE DOURADOS",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UFGD"


teste <- grepl(
  pattern = "MARINGÁ",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UEM"


teste <- grepl(
  pattern = "SERGIPE",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UFS"


teste <- grepl(
  pattern = "CARIRI",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "URCA"


teste <- grepl(
  pattern = "SANTA CATARINA",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UFSC"


teste <- grepl(
  pattern = "FLUMINENSE",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UFF"


teste <- grepl(
  pattern = "UNIVERSIDADE FEDERAL RURAL DA AMAZÔNIA",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UFRA"

teste <- grepl(
  pattern = "CAXIAS DO SUL",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UCS"

teste <- grepl(
  pattern = "UFMT",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UFMT"

teste <- grepl(
  pattern = "UFRRJ|RURAL DO RIO DE JANEIRO",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UFRRJ"


teste <- grepl(
  pattern = "PARANÁ",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UFPR"

teste <- grepl(
  pattern = "PARAÍBA",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UFPB"


teste <- grepl(
  pattern = "PERNAMBUCO",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UFPE"

teste <- grepl(
  pattern = "ESTADUAL DE MONTES CLAROS",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UNIMONTES"

teste <- grepl(
  pattern = "UNIP",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UNIP"

teste <- grepl(
  pattern = "UESC",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UESC"


teste <- grepl(
  pattern = "UFMG",
  x = inst_fix$inst,
  ignore.case = TRUE
)

inst_fix$abbrev[teste] <- "UFMG"


inst_fix <- inst_fix %>%
  as_tibble() %>%
  distinct(abbrev, .keep_all = TRUE)


respostas <- respostas %>%
  mutate(Instituicao_UP = str_to_upper(Instituicao)) %>%
  left_join(inst_fix, by = c("Instituicao_UP" = "inst")) %>%
  left_join(instituicoes, by = c("abbrev" = "Insti")) %>%
  as_tibble() %>%
  distinct()

