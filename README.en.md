# Food supply diversity in South America (FAOSTAT, 2010-2023)

A 10-country South American panel to ask whether the years with a more diverse food supply are also years with more energy, more fat and better quality. Two R Markdown reports, processed data and all the code to reproduce them.

[Versión en español](README.md) · Live reports (in Spanish): <https://jps4l4.github.io/faostat-diversidad-alimentaria/>

## The question

> Within each country, are the years with a more diverse food supply also years with more energy, more fat and better supply quality?

"More variety" is often read as "a better diet". Here it is tested with food availability data, and we measure carefully how well the answer holds up.

## Data

- **Source:** FAOSTAT (FAO). Probable domain: Food Balances (2010-). The domain, elements and units are still to be confirmed.
- **Countries (10):** Argentina, Bolivia, Brazil, Chile, Colombia, Ecuador, Paraguay, Peru, Uruguay and Venezuela.
- **Panel:** 2010-2023, 140 country-year rows (balanced).
- **Country-level indicators:** 2019-2023 window.
- **Status:** processed data is in [`data/processed/`](data/processed/). **Raw data is pending**; see [`data/raw/README.md`](data/raw/README.md).

## Method

**1. Descriptive** ([report](https://jps4l4.github.io/faostat-diversidad-alimentaria/01_descriptivo.html)). Data quality checks, trends by country, Mann-Kendall test, correlations, PCA and clustering. It concludes which stage should come next.

**2. Diagnostic** ([report](https://jps4l4.github.io/faostat-diversidad-alimentaria/02_diagnostico.html)).
- Fixed- and random-effects panel models (with a common trend) and the Hausman test.
- With only 10 countries, usual inference is unreliable. We compare country-clustered errors, Driscoll-Kraay and the wild cluster bootstrap with Webb weights, with Holm correction across three outcomes.
- Robustness: year effects, first differences, lagged diversity, leave-one-country-out, dropping Venezuela's crisis years.
- A short energy forecast: naive vs Holt vs ARIMA, with strictly temporal validation (fixed split and rolling origins).

**3. Multivariate** ([report](https://jps4l4.github.io/faostat-diversidad-alimentaria/03_multivariado.html)).
- **Interdependence:** PCA of the 13 food groups (with KMO and Bartlett), on the raw data and on country-demeaned data; Ward clustering on the retained components.
- **Dependence:** multivariate linear regression (MANCOVA) of energy, fat and quality jointly, with country fixed effects; Pillai test, canonical variate and a joint Wald test with the wild cluster bootstrap.

## Key findings

These are **associations**, not causal effects.

- **Within each country**, +1 SD of diversity goes with **+74.2 kcal/person/day** (+2.5%; wild-bootstrap Webb p = 0.012; Holm = 0.038) and **+11.4 g fat/day** (+12%; Holm = 0.038; holds in 6 of 6 robustness checks).
- **Supply quality:** no association.
- **It is fragile.** With year effects none of the associations survive Holm. In first differences the energy effect disappears (-14.5 kcal; p = 0.53), while the fat effect holds.
- **Between countries (n = 10)** no association survives Holm.
- **Hausman** does not reject random effects, with low power; fixed effects are kept.
- **Supply patterns:** composition is mostly a country trait (median 93% of the variance is between countries). The 6 clusters (silhouette 0.58) are country typologies, not periods. Within countries there is a general supply-expansion axis that correlates 0.86 with energy but only 0.51 with diversity.
- **Joint test:** Pillai gives p < 0.001, but the wild cluster bootstrap gives p = 0.064 (trend) and 0.083 (year effects). With 10 countries the joint evidence is weak and the association is concentrated in fat.
- **Forecast:** repeating the last value beats Holt and ARIMA (rolling-origin MAE 35.7 kcal/day; MAPE 1.27%). Regional average for 2026: about 2,996 kcal/day [2,920 – 3,072].

![Diversity and energy within countries](docs/img/diversidad_vs_energia.png)

![Coefficients with wild-bootstrap confidence intervals](docs/img/coeficientes.png)

| | |
|---|---|
| ![Energy trend by country](docs/img/tendencia_energia.png) | ![Regional average forecast](docs/img/pronostico_energia.png) |

Figures are labelled in Spanish; the reports are in Spanish.

## Structure

```
analysis/        01_descriptivo.Rmd, 02_diagnostico.Rmd, 03_multivariado.Rmd
data/processed/  3 CSV files (country-year panel, country indicators, PCA and clusters)
data/raw/        pending (see its README)
docs/            HTML reports, landing page and figures (GitHub Pages)
scripts/         render.R (reports) and figures.R (figures)
```

## How to reproduce

Requires R 4.6 (tested with 4.6.1) and [Pandoc](https://pandoc.org/) (bundled with RStudio).

Packages: `tidyverse`, `janitor`, `plm`, `sandwich`, `lmtest`, `knitr`, `rmarkdown`, `DT`, `corrplot`, `factoextra`, `cluster`, `ggrepel`, `moments`, `FactoMineR`, `psych`, `car`; `ragg` is optional.

```
Rscript scripts/render.R     # builds docs/01_descriptivo.html, 02_diagnostico.html and 03_multivariado.html
Rscript scripts/figures.R    # rebuilds docs/img/*.png
```

Run them from the repository root. The reports print the date on which they are rendered.

## Limitations

- Ten countries and 14 years: low power, and results depend on the inference method.
- This is food availability (balance sheets), not consumption.
- The diversity index is computed from the same supply that determines energy and fat, so the relationship may be partly mechanical.
- The quality index is partial (fruit and vegetables, and the fat share of energy).
- Raw data and the script that turns it into the processed CSV files are not in the repository yet.

## Authors

Juan Salazar and Luz Ríos. University project (ITM).

## Data and license

FAO. FAOSTAT. Food Balances (2010-). Rome. *(domain to be confirmed)*. <https://www.fao.org/faostat/>

FAOSTAT data is used under the FAO terms of use.

License: pending.
