shiny_app = function(ui, server) {
  source(here::here("stuff/shiny-bar.R"))
  server_ = function(input, output, session) {
    addResourcePath("assets", here::here("stuff"))
    moduleServer("teste", server)
  }
  
  shiny::shinyApp(fluidPage(tagList(styles$topbar$style, styles$sidebar$style, styles$styles), ui(NS("teste"))), server_)
}
