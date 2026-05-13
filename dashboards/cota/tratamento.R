library(tidyverse)

df =
  read.csv("dashboards/cota/data/ana_furnas_dia.csv") |>
  filter(nome == "FURNAS") |>
  select(-nome) |>
  rename(data = "data_referencia", volume = "volume_util") |>
  as_tibble() |>
  mutate(
    data = format(as.Date(data, "%d/%m/%Y"), "%Y-%m-%d"),
    across(c(afluencia, defluencia, nivel, volume),
           function(x) x |> str_replace("[.]", "") |> str_replace(",", ".") |> as.numeric()
           )
    ) |>
  left_join(read.csv("dashboards/cota/data/meteo_furnas.csv"), by = "data")


