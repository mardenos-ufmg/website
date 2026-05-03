topbar = list()

topbar$style =
  tags$head(
  tags$link(rel = "shortcut icon", href = "/stuff/favicon.ico"),
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
      .section-header {
        font-size: 1.2rem;
        font-weight: bold;
        opacity: 0.8;
        margin-top: 40px;
        margin-bottom: 5px;
        text-transform: uppercase;
        letter-spacing: 1px;
      }
      .topbar .right {
        margin-right: 130px;
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
        a(class = "logo", href = "/index.html", img(src = "/stuff/favicon.png", height = "20px", style = "margin-right: 10px;"), "Mar de Nós"),
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




sidebar = list()

# sidebar$ui = div(
#   class = "sidebar",
#   div(class = "title", "Apps"),
#   div(class = "section-header", "Aplicativos"),
#   div(
#     class = "section",
#     lapply(as.list(list.files("dashboards")), function(name) {
#       a(name, href = paste0("app/", name))
#     })
#   ),
#   div(class = "sidebar-footer", "Mar de Nós - UFMG")
# )

sidebar$ui = function(app_names) {
  div(
    class = "sidebar",
    div(class = "title", "Apps"),
    div(class = "section-header", "Aplicativos"),
    div(
      class = "section",
      lapply(app_names, function(name) {
        actionLink(inputId = paste0("nav_", name), label = name)
      })
    ),
    div(class = "sidebar-footer", "Mar de Nós - UFMG")
  )
}


sidebar$style = tags$head(
  tags$style(HTML("
    .sidebar {
      position: fixed;
      top: 0;
      left: 0;
      height: 100vh;
      width: 180px;
      background-color: #2c3e50;
      color: white;

      font-family: 'Lato', sans-serif;
      font-size: 1.4rem;
      font-weight: 300;

      display: flex;
      flex-direction: column;
      padding: 2rem 1.5rem;
      gap: 20px;

      box-shadow: 2px 0 8px rgba(0,0,0,0.08);
      z-index: 999;
    }
    
    .sidebar .title {
      font-size: 1.8rem;
      font-weight: bold;
      margin-bottom: 10px;
    }

    .sidebar a {
      color: white;
      text-decoration: none;
      padding: 8px 10px;
      border-radius: 6px;
      transition: background 0.2s;
    }

    .sidebar a:hover {
      background-color: rgba(255,255,255,0.1);
    }

    .sidebar .section {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
    
    .sidebar-footer {
      margin-top: auto;
      font-size: 1.2rem;
      opacity: 0.7;
      padding-top: 15px;
      border-top: 1px solid rgba(255,255,255,0.2);
    }

    /* empurra conteúdo principal */
    .content {
      margin-left: 180px;
    }
  "))
)


# ui = tagList(
#   topbar$style,
#   sidebar$style,
#   topbar$ui,
#   sidebar$ui,
#   div(class = "content",
#       fluidPage(
#         titlePanel(div("App", class = "title-panel"))
#       )
#   ))
# shinyApp(ui, function(input, output, session){})