library(shiny)
library(dplyr)
library(tidyr)
library(lubridate)
library(plotly)
library(stringr)

# ── Unidades por variável ──────────────────────────────────────────────────────
VAR_META <- list(
  afluencia     = list(label = "Afluência",     unit = "m³/s",  color = "#1f77b4"),
  defluencia    = list(label = "Defluência",    unit = "m³/s",  color = "#d62728"),
  nivel         = list(label = "Nível",         unit = "m",     color = "#2ca02c"),
  volume        = list(label = "Volume útil",   unit = "%",     color = "#9467bd"),
  precipitacao  = list(label = "Precipitação",  unit = "mm",    color = "#17becf"),
  temperatura   = list(label = "Temperatura",   unit = "°C",    color = "#ff7f0e"),
  umidade       = list(label = "Umidade",       unit = "%",     color = "#8c564b"),
  radiacao      = list(label = "Radiação",      unit = "W/m²",  color = "#e377c2")
)

ALL_VARS  <- names(VAR_META)
VAR_LABELS <- setNames(sapply(VAR_META, `[[`, "label"), ALL_VARS)

# ── Leitura e limpeza dos dados ────────────────────────────────────────────────
read_clean_csv <- function(path) {
  if (!file.exists(path)) return(NULL)
  read.csv(path, stringsAsFactors = FALSE)
}

load_data <- function() {
  ana_path   <- "data/ana_furnas_dia.csv"
  meteo_path <- "data/meteo_furnas.csv"

  if (!file.exists(ana_path)) {
    # dados de exemplo para demonstração
    set.seed(42)
    dates <- seq(as.Date("2010-01-01"), as.Date("2025-09-30"), by = "day")
    n <- length(dates)
    df <- tibble(
      data         = format(dates, "%Y-%m-%d"),
      afluencia    = abs(rnorm(n, 400, 150)),
      defluencia   = abs(rnorm(n, 800, 200)),
      nivel        = 760 + cumsum(rnorm(n, 0, 0.05)) %% 10,
      volume       = 50 + cumsum(rnorm(n, 0, 0.1)) %% 40,
      precipitacao = abs(rnorm(n, 150, 100)),
      temperatura  = 22 + sin(seq(0, 4 * pi, length.out = n)) * 4 + rnorm(n, 0, 1),
      umidade      = 60 + rnorm(n, 0, 5),
      radiacao     = abs(rnorm(n, 8e6, 5e5))
    )
    return(df)
  }

  fix_num <- function(x) x |> str_replace("[.]", "") |> str_replace(",", ".") |> as.numeric()

  df_ana <- read.csv(ana_path, stringsAsFactors = FALSE) |>
    filter(nome == "FURNAS") |>
    select(-nome) |>
    rename(data = "data_referencia", volume = "volume_util") |>
    as_tibble() |>
    mutate(
      data = format(as.Date(data, "%d/%m/%Y"), "%Y-%m-%d"),
      across(c(afluencia, defluencia, nivel, volume), fix_num)
    )

  if (file.exists(meteo_path)) {
    df_meteo <- read.csv(meteo_path, stringsAsFactors = FALSE)
    df_ana <- left_join(df_ana, df_meteo, by = "data")
  }

  df_ana
}

df_global <- tryCatch(load_data(), error = function(e) NULL)

# ── UI ────────────────────────────────────────────────────────────────────────
ui <- fluidPage(
  tags$head(tags$style(HTML("
    body { background: #f5f5f5; font-family: 'Helvetica Neue', Arial, sans-serif; }
    .sidebar-panel {
      background: #fff;
      border-radius: 6px;
      padding: 16px;
      box-shadow: 0 1px 4px rgba(0,0,0,.1);
    }
    .main-panel {
      background: #fff;
      border-radius: 6px;
      padding: 12px;
      box-shadow: 0 1px 4px rgba(0,0,0,.1);
    }
    h4 { font-weight: 600; margin-bottom: 12px; }
    .shiny-input-container { margin-bottom: 10px; }
  "))),

  titlePanel("Reservatório de Furnas — Série Temporal"),

  sidebarLayout(
    sidebarPanel(
      width = 3,
      div(class = "sidebar-panel",
        h4("Variáveis"),
        checkboxGroupInput(
          "vars", label = NULL,
          choices  = setNames(ALL_VARS, unname(VAR_LABELS)),
          selected = c("nivel", "volume", "afluencia")
        ),
        hr(),
        h4("Período"),
        dateRangeInput(
          "periodo", label = NULL,
          start = "2015-01-01",
          end   = Sys.Date(),
          min   = "2010-01-01",
          max   = Sys.Date(),
          format = "dd/mm/yyyy",
          language = "pt"
        ),
        hr(),
        radioButtons(
          "agregacao", "Agregação",
          choices  = c("Diário" = "day", "Mensal" = "month", "Anual" = "year"),
          selected = "day"
        )
      )
    ),

    mainPanel(
      width = 9,
      div(class = "main-panel",
        plotlyOutput("plot_ts", height = "560px")
      )
    )
  )
)

# ── Server ────────────────────────────────────────────────────────────────────
server <- function(input, output, session) {

  df_filtered <- reactive({
    req(df_global, input$vars, input$periodo)
    vars_sel <- input$vars

    df <- df_global |>
      filter(data >= format(input$periodo[1]), data <= format(input$periodo[2])) |>
      select(data, all_of(vars_sel)) |>
      mutate(data = as.Date(data))

    # Agregação
    if (input$agregacao != "day") {
      df <- df |>
        mutate(periodo = floor_date(data, input$agregacao)) |>
        group_by(periodo) |>
        summarise(across(all_of(vars_sel), mean, na.rm = TRUE), .groups = "drop") |>
        rename(data = periodo)
    }

    df
  })

  output$plot_ts <- renderPlotly({
    df  <- df_filtered()
    vars_sel <- input$vars
    req(length(vars_sel) >= 1)

    # Agrupa variáveis por unidade para alocar eixos
    units_used <- unique(sapply(vars_sel, function(v) VAR_META[[v]]$unit))
    unit_axis  <- setNames(seq_along(units_used), units_used)  # unit -> axis number

    # Normaliza cada série para [0,1] para sobreposição visual
    normalize <- function(x) {
      rng <- range(x, na.rm = TRUE)
      if (diff(rng) == 0) return(rep(0.5, length(x)))
      (x - rng[1]) / diff(rng)
    }

    p <- plot_ly()

    for (v in vars_sel) {
      meta  <- VAR_META[[v]]
      unit  <- meta$unit
      ax_n  <- unit_axis[[unit]]
      yaxis <- if (ax_n == 1) "y" else paste0("y", ax_n)

      y_norm <- normalize(df[[v]])

      # Tooltip mostra valor real
      hover_text <- paste0(
        "<b>", meta$label, "</b><br>",
        format(df$data, "%d/%m/%Y"), "<br>",
        round(df[[v]], 2), " ", unit
      )

      p <- add_trace(
        p,
        x         = df$data,
        y         = y_norm,
        type      = "scatter",
        mode      = "lines",
        name      = paste0(meta$label, " (", unit, ")"),
        yaxis     = yaxis,
        line      = list(color = meta$color, width = 1.5),
        text      = hover_text,
        hoverinfo = "text"
      )
    }

    # Constrói eixos Y invisíveis (normalizados [0,1]) com título = unidade
    layout_args <- list(
      p,
      hovermode = "x unified",
      legend    = list(orientation = "h", y = -0.15),
      margin    = list(l = 60, r = 60, t = 40, b = 80),
      xaxis     = list(title = "", showgrid = TRUE, gridcolor = "#eeeeee"),
      plot_bgcolor  = "#ffffff",
      paper_bgcolor = "#ffffff"
    )

    for (unit in units_used) {
      ax_n     <- unit_axis[[unit]]
      ax_name  <- if (ax_n == 1) "yaxis" else paste0("yaxis", ax_n)

      # Variáveis desta unidade — para tickvals personalizados
      v_unit <- vars_sel[sapply(vars_sel, function(v) VAR_META[[v]]$unit == unit)]

      # Usa a primeira variável da unidade para referência de ticks
      ref_var  <- v_unit[1]
      ref_vals <- df[[ref_var]]
      rng_real <- range(ref_vals, na.rm = TRUE)

      tick_real <- pretty(ref_vals, n = 5)
      tick_norm <- (tick_real - rng_real[1]) / diff(rng_real)

      # Clipa para [0,1]
      keep      <- tick_norm >= 0 & tick_norm <= 1
      tick_real <- tick_real[keep]
      tick_norm <- tick_norm[keep]

      side <- if (ax_n %% 2 == 1) "left" else "right"
      overlaying <- if (ax_n == 1) NULL else "y"

      layout_args[[ax_name]] <- list(
        title      = unit,
        side       = side,
        overlaying = overlaying,
        showgrid   = (ax_n == 1),
        gridcolor  = "#eeeeee",
        zeroline   = FALSE,
        tickvals   = tick_norm,
        ticktext   = round(tick_real, 1),
        range      = c(-0.05, 1.05),
        anchor     = "x"
      )
    }

    do.call(layout, layout_args)
  })
}

shinyApp(ui, server)
