library(shiny)
source(here::here("stuff/shiny-styles.R"))

ui = fluidPage(
  tagList(
    styles$topbar$style,
    styles$styles,
    styles$topbar$ui
  ),
  tagList(div(class = "mdn-container",
              
  div(class = "mdn-header", "Análise fatorial com dados do SNIS"),
  fluidRow(
    div(
      style = "display: inline-block; width: 200px; margin-right: 20px;",
      selectInput("geral-ano", "Ano", choices = as.character(2010:2021))
    ),
    div(
      style = "display: inline-block; width: 200px; margin-right: 20px;",
      selectInput("fa-scores-var", "Variável", choices = NULL)
    ),
    div(
      style = "display: inline-block; margin-top: 25px;",
      checkboxInput("fa-scores-quart", "Quartis", value = TRUE)
    )
  ),
  
  fluidRow(style = "height: 500px;",
    column(8, tmap::tmapOutput("fa-scores-mapa")),
    column(4, plotOutput("fa-scores-summary-plot"))
  ),
  fluidRow(column(12, DT::dataTableOutput("fa-scores-summary"))),
    
  section("Loadings (EEE e SU)",
    fluidRow(
      column(7, plotOutput("fa-loadings-eee")),
      column(5, plotOutput("fa-loadings-su"))
    ),
    collapse = T
  )
  
  ))
)


server = function(input, output, session) {
  # ---- dados ----
  devtools::load_all(here::here("autoindex/snis"))
  # load(here::here("autoindex/snis/data/dados_snis.rda"))
  # load(here::here("autoindex/snis/data/mapa_MG.rda"))
  # source(here::here("autoindex/snis/R/plots.R"))
  # source(here::here("autoindex/snis/R/utils.R"))
  library(dplyr)
  
  plot_hist = function(var) {
    ggplot(df(), aes(x = .data[[var]])) +
      geom_histogram(aes(y = after_stat(count / sum(count))),
                     bins = 10,
                     fill = "lightblue",
                     color = "white") +
      labs(
        title = paste0(var, " em MG, ", ano()),
        y = "Frequência relativa",
        x = var
      ) +
      xlim(0,1) +
      theme_minimal() +
      theme(panel.grid.major = element_blank())
  }
  
  # ---- reactives ----
  ano = reactive({
    req(input$`geral-ano`)
    input$`geral-ano`
  })
  
  df = reactive({
    req(ano())
    dados_snis[[ano()]]$df
  })
  
  geo_df = reactive({
    df() %>%
      select(
        name = all_of("município"),
        `código do município` = "código do município",
        Score = all_of(input$`fa-scores-var`),
        Grupo = all_of("região intermediária")
      ) %>%
      mutate(Score = round(Score, 4)) %>%
      distinct(name, .keep_all = TRUE) %>%
      left_join(x = mapa_MG, by = "name") |>
      rename(municipio = "name", score = "Score")
  })
  
  
  # ---- atualizar variável ----
  observeEvent(df(), {
    updateSelectInput(
      session,
      "fa-scores-var",
      choices = c(
        "score médio eee",
        "score efetividade",
        "score eficácia",
        "score eficiência",
        "score médio su",
        "score sustentabilidade",
        "score universalidade"
      )
    )
  }, ignoreInit = TRUE)
  
  observeEvent(input$`fa-scores-var`, {
    output$"fa-scores-summary-plot" = renderPlot({
      plot_hist(input$`fa-scores-var`)
    })
  })
  
  # ---- mapa ----
  output$`fa-scores-mapa` = tmap::renderTmap({
    suppressWarnings(suppressMessages(
      
    tmap::tm_shape(geo_df(), bbox = sf::st_bbox( filter(geo_df(), !is.na(score)) )) +
      tmap::tm_fill(
        col = "score",
        title = "Legenda",
        style = "cont",
        palette = viridis::turbo(100, direction = -1),
        popup.vars = c("municipio", "score")
      ) +
      tmap::tm_borders(col = "gray50", lwd = 0.5) +
      tmap::tm_basemap(server = "OpenStreetMap") +
      tmap::tm_layout(
        main.title = paste0("Mapa Interativo de ", input$`fa-scores-var`, " em MG, ", ano()),
        main.title.position = "center",
        legend.outside = TRUE
      )
    
    ))
  })
  
  # ---- loadings ----
  output$`fa-loadings-eee` = renderPlot({
    req(ano())
    plot_loading(dados_snis[[ano()]]$fa$eee)
  })
  
  output$`fa-loadings-su` = renderPlot({
    req(ano())
    plot_loading(dados_snis[[ano()]]$fa$su)
  })
  
  # ---- clique no mapa ----
  observeEvent(input$`fa-scores-mapa_shape_click`, {
    click = input$`fa-scores-mapa_shape_click`
    idx = suppressWarnings(as.integer(gsub("[^0-9]", "", click$id)))
    municipio = geo_df()[idx,] |> pull("código do município")
    
    # req(click$id)
    # req(!is.na(idx))
    # print(click$id)
    # print(idx)
    # print(municipio)
    
    output$`fa-scores-summary` = DT::renderDataTable({
      df() %>%
        filter(`código do município` == municipio) %>%
        select(
          `município`,
          `natureza jurídica`,
          `tipo de serviço`,
          prestador,
          starts_with("score ")
        ) |>
        dplyr::mutate(
          dplyr::across(where(is.numeric), ~ round(.x, 4))
        )
    }, rownames = FALSE, options = list(dom = "t", paging = FALSE, scrollX = TRUE, ordering = FALSE))
    
    output$"fa-scores-summary-plot" = renderPlot({
      x = df() |> filter(`código do município` == municipio) |> pull(input$`fa-scores-var`)
      municipio_nome = df() |> filter(`código do município` == municipio) |> pull("município")

      p =
        plot_hist(input$`fa-scores-var`) +
        geom_vline(xintercept = x, color = "red")
      
      ymax = ggplot_build(p)$data[[1]]$y |> max()
      
      p +
        annotate("text",
                 x = x + 0.02,
                 y = ymax,
                 label = municipio_nome,
                 hjust = 0,
                 vjust = -0.5,
                 color = "red")
    })
    
  })
}

shinyApp(ui, server)
