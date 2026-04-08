fs::dir_copy("raw/snis/docs", "_site/4devs/docs/snis", overwrite = TRUE)
# source("stuff/funs.R")
# if (!dir.exists("_site/4devs/arvore")) dir.create("_site/4devs/arvore", recursive = TRUE, showWarnings = FALSE)
# htmlwidgets::saveWidget(gerar_arvore()$widget, file = "_site/4devs/arvore/arvore.html", selfcontained = TRUE)