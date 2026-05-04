# shiny::shinyApp(fluidPage(ui(NS("teste"))), function(input, output, session) moduleServer("teste", server))

ui = function(ns) {
  header_col = function(title, color, height, width = 12) {
    column(
      width,
      div(
        style = paste0(
          "background-color:", color, ";",
          "color: #3e3e3e;",
          "font-size: 35px;",
          "height: calc(", height, "vh - 10px);",
          "line-height: calc(", height, "vh - 10px);",
          "text-align: center;",
          "margin: 5px 2.5px;",
          "border-radius: 10px;"
        ),
        title
      )
    )
  }
  
  fluidPage(
    
    fluidRow(header_col("Análise Fatorial com dados do SNIS", "#a8f2fe", 8)),
    fluidRow(header_col("Scores", "#a8f2fe", 8)),
    
    fluidRow(
      div(
        style = "display: inline-block; width: 200px; margin-right: 20px;",
        selectInput(ns("geral-ano"), "Ano", choices = as.character(2010:2021))
      ),
      div(
        style = "display: inline-block; width: 200px; margin-right: 20px;",
        selectInput(ns("fa-scores-var"), "Variável", choices = NULL)
      ),
      div(
        style = "display: inline-block; margin-top: 25px;",
        checkboxInput(ns("fa-scores-quart"), "Quartis", value = TRUE)
      )
    ),
    
    fluidRow(
      column(8, tmap::tmapOutput(ns("fa-scores-mapa"))),
      column(4,
             tableOutput(ns("fa-scores-summary")),
             verbatimTextOutput(ns("fa-scores-summary2"))
      )
    ),
    
    fluidRow(header_col("Loadings", "#a8f2fe", 8)),
    
    fluidRow(
      column(7,
             fluidRow(header_col("EEE", "#a8f2fe", 8)),
             plotOutput(ns("fa-loadings-eee"))
      ),
      column(5,
             fluidRow(header_col("SU", "#a8f2fe", 8)),
             plotOutput(ns("fa-loadings-su"))
      )
    )
  )
}


server = function(input, output, session) {
  # ---- dados ----
  devtools::load_all(here::here("autoindex/snis"))
  # load(here::here("autoindex/snis/data/dados_snis.rda"))
  # load(here::here("autoindex/snis/data/mapa_MG.rda"))
  # source(here::here("autoindex/snis/R/plots.R"))
  # source(here::here("autoindex/snis/R/utils.R"))
  library(dplyr)
  
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
    req(df(), input$`fa-scores-var`)
    
    df() %>%
      select(
        name = `município`,
        Score = all_of(input$`fa-scores-var`),
        Grupo = `região intermediária`,
        codigo = `código do município`
      ) %>%
      mutate(Score = round(Score, 4)) %>%
      distinct(name, .keep_all = TRUE) %>%
      left_join(mapa_MG, by = "name")
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
  
  # ---- mapa ----
  output$`fa-scores-mapa` = tmap::renderTmap({
    req(df(), input$`fa-scores-var`)
    
    suppressMessages(
      mapa_interativo(
        df(),
        var = input$`fa-scores-var`,
        quart = input$`fa-scores-quart`
      )
    )
  })
  
  # ---- resumo ----
  output$`fa-scores-summary` = renderTable({
    req(df(), input$`fa-scores-var`)
    
    df()[[input$`fa-scores-var`]] %>%
      summary() %>%
      as.matrix() %>%
      t() %>%
      as.data.frame()
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
    req(click$id)
    
    # índice vindo do tmap (geralmente "shape_XX")
    idx = suppressWarnings(as.integer(gsub("[^0-9]", "", click$id)))
    req(!is.na(idx))
    
    municipio = geo_df() %>%
      slice(idx) %>%
      pull(codigo)
    
    req(municipio)
    
    output$`fa-scores-summary2` = renderPrint({
      df() %>%
        filter(`código do município` == municipio) %>%
        select(
          `município`,
          `código do município`,
          `natureza jurídica`,
          `tipo de serviço`,
          `abrangência`,
          `código do prestador`,
          prestador
        )
    })
    
  })
}
#            div(
#              style = paste0(
#                "background-color:", color, ";",
#                "color: #3e3e3e;
#              font-size: 35px;
#              height: calc(",height,"vh - 10px);",
#                "line-height: calc(", height,"vh - 10px);",
#                "text-align: center;
#              margin: 5px 2.5px;
#              border-radius: 10px;
#              "),
#              title
#            )
#     )
#   }
#   
#   fluidPage(
#   fluidRow(header_col("Análise Fatorial com dados do SNIS", "#a8f2fe", 8)),
#   fluidRow(header_col("Scores", "#a8f2fe", 8)),
#   
#   fluidRow(
#     div(
#       style = "display: inline-block; width: 200px; margin-right: 20px;",
#       selectInput("geral-ano", label = "Ano", choices = as.character(2010:2021))
#     ),
#     div(
#       style = "display: inline-block; width: 200px; margin-right: 20px;",
#       selectInput("fa-scores-var", label = "Variável", choices = "")
#     ),
#     div(
#       style = "display: inline-block; margin-top: 25px;",
#       checkboxInput("fa-scores-quart", "Quartis", value = TRUE)
#     )
#   ),
#   
#   fluidRow(
#     column(8,
#       tmap::tmapOutput("fa-scores-mapa")
#     ),
#     column(4,
#       fluidRow(tableOutput("fa-scores-summary")),
#       fluidRow(verbatimTextOutput("fa-scores-summary2"))
#   
#     )
#   ),
#   
#   fluidRow(header_col("Loadings", "#a8f2fe", 8)),
#   
#   fluidRow(
#     column(7,
#       fluidRow(header_col("EEE", "#a8f2fe", 8)),
#       plotOutput("fa-loadings-eee")
#     ),
#     column(5,
#       fluidRow(header_col("SU", "#a8f2fe", 8)),
#       plotOutput("fa-loadings-su")
#       )
#     )
#   )
# }
  

# ui = function(ns) {
#   fluidPage(
#     
#     selectInput(ns("geral-ano"), "Ano", choices = as.character(2010:2021)),
#     
#     selectInput(ns("fa-scores-var"), "Variável", choices = ""),
#     
#     checkboxInput(ns("fa-scores-quart"), "Quartis", value = TRUE),
#     
#     tmap::tmapOutput(ns("fa-scores-mapa")),
#     
#     tableOutput(ns("fa-scores-summary")),
#     verbatimTextOutput(ns("fa-scores-summary2")),
#     
#     plotOutput(ns("fa-loadings-eee")),
#     plotOutput(ns("fa-loadings-su"))
#   )
# }
# 
# server = function(input, output, session) {
#   load(here::here("autoindex/snis/data/dados_snis.rda"))
#   load(here::here("autoindex/snis/data/mapa_MG.rda"))
#   source(here::here("autoindex/snis/R/plots.R"))
#   source(here::here("autoindex/snis/R/utils.R"))
#   
#   tmap::tmap_mode("view")
#   library(tidyverse)
#   
#   ###  Reactive  ###
#   ano   = reactive({ input$"geral-ano" })
#   #var   = reactive({ input$"fa-scores-var" })
#   #quart = reactive({ input$"fa-scores-quart" })
#   df    = reactive({ dados_snis[[ano()]]$df })
#   geo_df = reactive({
#     df() %>%
#       select(
#         name = all_of("município"),
#         Score = all_of(input$"fa-scores-var"),
#         Grupo = all_of("região intermediária")
#       ) %>%
#       mutate(Score = round(Score, 4)) %>%
#       distinct(name, .keep_all = TRUE) %>%
#       left_join(x = mapa_MG, by = "name")
#   })
# 
#   ###  PainelFA  ###
#   output$"fa-scores-mapa" = tmap::renderTmap({
#     req(df(), input$"fa-scores-var")
#     mapa_interativo(df(), var = input$"fa-scores-var", quart = input$"fa-scores-quart") |> suppressMessages()
#     # plot_map(df(), var = input$"fa-scores-var", quart = input$"fa-scores-quart") |>
#     #   plotly::ggplotly()
#   })
# 
#   observeEvent(df(), {
#     updateSelectInput(session, "fa-scores-var",
#       #choices = colnames(df())
#       choices = c("score médio eee", "score efetividade", "score eficácia", "score eficiência", "score médio su", "score sustentabilidade", "score universalidade")
#     )
#   })
# 
#   output$"fa-scores-summary" = renderTable({
#     req(df())
#     df()[[ input$"fa-scores-var" ]] |>
#       summary() |>
#       as.matrix() |>
#       t() |>
#       as.data.frame()
#   })
# 
#   output$"fa-loadings-eee" = renderPlot({
#     req(ano())
#     #FA_EEE = fa(df(), features = readODS::read_ods("data/features.ods", sheet = "EEE"))
#     plot_loading(dados_snis[[ano()]]$fa$eee)
#   })
# 
#   output$"fa-loadings-su" = renderPlot({
#     req(ano())
#     #FA_SU = fa(df(), features = readODS::read_ods("data/features.ods", sheet = "SU"))
#     plot_loading(dados_snis[[ano()]]$fa$su)
#   })
#   
#   observeEvent(input$"fa-scores-mapa_shape_click", {
#     click = input$"fa-scores-mapa_shape_click"
# 
#     click_municipio =
#       geo_df() |>
#       slice(as.integer(substring(click$id,2))) |>
#       as_tibble() |>
#       pull("id") |>
#       as.integer()
# 
#     output$"fa-scores-summary2" = renderPrint({
#       df() |>
#         filter(`código do município` == click_municipio) |>
#         select(all_of(c(
#           "município", "código do município", "natureza jurídica", "tipo de serviço", "abrangência", "código do prestador", "prestador"
#           )))
#     })
# 
#   })
# }
