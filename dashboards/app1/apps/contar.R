
ui <- function(ns) {
  fluidPage(
    titlePanel("App Contar"),
    sidebarLayout(
      sidebarPanel(
        actionButton(ns("btn"), "Clique aqui")
      ),
      mainPanel(
        h3("Número de cliques:"),
        textOutput(ns("contador"))
      )
    )
  )
}

server <- function(input, output, session) {
  contador <- reactiveVal(0)
  observeEvent(input$btn, {
    contador(contador() + 1)
  })
  output$contador <- renderText({
    contador()
  })
}

