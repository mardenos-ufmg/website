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
        a("Mar de Nós", class = "logo", href = "website/index.html"),
        a("Sobre nós", href = "website/qmd/dashboards.html"),
        a("Blog", href = "website/blog/index.html"),
        a("Dashboards", href = "website/qmd/dashboards.html"),
        a("Repositório de dados", href = "website/qmd/repositorio.html"),
        a("Bibliografia", href = "website/qmd/bibliografia.html"),
        a("4devs", href = "website/4devs/index.html")
    ),
    
    div(class = "right",
        a(icon("github"), href = "https://github.com/mardenos-ufmg"),
        a(icon("instagram"), href = "https://instagram.com/mar.de.nos_ufmg"),
        a(icon("envelope"), href = "mailto:mardenos.ufmg@gmail.com")
    )
)