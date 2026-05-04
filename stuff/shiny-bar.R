styles = list(topbar = list(), sidebar = list())

styles$topbar$style =
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
        color: white;
      }
      .logo {
        font-weight: bold;
        font-size: 18px;
        margin-left: 20px;
      }
    "))
)

styles$topbar$ui =
div(class = "topbar",
    div(class = "left",
        a(class = "logo", href = "/index.html", img(src = here::here("stuff/favicon.png"), height = "20px", style = "margin-right: 10px;"), "Mar de Nós"),
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

styles$sidebar$ui = function(app_names) {
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


styles$sidebar$style = tags$head(
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
    
    .sidebar a:hover {
      text-decoration: underline;
      color: white;
      background-color: rgba(255,255,255,0.1);
    }
    
    .sidebar .title {
      font-size: 1.8rem;
      font-weight: bold;
      margin-bottom: 10px;
    }
    
    .sidebar a,
    .sidebar a:visited,
    .sidebar a:focus,
    .sidebar a:active {
      color: white;
      text-decoration: none;
      padding: 8px 10px;
      border-radius: 6px;
      transition: background 0.2s;
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
      margin-left: 200px;
    }
  "))
)

styles$styles = tags$head(tags$style(HTML(paste0("
  .mdn-container {
    width: 100%;
    max-width: 100%;
    margin: 0 auto;
    padding: 20px 40px;
    padding: 20px 40px;
    font-family: 'Lato', sans-serif;
  }

  .mdn-header {
    background-image: linear-gradient(rgba(255, 255, 255, 0.45), rgba(255, 255, 255, 0.45)), url(\"assets/shiny-title.png\");
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
  
    padding: 30px;
    border-radius: 15px;
    text-align: center;
    text-shadow: 0 20px 60px rgba(255,255,255,0.7);
  
    font-size: 2.5rem;
    font-weight: 600;
  
    color: #1f2d3a;
  
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    margin-bottom: 30px;
  
    position: relative;
    overflow: hidden;
  }
  
  .mdn-section p,
  .mdn-section li {
    font-size: 1rem;
    line-height: 1.6;
    color: #444;
  }

  .mdn-section {
    display: block;
    background: white;
    padding: 25px;
    border-radius: 12px;
    margin-bottom: 25px;
    box-shadow: 0 3px 10px rgba(0,0,0,0.08);
  }

  .mdn-title {
    font-size: 1.6rem;
    margin-bottom: 15px;
    color: #2c3e50;
    border-left: 5px solid #7ec8d8;
    padding-left: 10px;
  }

  .mdn-text {
    font-size: 1rem;
    line-height: 1.6;
    color: #444;
  }
  
  .mdn-cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 20px;
    margin-top: 15px;
  }

  .mdn-card {
    background: #f8fbfd;
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    transition: all 0.2s ease;
  }

  .mdn-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 6px 18px rgba(0,0,0,0.12);
  }

  .mdn-card-title {
    font-weight: 600;
    font-size: 1.2rem;
    margin-bottom: 10px;
    color: #2c3e50;
  }
  
  
  
  
  details summary {
    cursor: pointer;
    list-style: none;
    font-weight: 600;
    color: #2c3e50;
    padding: 10px 15px;
    border-radius: 10px;
    transition: all 0.2s ease;
  }
  
  /* hover com shadow */
  details summary:hover {
    background: #f8fbfd;
    box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  }
"))))


card = function(title, content) {
  div(class = "mdn-card",
      div(class = "mdn-card-title", title),
      div(class = "mdn-text", content)
  )
}


section = function(title, ..., collapse = FALSE) {
  if (!collapse) {
    return(
      div(
        class = "mdn-section",
        div(class = "mdn-title", title),
        ...
      )
    )
  }
  
  # versão colapsável (sempre fechado)
  tags$details(
    tags$summary(
      div(class = "mdn-title", title)
    ),
    div(
      class = "mdn-section",
      ...
    )
  )
}


# section = function(title, ...) {
#   div(class = "mdn-section",
#       div(class = "mdn-title", title),
#       ...
#   )
# }

lista = function(...) {
  tags$ul(
    lapply(list(...), function(x) tags$li(x))
  )
}

# ui = tagList(
#   styles$topbar$style,
#   styles$sidebar$style,
#   styles$styles,
#   styles$topbar$ui,
#   styles$sidebar$ui,
#   div(class = "content",
#       fluidPage(
#         titlePanel(div("App", class = "title-panel"))
#       )
#   ))
# shinyApp(ui, function(input, output, session){})