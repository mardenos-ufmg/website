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

\n\n',
.
)}()

  writeLines(qmd_content, "bibliografia.qmd", useBytes = FALSE)
}




gerar_arvore = function() {
  suppressMessages(library(dplyr))
  
  root_path = normalizePath(here::here())
  root_name = basename(root_path)
  
  ignore_pattern = paste0(
    "(?:",
    "(^|/)\\.",              # qualquer pasta/arquivo que começa com ponto (.git, .quarto, .Rproj.user, .github)
    "|",
    "(^|/)_site(/|$)",       # _site
    "|",
    "(^|/)docs(/|$)",       # docs
    "|",
    "(^|/)_freeze(/|$)",     # _freeze
    "|",
    "(^|/)\\.ipynb_checkpoints(/|$)",     # .ipynb_checkpoints
    "|",
    "(^|/)__pycache__(/|$)",     # __pycache__
    "|",
    "^raw/snis/docs",         # raw/snis/docs
    "|",
    "\\.Rproj$",             # *.Rproj
    "|",
    "_quarto.yml$",             # *.Rproj
    "|",
    "_pkgdown.yml$",             # *.Rproj
    ")"
  )
  
  all_entries =
    list.files(
      path       = root_path,
      recursive  = TRUE,
      full.names = FALSE,
      all.files  = TRUE,
      include.dirs = TRUE
    ) |>
    {\(.) .[!grepl(ignore_pattern, ., perl = TRUE)]}()
  
  
  paths  = file.path(root_path, all_entries)
  is_dir = file.info(paths)$isdir
  
  df = data.frame(
    pathString = paste0(root_name, "/", all_entries),
    type       = ifelse(is_dir, "pasta", "ficheiro"),
    size_kb    = ifelse(
      is_dir, NA,
      round(file.info(paths)$size / 1024, 1)
    ),
    stringsAsFactors = FALSE
  )
  
  df$depth <- sapply(strsplit(df$pathString, "/"), length)
  df <- df[order(-df$depth), ]
  
  # iterar sobre cada pasta
  for(i in which(df$type == "pasta")) {
    path <- df$pathString[i]
    # todos os filhos (arquivos ou pastas) que começam com "pasta/"
    filhos <- grep(paste0("^", path, "/"), df$pathString)
    # somar os tamanhos dos filhos
    df$size_kb[i] <- sum(df$size_kb[filhos], na.rm = TRUE)
  }
  
  # opcional: remover coluna depth e voltar para ordem original
  df <- df[order(as.numeric(rownames(df))), ]
  df$depth <- NULL
  
  df <- rbind(data.frame(pathString = root_name, type = "pasta", size_kb = NA, stringsAsFactors = FALSE), df)
  
  df =
    df |>
    mutate(
      color = case_when(
        type == "pasta" ~ "#178ADE",
        type == "ficheiro" ~ "#1D9E75",
        TRUE ~ "#888780"
      )
    )
  
  widget = collapsibleTree::collapsibleTree(
    data.tree::as.Node(df),
    attribute    = "type",
    fill         = "color",
    fillByLevel  = FALSE,
    collapsed    = FALSE,
    tooltip      = TRUE,
    fontSize     = 14,
    width        = NULL,
    height       = 700,
    zoomable     = TRUE,
    rootOrientated = TRUE,
    inputId = "selected_node"
  )
  list(df=df, widget=widget)
}
