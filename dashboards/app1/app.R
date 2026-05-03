library(shiny)
source(here::here("stuff/shiny-bar.R"))
source(here::here("dashboards/app1/funs.R"))


apps = list()
env = list()
for (file in list.files("dashboards/app1/apps", full.names = T)) {
  nome = strsplit(basename(file), "[.]R")[[1]]
  env[[nome]] = new.env()
  source(file, local = env[[nome]])
  apps[[nome]] = as.list.environment(env[[nome]])
}
app_names = names(apps)


ui = tagList(
  topbar$style,
  sidebar$style,
  
  topbar$ui,
  sidebar$ui(app_names),
  
  div(
    class = "content",
    uiOutput("app_container")
  )
)

server = function(input, output, session) {
  current_app = reactiveVal(app_names[1])
  
  # Navegação pela sidebar
  lapply(app_names, function(name) {
    observeEvent(input[[paste0("nav_", name)]], {
      current_app(name)
    }, ignoreInit = TRUE)
  })
  
  # Renderiza a UI do app ativo com o namespace correto
  output$app_container <- renderUI({
    name <- current_app()
    apps[[name]]$ui(NS(name))
  })
  
  # Sobe TODOS os módulos uma única vez (não dentro de reactive)
  lapply(app_names, function(name) {
    moduleServer(name, apps[[name]]$server)
  })
}

shinyApp(ui = ui, server = server)
