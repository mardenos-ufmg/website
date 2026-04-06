library(shiny)

ui = fluidPage(
  titlePanel("Árvore de Arquivos"),
  fluidRow(column(12, verbatimTextOutput("node_info"))),
  fluidRow(column(12, collapsibleTree::collapsibleTreeOutput("tree", height = "700px")))
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