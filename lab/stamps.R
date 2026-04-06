
timestamp_github_blog =
  httr::GET("https://api.github.com/repos/mardenos-ufmg/website-blog") |>
  httr::content(as = "text") |>
  jsonlite::fromJSON() |>
  purrr::pluck("pushed_at") |>
  {\(.) substr(., 1, nchar(.)-1)}() |>
  as.POSIXct()

googledrive::drive_get("https://docs.google.com/spreadsheets/d/1P0u8OA5ZZtis5zEfhBOh4GcWrvbUxLWgxJlOlMPxGqU") |>
  purrr::pluck("drive_resource") |>
  purrr::pluck(1) |>
  purrr::pluck("modifiedTime")

  httr::GET("https://docs.google.com/spreadsheets/d/1P0u8OA5ZZtis5zEfhBOh4GcWrvbUxLWgxJlOlMPxGqU?fields=modifiedTime") |>
  httr::content() |>
  jsonlite::fromJSON()
  purrr::pluck("modifiedTime")
