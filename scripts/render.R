# Renderiza los dos informes en docs/. Uso (desde la raíz del repo):
#   Rscript scripts/render.R
if (nzchar(Sys.getenv("R_LIBS_USER")) && dir.exists(Sys.getenv("R_LIBS_USER")))
  .libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))

# Raíz del repo: la carpeta que contiene scripts/ (funciona desde cualquier directorio)
args  <- commandArgs(trailingOnly = FALSE)
arch  <- sub("^--file=", "", args[grepl("^--file=", args)])
raiz  <- if (length(arch)) normalizePath(file.path(dirname(arch[1]), "..")) else getwd()
setwd(raiz)

informes <- c("01_descriptivo", "02_diagnostico")
for (i in informes) {
  rmarkdown::render(
    input         = file.path("analysis", paste0(i, ".Rmd")),
    output_file   = paste0(i, ".html"),
    output_dir    = "docs",
    knit_root_dir = raiz,        # las rutas del Rmd (data/processed/...) son relativas a la raíz
    intermediates_dir = tempdir(),
    quiet         = TRUE
  )
  message("OK: docs/", i, ".html")
}
