ui = function(ns) {
  tagList(div(class = "mdn-container",
    
    div(class = "mdn-header", "Sobre o Dashboard"),
    
    section("O que é um App Dashboard?",
      p("Um dashboard interativo é uma aplicação que permite visualizar, explorar e analisar dados de forma dinâmica. Diferente de relatórios estáticos, dashboards permitem ao usuário selecionar variáveis, filtrar informações e interagir com gráficos e mapas em tempo real."),
      p("Aplicações desenvolvidas com Shiny (R) integram modelagem, visualização e interação em uma única interface web, sendo amplamente utilizadas em estatística, ciência de dados e pesquisa aplicada.")
    ),
    
    section("Aplicativos disponíveis",
      div(class = "mdn-cards",
        card("Análise Fatorial – SNIS",
             "Exploração de indicadores do Sistema Nacional de Informações sobre Saneamento (SNIS), com mapas interativos, análise de scores fatoriais e visualização de loadings."
        ),
        card("Séries Temporais – Lago de Furnas",
             "Análise do nível (cota) do Lago de Furnas, incluindo séries de temperatura e outras variáveis meteorológicas e ambientais."
        )
      )
    ),
    
    section("Como utilizar",
      lista(
        "Use o menu lateral para navegar entre os aplicativos.",
        "Selecione variáveis e filtros disponíveis.",
        "Interaja com gráficos e mapas.",
        "Clique em elementos visuais para explorar detalhes."
      )
    )
      
  ))
}


server = function(input, output, session) {}

# source(here::here("dashboards/app1/funs.R")); shiny_app(ui, server)