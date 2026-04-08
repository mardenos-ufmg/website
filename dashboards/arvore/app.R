library(shiny)
source("dashboards/arvore/funs.R")
source("dashboards/topbar.R")

ui = tagList(
  tags$style(HTML("
  .path-sans {
    font-family: sans-serif;
  }
  .title-panel {
      text-align: center;
  }
   ")),
  topbar_style,
  topbar_ui,
  fluidPage(
    titlePanel(div("Árvore de Arquivos", class = "title-panel")),
    fluidRow(column(12, uiOutput("node_info"))),
    fluidRow(column(12, collapsibleTree::collapsibleTreeOutput("tree", height = "700px")))
  )
)

server = function(input, output, session) {
  df = arvore_io("ler")
  
  output$tree = collapsibleTree::renderCollapsibleTree({
    arvore_gerar_widget(df)
    })
  
  output$node_info = renderUI({
    path = input$selected_node |>
      unlist() |>
      {\(.) c("website", .)}() |>
      paste0(collapse = "/")
    
    row = df[df$path == path, ]
    
    if(nrow(row) == 0) return(NULL)
    
    tipo = row$type
    size = paste0(row$size_kb, " KB")
    descricao = ifelse(is.na(row$descricao), "—", row$descricao)
    palavras_chave = ifelse(is.na(row$palavras_chave), "—", row$palavras_chave)
    
    tagList(
      tags$h4(paste0(path, "   (", tipo, ", ", size, ")"), class = "path-sans"),
      tags$p(strong("Palavras-chave: "), palavras_chave),
      tags$p(strong("Descrição: "), descricao)
    )
  })
  
  # output$node_info = renderPrint({
  #   path = input$selected_node |> unlist() |> {\(.) c("website", .)}() |> paste0(collapse = "/")
  #   df |>
  #     {\(.) .[.$path==path,]}()
  # })
}

shinyApp(ui, server)