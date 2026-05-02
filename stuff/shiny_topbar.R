topbar = list()

topbar$style =
  tags$head(
  tags$link(rel = "shortcut icon", href = here::here("/stuff/favicon.ico")),
  tags$style(HTML("
      .topbar {
        background-color: #2c3e50;
        color: white;
        padding: 2.6rem 1.5rem;
        
        font-family: 'Lato', sans-serif;
        font-size: 1.8rem;
        font-weight: 300;

        display: flex;
        align-items: center;
        justify-content: space-between;
        
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        position: sticky;
        top: 0;
        z-index: 1000;
        margin-left: calc(-50vw + 50%);
        margin-bottom: 2rem;
      }
      .topbar .left, .topbar .right {
        display: flex;
        align-items: center;
        gap: 35px;
      }
      .topbar .right {
        margin-right: 120px;
      }
      .topbar a {
        color: white;
        text-decoration: none;
      }
      .topbar a:hover {
        text-decoration: underline;
      }
      .logo {
        font-weight: bold;
        font-size: 18px;
        margin-left: 20px;
      }
    "))
)

topbar$ui =
div(class = "topbar",
    div(class = "left",
        a(class = "logo", href = "/index.html", img(src = "stuff/favicon.png", height = "20px", style = "margin-right: 10px;"), "Mar de Nós"),
        a("Sobre nós", href = "sobre/index.html"),
        a("Blog", href = "/blog/index.html"),
        a("Apps", href = "/app.html"),
        a("Dados", href = "/dados.html"),
        a("Bibliografia", href = "/bibliografia.html")
    ),
    
    div(class = "right",
        a(icon("github"), href = "https://github.com/mardenos-ufmg"),
        a(icon("instagram"), href = "https://instagram.com/mar.de.nos_ufmg"),
        a(icon("envelope"), href = "mailto:mardenos.ufmg@gmail.com")
    )
)

# usage example
# 
# ui = tagList(
#   topbar$style,
#   topbar$ui,
#   fluidPage(
#     titlePanel(div("Árvore de Arquivos", class = "title-panel")),
#     fluidRow(column(12, uiOutput("node_info"))),
#     fluidRow(column(12, collapsibleTree::collapsibleTreeOutput("tree", height = "700px")))
#   )
# )
# 
# shinyApp(ui, function(input, output, session){})
