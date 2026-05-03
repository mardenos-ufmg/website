#library(shiny)

cota_ui <- fluidPage(
  titlePanel("Meu primeiro app Shiny"),
  
  sidebarLayout(
    sidebarPanel(
      actionButton("btn", "Clique aqui")
    ),
    
    mainPanel(
      h3("Número de cliques:"),
      textOutput("contador")
    )
  )
)

cota_server <- function(input, output, session) {
  
  contador <- reactiveVal(0)
  
  observeEvent(input$btn, {
    contador(contador() + 1)
  })
  
  output$contador <- renderText({
    contador()
  })
}

