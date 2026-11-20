# Genera las figuras de docs/img/ a partir de data/processed/ con las mismas
# definiciones que analysis/02_diagnostico.Rmd. Uso (desde la raíz del repo):
#   Rscript scripts/figures.R
if (nzchar(Sys.getenv("R_LIBS_USER")) && dir.exists(Sys.getenv("R_LIBS_USER")))
  .libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))

args <- commandArgs(trailingOnly = FALSE)
arch <- sub("^--file=", "", args[grepl("^--file=", args)])
if (length(arch)) setwd(normalizePath(file.path(dirname(arch[1]), "..")))

suppressPackageStartupMessages({ library(tidyverse); library(janitor) })
set.seed(123)
dir.create(file.path("docs", "img"), showWarnings = FALSE, recursive = TRUE)

fuente <- "Fuente: FAOSTAT, cálculos propios"
paleta <- c(Argentina = "#1B9E77", Bolivia = "#D95F02", Brasil = "#7570B3",
            Chile = "#E7298A", Colombia = "#66A61E", Ecuador = "#E6AB02",
            Paraguay = "#A6761D", Perú = "#666666", Uruguay = "#1F78B4",
            Venezuela = "#E31A1C")
tema <- theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold", size = 15),
        plot.title.position = "plot", plot.caption = element_text(colour = "grey40"),
        panel.grid.minor = element_blank(), legend.position = "bottom")
guardar <- function(p, f, w = 8, h = 5) {
  ggsave(file.path("docs", "img", f), p, width = w, height = h, dpi = 150, bg = "white")
  message("OK: docs/img/", f)
}

panel <- read_csv(file.path("data", "processed", "panel_pais_anio_definitivo.csv"),
                  show_col_types = FALSE) |> clean_names() |> arrange(pais, ano)
paises <- sort(unique(panel$pais)); G <- length(paises)
panel <- panel |>
  mutate(div_z = (food_diversity_index - mean(food_diversity_index)) / sd(food_diversity_index),
         t_c = ano - min(ano))

# --- Figura 1: diversidad vs energía dentro de cada país (Frisch-Waugh) -------------
# Se quitan efectos de país y tendencia común a ambas variables; la pendiente de la
# recta es el coeficiente de efectos fijos + tendencia del informe diagnóstico.
res <- function(v) resid(lm(panel[[v]] ~ factor(panel$pais) + panel$t_c))
panel <- panel |> mutate(div_r = res("div_z"), kcal_r = res("kcal_dia_total"))
b_k <- unname(coef(lm(kcal_r ~ div_r, panel))[2])
message(sprintf("Pendiente energía (debe ser 74.24): %.2f", b_k))
f1 <- ggplot(panel, aes(div_r, kcal_r)) +
  geom_hline(yintercept = 0, colour = "grey85") + geom_vline(xintercept = 0, colour = "grey85") +
  geom_point(aes(colour = pais), alpha = .8, size = 2) +
  geom_smooth(method = "lm", se = FALSE, colour = "black", linewidth = .9) +
  scale_colour_manual(values = paleta, name = NULL) +
  guides(colour = guide_legend(nrow = 2, override.aes = list(size = 3))) +
  labs(title = "Dentro de cada país, más diversidad se asocia con más energía",
       subtitle = sprintf("Pendiente: %+.1f kcal/día por +1 DE (efectos fijos de país + tendencia)", b_k),
       x = "Diversidad (desviaciones del propio país, en DE del panel)",
       y = "Energía (kcal/día, desviaciones)", caption = fuente) + tema
guardar(f1, "diversidad_vs_energia.png")

# --- Figura 2: coeficientes con IC (bootstrap salvaje, pesos de Webb) ---------------
webb <- c(-sqrt(1.5), -1, -sqrt(0.5), sqrt(0.5), 1, sqrt(1.5))
D2 <- function(x) { x <- as.matrix(x); x - apply(x, 2, function(c) ave(c, panel$pais)) }
wcb <- function(y, B = 1999, semilla = 20240601) {
  Xd <- D2(cbind(div_z = panel$div_z, t_c = panel$t_c)); yd <- D2(y)[, 1]
  gi <- match(panel$pais, paises); N <- nrow(Xd); K <- ncol(Xd); XtXi <- solve(crossprod(Xd))
  est <- function(yy) {
    b <- XtXi %*% crossprod(Xd, yy); e <- as.vector(yy - Xd %*% b)
    S <- rowsum(Xd * e, gi)
    V <- XtXi %*% crossprod(S) %*% XtXi * G / (G - 1) * (N - 1) / (N - K)
    c(b[1], sqrt(V[1, 1]))
  }
  o <- est(yd); t0 <- o[1] / o[2]
  Xr <- Xd[, 2, drop = FALSE]; fit_r <- as.vector(Xr %*% solve(crossprod(Xr), crossprod(Xr, yd)))
  u <- yd - fit_r
  set.seed(semilla); W <- matrix(sample(webb, B * G, replace = TRUE), B, G)
  ts_ <- apply(W, 1, function(w) { r <- est(fit_r + D2(w[gi] * u)[, 1]); r[1] / r[2] })
  q95 <- unname(quantile(abs(ts_), 0.95))
  list(b = o[1], p = (1 + sum(abs(ts_) >= abs(t0))) / (length(ts_) + 1),
       lo = o[1] - q95 * o[2], hi = o[1] + q95 * o[2])
}
vars <- c(kcal_dia_total = "Energía (kcal/día)", grasa_g_dia_total = "Grasa (g/día)",
          indice_calidad_oferta = "Índice de calidad (puntos)")
co <- map_dfr(names(vars), function(v) {
  w <- wcb(panel[[v]]); tibble(v = v, b = w$b, lo = w$lo, hi = w$hi, p = w$p)
}) |>
  mutate(etiqueta = factor(vars[v], levels = vars),
         padj = p.adjust(p, "holm"),
         lab = sprintf("%+.1f  (p Holm = %.3f)", b, padj))
print(co |> select(v, b, lo, hi, p, padj))
f2 <- ggplot(co, aes(b, etiqueta)) +
  geom_vline(xintercept = 0, colour = "grey60", linetype = "dashed") +
  geom_errorbar(aes(xmin = lo, xmax = hi), width = .15, linewidth = .9, colour = "#1F78B4", orientation = "y") +
  geom_point(size = 3.2, colour = "#1F78B4") +
  geom_text(aes(label = lab), vjust = -1.2, size = 3.8) +
  facet_wrap(~etiqueta, ncol = 1, scales = "free") +
  labs(title = "Asociación dentro de cada país, por +1 DE de diversidad",
       subtitle = "Coeficiente e IC 95 % por bootstrap salvaje por país (Webb); Holm sobre los tres resultados",
       x = "Coeficiente (unidades de cada variable)", y = NULL, caption = fuente) +
  tema + theme(axis.text.y = element_blank(), strip.text = element_text(face = "bold", hjust = 0))
guardar(f2, "coeficientes.png", h = 5.6)

# --- Figura 3: tendencia de la energía por país ---------------------------------------
reg <- panel |> group_by(ano) |> summarise(kcal = mean(kcal_dia_total), .groups = "drop")
etq <- panel |> filter(ano == max(ano))
f3 <- ggplot(panel, aes(ano, kcal_dia_total, colour = pais)) +
  geom_line(linewidth = .9) +
  geom_line(data = reg, aes(ano, kcal), inherit.aes = FALSE, colour = "black", linewidth = 1.3, linetype = "22") +
  ggrepel::geom_text_repel(data = etq, aes(label = pais), nudge_x = .6, hjust = 0, direction = "y",
                           segment.size = .2, size = 3.6, show.legend = FALSE) +
  scale_colour_manual(values = paleta) +
  scale_x_continuous(breaks = seq(2010, 2023, 3), expand = expansion(mult = c(.02, .16))) +
  labs(title = "Energía disponible por país, 2010-2023",
       subtitle = "Línea negra discontinua: promedio simple de los diez países",
       x = NULL, y = "kcal/persona/día", caption = fuente) + tema + theme(legend.position = "none")
guardar(f3, "tendencia_energia.png")

# --- Figura 4: pronóstico ingenuo del promedio regional -------------------------------
y <- reg$kcal; n <- length(y); h <- 1:3
s <- sd(diff(y)) * sqrt(h)
fut <- tibble(ano = max(reg$ano) + h, kcal = y[n], lo = y[n] - qnorm(.975) * s, hi = y[n] + qnorm(.975) * s)
print(fut)
f4 <- ggplot() +
  geom_ribbon(data = fut, aes(ano, ymin = lo, ymax = hi), fill = "#1F78B4", alpha = .2) +
  geom_line(data = reg, aes(ano, kcal), linewidth = 1, colour = "black") +
  geom_line(data = bind_rows(tibble(ano = max(reg$ano), kcal = y[n]), fut[, c("ano", "kcal")]),
            aes(ano, kcal), linewidth = 1, colour = "#1F78B4", linetype = "dashed") +
  geom_point(data = reg, aes(ano, kcal), size = 1.8) +
  scale_x_continuous(breaks = seq(2010, 2026, 2)) +
  labs(title = "Pronóstico del promedio regional: repetir el último valor",
       subtitle = sprintf("2026: %s kcal/día, IC 95 %% [%s, %s]. Ni Holt ni ARIMA superaron esta referencia",
                          format(round(fut$kcal[3]), big.mark = " "), format(round(fut$lo[3]), big.mark = " "),
                          format(round(fut$hi[3]), big.mark = " ")),
       x = NULL, y = "kcal/persona/día", caption = fuente) + tema
guardar(f4, "pronostico_energia.png")

# --- Miniatura 1200x630 para tarjeta de portafolio ------------------------------------
th <- ggplot(panel, aes(div_r, kcal_r)) +
  geom_point(aes(colour = pais), alpha = .85, size = 2.6, show.legend = FALSE) +
  geom_smooth(method = "lm", se = FALSE, colour = "black", linewidth = 1.1) +
  scale_colour_manual(values = paleta) +
  labs(x = "Diversidad (dentro del país)", y = "Energía (kcal)") +
  theme_minimal(base_size = 15) + theme(panel.grid.minor = element_blank())
txt <- ggplot() + xlim(0, 1) + ylim(0, 1) +
  annotate("text", x = 0, y = .85, hjust = 0, vjust = 1, size = 9, fontface = "bold", lineheight = .95,
           label = "Diversidad de la\noferta alimentaria\nen Sudamérica") +
  annotate("text", x = 0, y = .45, hjust = 0, vjust = 1, size = 5, colour = "grey30", lineheight = 1.15,
           label = "Panel de 10 países, 2010-2023\nEfectos fijos, bootstrap salvaje\ny pronóstico (FAOSTAT)") +
  annotate("text", x = 0, y = .04, hjust = 0, vjust = 0, size = 4.2, colour = "grey45",
           label = "Juan Salazar y Luz Ríos") +
  theme_void()
png_f <- file.path("docs", "img", "thumbnail.png")
if (requireNamespace("ragg", quietly = TRUE)) {
  ragg::agg_png(png_f, width = 1200, height = 630, res = 120, background = "white")
} else {
  png(png_f, width = 1200, height = 630, res = 120, bg = "white")
}
grid::grid.newpage()
grid::pushViewport(grid::viewport(layout = grid::grid.layout(1, 2, widths = grid::unit(c(.45, .55), "npc"))))
print(txt + theme(plot.margin = margin(30, 10, 30, 40)), vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 1))
print(th + theme(plot.margin = margin(30, 40, 30, 5)), vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 2))
invisible(dev.off()); message("OK: docs/img/thumbnail.png")
