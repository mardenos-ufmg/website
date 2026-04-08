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
  
  df_guardado = readxl::read_xlsx("arvore.xlsx")[,1:8]
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
        left_join(df_guardado_ativo)
    }
    if (nrow(df_guardado_inativo)) {
      df_novo =
        df_novo |>
        rbind(df_guardado_inativo)
    }
    
    df_novo =
      df_novo |>
      arrange(status)
    
    writexl::write_xlsx(df_novo, "dashboards/arvore/arvore.xlsx")
  } else {
    stop("tipo = 0  =>  ler árvore do sistema; tipo = 1  => escrever nova árvore")
  }
}