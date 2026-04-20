library(shiny)
source("dashboards/topbar.R")

ui = tagList(
  topbar_style,
  topbar_ui,
  fluidPage(
    titlePanel(div("Árvore de Arquivos", class = "title-panel")),
    fluidRow(column(12, uiOutput("node_info"))),
    fluidRow(column(12, collapsibleTree::collapsibleTreeOutput("tree", height = "700px")))
  )
)

server = function(input, output, session) {
}

shinyApp(ui, server)