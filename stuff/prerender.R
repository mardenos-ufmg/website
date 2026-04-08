ultima_alteracao_snis =
  list.files("raw/snis", full.names = TRUE) |>
  file.info() |>
  dplyr::select(dplyr::all_of("mtime")) |>
  unlist() |>
  max() |>
  as.POSIXct()

precisa_build_site =
  ( ultima_alteracao_snis > as.POSIXct(readLines("stuff/timestamp_snis_docs.txt")) ) |>
  {\(.) ifelse(is.na(.), T, .)}()

if (precisa_build_site) {
  cat("\niniciando pkgdown\n")
  suppressMessages(suppressWarnings(pkgdown::build_site("raw/snis")))
  cat(as.character(Sys.time()), "\n", file = "stuff/timestamp_snis_docs.txt")
  cat("pkgdown OK\n")
}


timestamp_blog_github =
  "https://raw.githubusercontent.com/mardenos-ufmg/website-blog/refs/heads/main/timestamp.txt" |>
  readLines() |>
  as.POSIXct()

# timestamp_blog_github =
#   httr::GET("https://api.github.com/repos/mardenos-ufmg/website-blog") |>
#   httr::content(as = "text") |>
#   jsonlite::fromJSON() |>
#   purrr::pluck("pushed_at") |>
#   {\(.) substr(., 1, nchar(.)-1)}() |>
#   as.POSIXct()


timestamp_blog_local = as.POSIXct(readLines("stuff/timestamp_blog.txt"))

precisa_baixar_blog =
  (timestamp_blog_local < timestamp_blog_github) |>
  {\(.) ifelse(is.na(.), T, .)}()

if (precisa_baixar_blog) {
  root_dir = file.path(tempdir(), "blog")
  
  for (folder in c("posts", "img")) {
    dest_dir = file.path(root_dir, folder)
    url_api  = file.path("https://api.github.com/repos/mardenos-ufmg/website-blog/contents", folder)
    dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
    
    res = httr::GET(url_api)
    httr::stop_for_status(res)
    files = jsonlite::fromJSON(httr::content(res, as = "text"))
    
    for (f in files$name) {
      download_url = files$download_url[files$name == f]
      dest_file = file.path(dest_dir, f)
      download.file(download_url, dest_file, quiet = TRUE)
    }
    
    fs::dir_copy(dest_dir, file.path("blog", folder), overwrite = TRUE)
  }
  cat(as.character(Sys.time()), "\n", file = "stuff/timestamp_blog.txt")
  unlink(root_dir, recursive = TRUE)
  cat("\nblog OK\n")
}

source("stuff/funs.R")

gerar_bibliografia()