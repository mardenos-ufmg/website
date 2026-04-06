gerar_arvore = function() {
suppressMessages(library(dplyr))

root_path = normalizePath("~/Documents/website")
root_name = basename(root_path)

ignore_pattern = paste0(
  "(?:",
  "(^|/)\\.",              # qualquer pasta/arquivo que começa com ponto (.git, .quarto, .Rproj.user, .github)
  "|",
  "(^|/)_site(/|$)",       # _site
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

widget <- collapsibleTree::collapsibleTree(
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
  rootOrientated = TRUE
)

htmlwidgets::saveWidget(widget, file = "_site/4devs/arvore/arvore.html", selfcontained = TRUE)
}
