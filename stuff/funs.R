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


arvore_gerar_df = function() {
  suppressMessages(library(dplyr))
  
  ignore_pattern = paste0(
    "(?:",
    "(^|/)\\.",
    "|",
    "(^|/)_site(/|$)",
    "|",
    "(^|/)docs(/|$)",
    "|",
    "(^|/)rsconnect(/|$)",
    "|",
    "(^|/)_freeze(/|$)",
    "|",
    "(^|/)\\.ipynb_checkpoints(/|$)",
    "|",
    "(^|/)__pycache__(/|$)",
    "|",
    "^raw/snis/docs",
    "|",
    "^raw/snis/more/lab/.+",
    "|",
    "^raw/snis/man/.+",
    "|",
    "\\.Rproj$",
    "|",
    "_quarto.yml$",
    "|",
    "_pkgdown.yml$",
    ")"
  )
  
  df =
    list.files(
      path       = here::here(),
      recursive  = TRUE,
      full.names = FALSE,
      all.files  = TRUE,
      include.dirs = TRUE
    ) |>
    {\(.) .[!grepl(ignore_pattern, ., perl = TRUE)]}() |>
    data.frame() |>
    `colnames<-`("path") |>
    mutate(
      type = ifelse(file.info(path)$isdir, "pasta", "ficheiro"),
      color = case_when(
        type == "pasta" ~ "#178ADE",
        type == "ficheiro" ~ "#1D9E75",
        TRUE ~ "#888780"
      ),
      size_kb = ifelse(type == "pasta", NA, round(file.info(path)$size / 1024, 1))
    ) |>
    {\(.) {.$depth = sapply(strsplit(.$path, "/"), length); . = .[order(-.$depth), ]; .}}()
  
  for(i in which(df$type == "pasta")) {
    path = df$path[i]
    filhos = grep(paste0("^", path, "/"), df$path)
    df$size_kb[i] = sum(df$size_kb[filhos], na.rm = TRUE)
  }
  
  df =
    df[order(as.numeric(rownames(df))), ] |>
    mutate(
      path = file.path(basename(here::here()), path)
    ) |>
    {\(.) rbind(data.frame(path = basename(here::here()), type = "pasta", color = "#FF0000", size_kb = NA, depth = 0), .)}() |>
    mutate(
      status = 1,
      descricao = NA,
      palavras_chave = NA
    )
  
  df
}

arvore_gerar_widget = function(df = NULL) {
  if (is.null(df)) df = arvore_gerar_df()
  collapsibleTree::collapsibleTree(
    data.tree::as.Node(df, pathName = "path"),
    attribute    = "type",
    fill         = "color",
    fillByLevel  = FALSE,
    collapsed    = FALSE,
    tooltip      = TRUE,
    fontSize     = 14,
    width        = NULL,
    height       = 800,
    zoomable     = TRUE,
    rootOrientated = TRUE,
    inputId = "selected_node"
  )
}



arvore_io = function(tipo) {
  if (tipo == "ler") {
    tipo = 0
  } else if (tipo == "escrever") {
    tipo = 1
  }
  
  df_guardado = readxl::read_xlsx(here::here("dashboards/arvore/arvore.xlsx"))[,1:8]
  #df_guardado = readxl::read_xlsx("arvore.xlsx")[,1:8]
  #df_guardado = readxl::read_xlsx("dashboards/arvore/arvore.xlsx")[,1:8]
  df_gerado   = arvore_gerar_df()
  
  if (!setequal(colnames(df_gerado), c("path", "type", "color", "size_kb", "depth", "status", "descricao", "palavras_chave"))) {
    warning("há algum erro na árvore salva em excel, usando árvore limpa")
    if (tipo == 0) return(df_gerado) else stop("ERRO")
  }
  
  if (tipo == 0) {  # read
    return(df_guardado)
  } else if (tipo == 1) {  # write
    df_guardado_ativo =
      df_guardado |>
      filter(path %in% df_gerado$path) |>
      select(path, descricao, palavras_chave)
    
    df_guardado_inativo =
      df_guardado |>
      filter(!(path %in% df_gerado$path)) |>
      mutate(
        status = 0
      )
    
    df_novo = df_gerado
    
    if (nrow(df_guardado_ativo)) {
      df_novo =
        df_novo |>
        select(-c(descricao, palavras_chave)) |>
        left_join(df_guardado_ativo, by = "path")
    }
    if (nrow(df_guardado_inativo)) {
      df_novo =
        df_novo |>
        rbind(df_guardado_inativo)
    }
    
    df_novo =
      df_novo |>
      arrange(status)
    
    writexl::write_xlsx(df_novo, here::here("dashboards/arvore/arvore.xlsx"))
  } else {
    stop("tipo = 0  =>  ler árvore do sistema; tipo = 1  => escrever nova árvore")
  }
}
