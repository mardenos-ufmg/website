gerar_bibliografia = function() {
  suppressMessages(library(dplyr))
  library(glue)
  df =
    gsheet::gsheet2tbl("https://docs.google.com/spreadsheets/d/1P0u8OA5ZZtis5zEfhBOh4GcWrvbUxLWgxJlOlMPxGqU") |>
    mutate(
      across(everything(), ~ replace(.x, is.na(.x), "")),
      disponivel_online = if_else(link != "", "Sim", "Não")
      )
    
  tipo_meta = list(
    "Legislação"    = list(icon = "bi-bank",               cor = "text-warning"),
    "Livro"         = list(icon = "bi-book",               cor = "text-primary"),
    "Artigo"        = list(icon = "bi-journal-text",       cor = "text-success"),
    "Relatório"     = list(icon = "bi-file-earmark-text",  cor = "text-danger"),
    "Portal / Blog" = list(icon = "bi-globe",              cor = "text-info"),
    "Documentário"  = list(icon = "bi-camera-video",       cor = "text-secondary")
  )


  make_card <- function(df) {
    titulo_full <- if (nchar(df$subtitulo) > 0) glue("{df$titulo} – {df$subtitulo}") else df$titulo
    autor_line  <- if (nchar(df$autor) > 0)     glue("\n**Autor:** {df$autor}  ") else ""
    fonte_line  <- if (nchar(df$fonte) > 0)     glue("\n**Fonte:** {df$fonte}  ") else ""
    link_line   <- if (nchar(df$link) > 0)      glue("\n\n[Acessar material]({df$link})") else ""

  glue(
'
::: {{.g-col-12 .g-col-md-4}}
::: {{.card .h-100 .p-3}}

{titulo_full}

{autor_line}

{fonte_line}

{df$descricao}

{link_line}
:::
:::
'
  )
}

  qmd_content <- lapply(unique(df$tipo), function(tipo) {
    subset <- df |> filter(.data$tipo == .env$tipo)
  
    cards =
      lapply(split(subset, seq_len(nrow(subset))), unlist) |>
      lapply(function(x) unname(x) |> t() |> data.frame() |> `colnames<-`(names(x))) |>
      lapply(make_card)
    
    meta  <- if (!is.null(tipo_meta[[tipo]])) tipo_meta[[tipo]] else default_meta
    icon  <- meta$icon
    cor   <- meta$cor
  
  glue(
'
## {tipo} <i class="bi {icon} fs-2 {cor}"></i>

::: {{.grid}}
{paste(cards, collapse = "\n")}
:::
'
  )
}) |>
  paste(collapse = "\n") |>
  {\(.)
    paste0(
'---
title: "Bibliografia"
subtitle: "Explore uma curadoria de conteúdos relevantes sobre saneamento básico no Brasil, incluindo livros, artigos acadêmicos, legislação, relatórios institucionais e materiais audiovisuais"
toc: true
toc-location: body
page-layout: full
---

## [Produção própria](autoindex/producao)

A produção local do projeto pode ser acessada aqui, onde estão reunidos os conteúdos desenvolvidos internamente pelo grupo.

\n\n',
.
)}()

  writeLines(qmd_content, "bibliografia.qmd", useBytes = FALSE)
}
