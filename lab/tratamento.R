library(tidyverse)

meteo = data.frame()
for (ano in 2010:2026) {
  df_temp =
    get_data(stations = c("A524", "A516"),
            first.day = paste0(ano, "-01-01"),
            last.day  = paste0(ano, "-12-31"),
            vars = c("precipitation", "temperature_air", "humidity", "radiation", "wind_burst")) |>
    mutate(
      across(
        everything(),
        function(x) ifelse(x==-9999,NA,x)
      ),
      time = substr(time, 1, 10)
    ) |>
    group_by(time) |>
    summarise(
      precipitacao = mean(precipitation, na.rm = TRUE),
      temperatura  = mean(temperature_air, na.rm = TRUE),
      umidade      = mean(humidity, na.rm = TRUE),
      radiacao     = mean(radiation, na.rm = TRUE),
      .groups = "drop"
    ) |>
    rename(data = "time") |>
    mutate(
      data = format(as.Date(data, "%Y/%m/%d"), "%Y-%m-%d")
    )

  meteo = rbind(meteo, df_temp)
  cat("\n", ano, "\tOK")
}



write.csv(meteo, "~/Downloads/meteo_furnas.csv", row.names = F)


ana =
  read.csv("~/Downloads/reservatorios_parana_20260511_033016.csv") |>
  as_tibble() |>
  filter(nome == "FURNAS") |>
  mutate(
    across(
      c(afluencia, defluencia, nivel, volume_util),
      function(x) str_replace(x, "[.]", "") |> str_replace(",", ".") |> as.numeric()
      ),
  ) |>
  rename(
    data = "data_referencia",
    reservatorio = "nome"
  ) |>
  mutate(
    data = format(as.Date(data, "%d/%m/%Y"), "%Y-%m-%d")
  ) |>
  relocate(reservatorio)

write.csv(ana, "~/Downloads/ana_furnas.csv", row.names = F)

