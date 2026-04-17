instalar_pacotes = function() {
  pacotes_instalados = installed.packages()[, "Package"]
  
  if (!"pak" %in% pacotes_instalados) install.packages("pak")
  if (!"renv" %in% pacotes_instalados) {
    if ("pak" %in% pacotes_instalados) {
      pak::pak("renv")
    } else {
      install.packages("renv")
    }
  } 
  
  pacotes_necessarios =
    list.files(recursive = TRUE, pattern = "\\.(R|qmd)$", full.names = T) |>
    renv::dependencies() |>
    {\(.) .$Package}() |>
    unique() |>
    setdiff(pacotes_instalados) |>
    setdiff("snis")
  
  if (length(pacotes_necessarios) == 0) return("pacotes OK")
  
  cat("\n\nTalvez seja necessário instalar os seguintes pacotes de sistema\n\n", pak::pkg_sysreqs(pacotes_necessarios)$install_scripts, "\n\n")
  
  res = try(pak::pak(pacotes_necessarios), silent = TRUE)
  
  pacotes_faltando = pacotes_necessarios[!pacotes_necessarios %in% pacotes_instalados]
  
  if (length(pacotes_faltando) > 0) {
    message("Alguns pacotes não foram instalados com pak. Usando install.packages()...")
    install.packages(pacotes_faltando)
  }
}
