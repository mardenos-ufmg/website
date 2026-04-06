library(data.tree)
library(collapsibleTree)
library(htmlwidgets)

# ── 2. Argumento de entrada ───────────────────
# args <- commandArgs(trailingOnly = TRUE)
# 
# if (length(args) == 0) {
#   root_path <- getwd()  # usa directório actual se nenhum path fornecido
#   message("Nenhum path fornecido. A usar: ", root_path)
# } else {
#   root_path <- normalizePath(args[1], mustWork = TRUE)
# }

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

# df2 <- df
# 
# df2$depth <- sapply(strsplit(df2$pathString, "/"), length)
# df2 <- df2[order(-df2$depth), ]
# 
# # iterar sobre cada pasta
# for(i in which(df2$type == "pasta")) {
#   path <- df2$pathString[i]
#   # todos os filhos (arquivos ou pastas) que começam com "pasta/"
#   filhos <- grep(paste0("^", path, "/"), df2$pathString)
#   # somar os tamanhos dos filhos
#   df2$size_kb[i] <- sum(df2$size_kb[filhos], na.rm = TRUE)
# }
# 
# # opcional: remover coluna depth e voltar para ordem original
# df2 <- df2[order(as.numeric(rownames(df2))), ]
# df2$depth <- NULL


# build_df <- function(entries, root) {
#   paths <- file.path(root, entries)
#   is_dir <- file.info(paths)$isdir
#   
#   df <- data.frame(
#     pathString = paste0(root_name, "/", entries),
#     type       = ifelse(is_dir, "pasta", "ficheiro"),
#     size_kb    = ifelse(
#       is_dir, NA,
#       round(file.info(paths)$size / 1024, 1)
#     ),
#     stringsAsFactors = FALSE
#   )
#   df
# }
# 
# df <- build_df(all_entries, root_path)

# ── 5. Criar nó raiz se necessário ────────────

# ── 6. Construir árvore ───────────────────────
tree <- as.Node(df)

# ── 7. Cores por tipo ─────────────────────────
fill_color <- function(node) {
  if (is.null(node$type)) return("#888780")
  if (node$type == "pasta") "#178ADE" else "#1D9E75"
}

# ── 8. Gerar widget interativo ────────────────
widget <- collapsibleTree(
  tree,
  attribute    = "type",
  fillByLevel  = FALSE,
  collapsed    = FALSE,
  tooltip      = TRUE,
  fontSize     = 14,
  width        = NULL,
  height       = 700,
  zoomable     = TRUE,
  rootOrientated = TRUE
)

# ── 9. Guardar como HTML ──────────────────────
output_file <- file.path(dirname(root_path),
                         paste0(root_name, "_file_tree.html"))

saveWidget(widget, file = output_file, selfcontained = TRUE)
