# tema_css = function() {
#   CORES = list(
#     primaria   = "#4B3F9E",
#     secundaria = "#7B6FCF",
#     acento     = "#00BCD4",
#     fundo      = "#F4F6F9",
#     texto      = "#2D2D3A"
#   )
#   
#   tags$style(HTML(sprintf("
# * { box-sizing: border-box; }
# body { background: %s; font-family: 'Segoe UI', sans-serif; color: %s; margin: 0; }
# 
# /* Conteúdo principal */
# .main-content {
#   margin-left: 220px; margin-top: 56px;
#   min-height: calc(100vh - 56px);
#   padding: 28px 32px;
# }
# 
# /* Cards e caixas */
# .info-box {
#   background: #fff; border-radius: 12px; padding: 24px 28px;
#   box-shadow: 0 2px 12px rgba(0,0,0,.07); margin-bottom: 24px;
# }
# .info-box h2 { font-size: 18px; font-weight: 700; color: %s; margin: 0 0 10px; }
# .info-box p  { font-size: 14px; color: #555; line-height: 1.7; margin: 0; }
# 
# .page-header {
#   background: #fff; border-radius: 12px; padding: 22px 28px;
#   margin-bottom: 24px; box-shadow: 0 2px 12px rgba(0,0,0,.07);
#   border-left: 5px solid %s;
# }
# .page-header h2 { margin: 0 0 4px; font-size: 22px; font-weight: 800; color: %s; }
# .page-header p  { margin: 0; color: #777; font-size: 14px; }
# 
# .feature-card {
#   background: #fff; border-radius: 12px; padding: 24px;
#   box-shadow: 0 2px 12px rgba(0,0,0,.07); border-left: 4px solid %s;
#   transition: transform .18s, box-shadow .18s; height: 100%%;
# }
# .feature-card:hover { transform: translateY(-3px); box-shadow: 0 6px 20px rgba(0,0,0,.12); }
# .feature-card .fc-icon { font-size: 30px; margin-bottom: 10px; }
# .feature-card h3 { font-size: 15px; font-weight: 700; margin: 0 0 6px; color: %s; }
# .feature-card p  { font-size: 13px; color: #666; margin: 0; line-height: 1.6; }
# .feature-card .fc-link {
#   display: inline-block; margin-top: 14px; font-size: 12px; font-weight: 600;
#   color: %s; cursor: pointer; text-decoration: none;
# }
# .feature-card .fc-link:hover { text-decoration: underline; }
# 
# /* Hero de boas-vindas */
# .welcome-hero {
#   background: linear-gradient(135deg, %s 0%%, %s 100%%);
#   border-radius: 16px; padding: 42px 48px; color: #fff; margin-bottom: 28px;
#   position: relative; overflow: hidden;
# }
# .welcome-hero::after {
#   content: ''; position: absolute; right: -60px; top: -60px;
#   width: 260px; height: 260px;
#   background: rgba(255,255,255,.07); border-radius: 50%%;
# }
# .welcome-hero h1 { font-size: 26px; font-weight: 800; margin: 0 0 10px; }
# .welcome-hero p  { font-size: 15px; opacity: .88; margin: 0; max-width: 560px; }
# 
# }
# ",
# CORES$fundo,      CORES$texto,
# CORES$acento,     CORES$acento,       # active item
# CORES$primaria,                       # info-box h2
# CORES$acento,     CORES$primaria,     # page-header
# CORES$acento,     CORES$primaria,     # feature-card
# CORES$primaria,                       # fc-link
# CORES$primaria,   CORES$secundaria    # hero
#   )))
# }
# 

# tema_css <- function() {
#   CORES <- list(
#     primaria   = "#4B3F9E",
#     secundaria = "#7B6FCF",
#     acento     = "#00BCD4",
#     fundo      = "#F4F6F9",
#     texto      = "#2D2D3A"
#   )
#   
#   tags$style(HTML(glue::glue("
# * {{ box-sizing: border-box; }}
# body {{ background: {CORES$fundo}; font-family: 'Segoe UI', sans-serif; color: {CORES$texto}; margin: 0; }}
# 
# /* Conteúdo principal */
# .main-content {{
#   margin-left: 220px; margin-top: 56px;
#   min-height: calc(100vh - 56px);
#   padding: 28px 32px;
# }}
# 
# /* Cards e caixas */
# .info-box {{
#   background: #fff; border-radius: 12px; padding: 24px 28px;
#   box-shadow: 0 2px 12px rgba(0,0,0,.07); margin-bottom: 24px;
# }}
# .info-box h2 {{ font-size: 18px; font-weight: 700; color: {CORES$primaria}; margin: 0 0 10px; }}
# .info-box p  {{ font-size: 14px; color: #555; line-height: 1.7; margin: 0; }}
# 
# .page-header {{
#   background: #fff; border-radius: 12px; padding: 22px 28px;
#   margin-bottom: 24px; box-shadow: 0 2px 12px rgba(0,0,0,.07);
#   border-left: 5px solid {CORES$acento};
# }}
# .page-header h2 {{ margin: 0 0 4px; font-size: 22px; font-weight: 800; color: {CORES$primaria}; }}
# .page-header p  {{ margin: 0; color: #777; font-size: 14px; }}
# 
# .feature-card {{
#   background: #fff; border-radius: 12px; padding: 24px;
#   box-shadow: 0 2px 12px rgba(0,0,0,.07); border-left: 4px solid {CORES$acento};
#   transition: transform .18s, box-shadow .18s; height: 100%;
# }}
# .feature-card:hover {{ transform: translateY(-3px); box-shadow: 0 6px 20px rgba(0,0,0,.12); }}
# .feature-card .fc-icon {{ font-size: 30px; margin-bottom: 10px; }}
# .feature-card h3 {{ font-size: 15px; font-weight: 700; margin: 0 0 6px; color: {CORES$primaria}; }}
# .feature-card p  {{ font-size: 13px; color: #666; margin: 0; line-height: 1.6; }}
# .feature-card .fc-link {{
#   display: inline-block; margin-top: 14px; font-size: 12px; font-weight: 600;
#   color: {CORES$primaria}; cursor: pointer; text-decoration: none;
# }}
# .feature-card .fc-link:hover {{ text-decoration: underline; }}
# 
# /* Hero de boas-vindas */
# .welcome-hero {{
#   background: linear-gradient(135deg, {CORES$primaria} 0%, {CORES$secundaria} 100%);
#   border-radius: 16px; padding: 42px 48px; color: #fff; margin-bottom: 28px;
#   position: relative; overflow: hidden;
# }}
# .welcome-hero::after {{
#   content: ''; position: absolute; right: -60px; top: -60px;
#   width: 260px; height: 260px;
#   background: rgba(255,255,255,.07); border-radius: 50%;
# }}
# .welcome-hero h1 {{ font-size: 26px; font-weight: 800; margin: 0 0 10px; }}
# .welcome-hero p  {{ font-size: 15px; opacity: .88; margin: 0; max-width: 560px; }}
#   ")))
# }


tema_css = function() {
  CORES = list(
    primaria   = "#4B3F9E",
    secundaria = "#7B6FCF",
    acento     = "#00BCD4",
    fundo      = "#F4F6F9",
    texto      = "#2D2D3A"
  )
  
  tags$style(HTML(glue::glue("
/* Aplica apenas dentro do contêiner .app-body */
.app-body * {{ box-sizing: border-box; }}
.app-body {{
  background: {CORES$fundo};
  font-family: 'Segoe UI', sans-serif;
  color: {CORES$texto};
}}

/* Conteúdo principal */
.app-body .main-content {{
  margin-left: 220px;
  margin-top: 56px;
  min-height: calc(100vh - 56px);
  padding: 28px 32px;
}}

/* Cards e caixas */
.app-body .info-box {{
  background: #fff; border-radius: 12px; padding: 24px 28px;
  box-shadow: 0 2px 12px rgba(0,0,0,.07); margin-bottom: 24px;
}}
.app-body .info-box h2 {{ font-size: 18px; font-weight: 700; color: {CORES$primaria}; margin: 0 0 10px; }}
.app-body .info-box p  {{ font-size: 14px; color: #555; line-height: 1.7; margin: 0; }}

.app-body .page-header {{
  background: #fff; border-radius: 12px; padding: 22px 28px;
  margin-bottom: 24px; box-shadow: 0 2px 12px rgba(0,0,0,.07);
  border-left: 5px solid {CORES$acento};
}}
.app-body .page-header h2 {{ margin: 0 0 4px; font-size: 22px; font-weight: 800; color: {CORES$primaria}; }}
.app-body .page-header p  {{ margin: 0; color: #777; font-size: 14px; }}

.app-body .feature-card {{
  background: #fff; border-radius: 12px; padding: 24px;
  box-shadow: 0 2px 12px rgba(0,0,0,.07); border-left: 4px solid {CORES$acento};
  transition: transform .18s, box-shadow .18s; height: 100%;
}}
.app-body .feature-card:hover {{ transform: translateY(-3px); box-shadow: 0 6px 20px rgba(0,0,0,.12); }}
.app-body .feature-card .fc-icon {{ font-size: 30px; margin-bottom: 10px; }}
.app-body .feature-card h3 {{ font-size: 15px; font-weight: 700; margin: 0 0 6px; color: {CORES$primaria}; }}
.app-body .feature-card p  {{ font-size: 13px; color: #666; margin: 0; line-height: 1.6; }}
.app-body .feature-card .fc-link {{
  display: inline-block; margin-top: 14px; font-size: 12px; font-weight: 600;
  color: {CORES$primaria}; cursor: pointer; text-decoration: none;
}}
.app-body .feature-card .fc-link:hover {{ text-decoration: underline; }}

/* Hero de boas-vindas */
.app-body .welcome-hero {{
  background: linear-gradient(135deg, {CORES$primaria} 0%, {CORES$secundaria} 100%);
  border-radius: 16px; padding: 42px 48px; color: #fff; margin-bottom: 28px;
  position: relative; overflow: hidden;
}}
.app-body .welcome-hero::after {{
  content: ''; position: absolute; right: -60px; top: -60px;
  width: 260px; height: 260px;
  background: rgba(255,255,255,.07); border-radius: 50%;
}}
.app-body .welcome-hero h1 {{ font-size: 26px; font-weight: 800; margin: 0 0 10px; }}
.app-body .welcome-hero p  {{ font-size: 15px; opacity: .88; margin: 0; max-width: 560px; }}
  ")))
}


page_welcome = function() {
  
  apps =
    list.files("dashboards/app1/apps", full.names = T) |>
    basename() |>
    strsplit("[.]R") |>
    unlist()

  cards = lapply(apps, function(xxx) {
    column(4,
      div(class = "feature-card",
        tags$h3(xxx),
        tags$span(
          class   = "fc-link",
          onclick = sprintf(
            "Shiny.setInputValue('current_page', '%s', {priority: 'event'})", xxx
          ),
          "Abrir dashboard →"
        )
      )
    )
  }) |>
    lapply(function(row) fluidRow(row))

  tagList(
    div(class = "welcome-hero",
      tags$h1("Bem-vindo ao Portal de Apps"),
      tags$p(
        "Explore dados públicos e ferramentas analíticas desenvolvidas pelo ",
        tags$b("Mar de Nós - UFMG."),
        " Atualmente ", length(apps), " dashboards disponíveis."
      )
    ),

    cards,

    tags$br(),

    div(class = "info-box",
      tags$h2("O que é Análise Descritiva de Dados?"),
      tags$p(
        "A análise descritiva é a primeira fase do estudo sobre os dados coletados. ",
        "Nela ocorre a manipulação de dados com o objetivo de resumir, descrever e explorar o comportamento destes. ",
        "Ela utiliza diversas ferramentas estatísticas — como tabelas, gráficos e medidas de síntese (índices e médias)."
      )
    )
  )
}


ui = function(ns) {
  tagList(tags$head(tema_css()), page_welcome())
}

ui = function(ns) {
  div(
    class = "app-body", tema_css(),
    div(class = "main-content", page_welcome())
    )
}

server = function(input, output, session) {}
