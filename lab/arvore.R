library(shiny)
source("stuff/funs.R")
source("dashboards/topbar.R")

ui = tagList(
  topbar_style,
  topbar_ui,
  fluidPage(
    theme = bs_theme(version = 5),
    titlePanel("Árvore de Arquivos"),
    fluidRow(column(12, verbatimTextOutput("node_info"))),
    fluidRow(column(12, collapsibleTree::collapsibleTreeOutput("tree", height = "700px")))
  )
)

server = function(input, output, session) {
  arvore = gerar_arvore()
  
  output$tree = collapsibleTree::renderCollapsibleTree({
    widget = arvore$widget
    widget
    })
  
  output$node_info = renderPrint({
    path = input$selected_node |> unlist() |> {\(.) c("website", .)}() |> paste0(collapse = "/")
    arvore$df |>
      {\(.) .[.$pathString==path,]}()
  })
}

shinyApp(ui, server)