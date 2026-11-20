# Instala los paquetes que usan los informes. Uso: Rscript scripts/install_packages.R
pk <- c("tidyverse","janitor","plm","sandwich","lmtest","knitr","rmarkdown","DT","corrplot",
        "factoextra","cluster","ggrepel","moments","FactoMineR","psych","car","ragg")
faltan <- setdiff(pk, rownames(installed.packages()))
if (length(faltan)) install.packages(faltan, repos = "https://cloud.r-project.org")
message("Listo. Faltaban: ", if (length(faltan)) paste(faltan, collapse = ", ") else "ninguno")
