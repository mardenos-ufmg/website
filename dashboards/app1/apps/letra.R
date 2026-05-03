ui <- function(ns) {
  fluidPage(
    titlePanel("App Letra"),
    sidebarLayout(
      sidebarPanel(
        selectInput(ns("col"), "Selecionar coluna", LETTERS)
      ),
      mainPanel(
        h3("Próxima letra:"),
        textOutput(ns("letra"))
      )
    )
  )
}

server <- function(input, output, session) {
  output$letra <- renderText({
    index <- which(LETTERS == input$col) + 1
    if (index <= 26) LETTERS[index] else "Não tem"
  })
}

