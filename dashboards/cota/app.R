library(shiny)
source(here::here("stuff/shiny-styles.R"))

ui = fluidPage(
  tagList(
    styles$topbar$style,
    styles$styles,
    styles$topbar$ui
  ),
  titlePanel("Cota do Lago de Furnas"),
  
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

server = function(input, output, session) {
  
  contador <- reactiveVal(0)
  
  observeEvent(input$btn, {
    contador(contador() + 1)
  })
  
  output$contador <- renderText({
    contador()
  })
}

shinyApp(ui, server)
