topbar_style =
  tags$head(
  tags$style(HTML("
      .topbar {
        background-color: #2c3e50;
        color: white;
        padding: 1.5rem 1.5rem;
        display: flex;
        align-items: center;
        justify-content: space-between;
        font-family: 'Lato', sans-serif;
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
)

topbar_ui =
div(class = "topbar",
    div(class = "left",
        a(class = "logo", href = "https://mardenos-ufmg.github.io/website/index.html", img(src = "https://mardenos-ufmg.github.io/website/stuff/favicon.png", height = "20px", style = "margin-right: 10px;"), "Mar de Nós"),
        a("Sobre nós", href = "https://mardenos-ufmg.github.io/website/qmd/dashboards.html"),
        a("Blog", href = "https://mardenos-ufmg.github.io/website/blog/index.html"),
        a("Dashboards", href = "https://mardenos-ufmg.github.io/website/qmd/dashboards.html"),
        a("Repositório de dados", href = "https://mardenos-ufmg.github.io/website/qmd/repositorio.html"),
        a("Bibliografia", href = "https://mardenos-ufmg.github.io/website/qmd/bibliografia.html"),
        a("4devs", href = "https://mardenos-ufmg.github.io/website/4devs/index.html")
    ),
    
    div(class = "right",
        a(icon("github"), href = "https://github.com/mardenos-ufmg"),
        a(icon("instagram"), href = "https://instagram.com/mar.de.nos_ufmg"),
        a(icon("envelope"), href = "mailto:mardenos.ufmg@gmail.com")
    )
)