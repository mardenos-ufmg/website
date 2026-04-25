source("stuff/pacotes.R")
instalar_pacotes()

ultima_alteracao_snis =
  list.files("autoindex/snis", full.names = TRUE) |>
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
  pkgdown::build_site("autoindex/snis", install = TRUE)
  cat(as.character(Sys.time()), "\n", file = "stuff/timestamp_snis_docs.txt")
  cat("pkgdown OK\n")
}


# timestamp_blog_github =
#   "https://raw.githubusercontent.com/mardenos-ufmg/website-blog/refs/heads/main/timestamp.txt" |>
#   readLines() |>
#   as.POSIXct()

# timestamp_blog_github =
#   httr::GET("https://api.github.com/repos/mardenos-ufmg/website-blog") |>
#   httr::content(as = "text") |>
#   jsonlite::fromJSON() |>
#   purrr::pluck("pushed_at") |>
#   {\(.) substr(., 1, nchar(.)-1)}() |>
#   as.POSIXct()

timestamp_blog_github = tryCatch({
  res =
    httr::GET("https://api.github.com/repos/mardenos-ufmg/website-blog") |>
    httr::content(as = "text") |>
    jsonlite::fromJSON() |>
    purrr::pluck("pushed_at")
  
  if (is.null(res) || is.na(res)) stop("Sem data")
  
  substr(res, 1, nchar(res) - 1) |>
    `substr<-`(11,11," ") |>
    as.POSIXct(tz = "UTC")
}, error = function(e) {
  as.POSIXct("1900-01-01", tz = "UTC")
})

timestamp_blog_local = as.POSIXct(readLines("stuff/timestamp_blog.txt"))

precisa_baixar_blog =
  (timestamp_blog_local < timestamp_blog_github) |>
  {\(.) ifelse(is.na(.), T, .)}()

if (precisa_baixar_blog) { try({
  repo_github = "https://github.com/mardenos-ufmg/website.git"
  destino_temp = file.path(tempdir(), "github-blog")
  
  if (dir.exists(destino_temp)) unlink(destino_temp, recursive = T)
  dir.create(destino_temp)
  system(paste("git clone", repo_github, destino_temp))
  
  destino_website = "blog/posts"
  fs::dir_copy(file.path(destino_temp, "posts"), destino_website, overwrite = TRUE)
  unlink(destino_temp, recursive = T)
  
  df_posts =
    c("title", "subtitle", "author", "date") |>
    {\(.) matrix(nrow=0, ncol=length(.)) |> as.data.frame() |> `colnames<-`(.) }()
  files = list.files(destino_website, full.names = T) |> {\(.) .[!file.info(.)$isdir]}()
  for (file in files) {
    df_posts[nrow(df_posts)+1,] = 
      readLines(file) |>
      {\(.) .[2:max(which(.=="---")-1)]}() |>
      yaml::yaml.load() |>
      {\(.) .[c("title", "subtitle", "author", "date")]}() |>
      as.data.frame.list()
  }
  
  cat(as.character(Sys.time()), "\n", file = "stuff/timestamp_blog.txt")
  
  df_posts |>
    dplyr::mutate(date = format(as.Date(.data$date), "%d/%m/%Y")) |>
    dplyr::arrange(.data$date) |>
    {\(.) .[nrow(.),]}() |>
    as.list.data.frame() |>
    saveRDS("stuff/df_ultimo_post.rds")
  
  cat("\nblog OK\n")
})}

source("stuff/funs.R")

try(gerar_bibliografia())