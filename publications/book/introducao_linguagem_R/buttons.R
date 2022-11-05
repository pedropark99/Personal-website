links_pt <- c(
  "Compre uma versão física" = "https://amz.run/5UiQ",
  "Leia online" = "https://pedropark99.github.io/Introducao_R/",
  "Respostas dos exercícios" = "./../respostas_complete.pdf"
)

links_en <- c(
  "Buy a physical copy" = "https://amz.run/5UiQ",
  "Read online" = "https://pedropark99.github.io/Introducao_R/",
  "Exercises answers" = "./../respostas_complete.pdf"
)

format_button <- function(x){
  text <- names(x)
  ref <- unname(x)
  t <- '<a href="%s"> <button type="button" class="btn btn-primary">%s</button></a>'
  t <- sprintf(t, ref, text)
  return(t)
}

build_html <- function(links){
  buttons <- vector("character", length(links))
  for (i in seq_along(links)) {
    buttons[i] <- format_button(links[i])
  }
  return(buttons)
}

buttons_pt <- build_html(links_pt)
buttons_pt <- paste0(buttons_pt, collapse = "\n")
readr::write_file(buttons_pt, "buttons-pt.html")


buttons_en <- build_html(links_en)
buttons_en <- paste0(buttons_en, collapse = "\n")
readr::write_file(buttons_en, "buttons-en.html")
