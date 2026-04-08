library(shiny)
library(bslib)

ui <- fluidPage(
  theme = bs_theme(version = 5),
  # CSS customizado
  tags$head(
    tags$style(HTML("
      .topbar {
        background-color: #2c3e50;
        color: white;
        padding: 0.75rem 1.5rem;
        display: flex;
        align-items: center;
        justify-content: space-between;
        font-family: 'Lato', sans-serif;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        position: sticky;
        top: 0;
        z-index: 1000;
        margin-left: calc(-50vw + 50%);
      }
      .topbar .left, .topbar .right {
        display: flex;
        align-items: center;
        gap: 35px;
      }
      .topbar a {
        color: white;
        text-decoration: none;
        font-weight: 300;
      }
      .topbar a:hover {
        text-decoration: underline;
      }
      .logo {
        font-weight: bold;
        font-size: 18px;
      }
    "))
  ),
  
  # Cabeçalho
  div(class = "topbar",
      
      div(class = "left",
          div(class = "logo", "Mar de Nós"),
          a("Sobre nós", href = "#"),
          a("Blog", href = "#"),
          a("Dashboards", href = "#"),
          a("Repositório de dados", href = "#"),
          a("Bibliografia", href = "#"),
          a("4devs", href = "#")
      ),
      
      div(class = "right",
          a(icon("github"), href = "#"),
          a(icon("instagram"), href = "#"),
          a(icon("envelope"), href = "#")
      )
  ),
  
  # Conteúdo da página
  fluidRow(
    column(12, h2("Conteúdo aqui"))
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)