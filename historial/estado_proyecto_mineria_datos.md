# Estado del proyecto: diversidad y calidad de la oferta alimentaria (FAO, Sudamérica)

Última actualización: 19 de octubre de 2026

## Tema y pregunta de investigación

Trabajo de minería de datos sobre 10 países de Sudamérica (Argentina, Bolivia, Brasil, Chile, Colombia, Ecuador, Paraguay, Perú, Uruguay, Venezuela), a partir de bases de datos de la FAO (FAOSTAT).

**Pregunta central:** ¿la diversificación de la oferta alimentaria de un país está asociada con una mayor disponibilidad de energía, proteínas y otros nutrientes, y con una oferta de mejor calidad?

## Datos usados

Tres CSV derivados de FAOSTAT (no incluidos en esta carpeta; deben colocarse junto al `.Rmd` para poder compilarlo):

| Dataset | Granularidad | Filas |
|---|---|---|
| `paises_definitivo_kpis.csv` | 1 fila por país | 10 |
| `paises_pca_clusters.csv` | 1 fila por país (+ PC1, PC2, clúster) | 10 |
| `panel_pais_anio_definitivo.csv` | 1 fila por país-año | 140 (2010-2023) |

## Archivos de este envío

1. **`informe_mineria_datos--5-.html`** — el informe original que subiste (versión 1), ya kniteado en R Markdown. Es el punto de partida de la revisión.
2. **`informe_mineria_datos_v2.Rmd`** — la versión 2, reescrita en R Markdown sin renderizar. Hay que abrirla en RStudio (o `rmarkdown::render()`) junto con los tres CSV para generar el HTML final.

## Qué se hizo hasta ahora

1. **Revisión de la v1** (hecha sobre el HTML subido). Se identificaron 7 problemas:
   - El informe terminaba a mitad de frase, sin conclusiones.
   - El título preguntaba por nutrientes (kcal/proteína) pero el análisis solo contrastaba diversidad vs. un índice de calidad; nunca se probó la relación con nutrientes directamente.
   - El clustering se presentaba como "coherente" pese a una silueta promedio muy baja (0.00–0.22).
   - El PCA tenía más variables (≈21) que países (10), con un componente de varianza prácticamente nula, y no mostraba las cargas.
   - Había afirmaciones de tendencia ("las kcal suben", "la dependencia aumentó") sin ningún test estadístico de respaldo.
   - Faltaba contexto de los datos: fuente exacta en FAOSTAT, definición del índice de diversidad, distinción entre disponibilidad y consumo real.
   - Quedaban restos de plantilla (notas tipo "coloca los tres CSV en la misma carpeta").

2. **Reescritura a v2** (`informe_mineria_datos_v2.Rmd`), que agrega:
   - Pregunta de investigación con hipótesis explícitas (H0, H1, H2) y tabla de definiciones de todos los índices.
   - Una sección de **consistencia entre datasets** que detecta automáticamente a qué ventana de años corresponden los KPIs (parecían no ser el promedio de los 14 años del panel).
   - El test que faltaba: diversidad vs. kcal/proteína/grasa/calidad, con Pearson, Spearman, corrección por comparaciones múltiples (Holm) y sensibilidad a excluir a Brasil.
   - Análisis de panel con tendencias (Mann-Kendall), separación entre variación "entre países" y "dentro de cada país", y un modelo de efectos fijos por país.
   - Validación del PCA (cargas numéricas, versión reducida a 8 variables no redundantes) y del clustering (silueta por clúster, número óptimo de k, comparación con clustering jerárquico, índice de Rand ajustado).
   - Conclusiones, limitaciones y trabajo futuro completos (la v1 cortaba a mitad de frase).
   - Corrección de errores puntuales de la v1 (p. ej. qué clúster tiene menor producción real, que Brasil también tiene una anomalía de exportación en 2023 y no solo Venezuela).

3. **Prueba técnica.** El `.Rmd` v2 se compiló con datos sintéticos (no tus CSV reales, que no tengo) para confirmar que el código no tiene errores de sintaxis, que todos los enlaces internos del documento funcionan y que no quedan `NA` ni mensajes de error en el texto generado. **Falta ejecutarlo con tus datos reales** para confirmar que los resultados concretos (valores de p, coeficientes, qué variable gana en cada test) tengan sentido.

## Pendiente / próximos pasos

- [ ] Correr `informe_mineria_datos_v2.Rmd` con tus tres CSV reales y revisar que ningún control de consistencia falle.
- [ ] Hacer tu comparativa v1 vs. v2 para verificar que los cambios sean sustanciales (tal como mencionaste que harías).
- [ ] Completar el nombre de autor y confirmar la ficha exacta de FAOSTAT de la que salieron los datos (Food Balance Sheets u otra), que quedó marcada como nota al pie por confirmar.
- [ ] Revisar visualmente el HTML final una vez generado (gráficos, tablas interactivas).

## Notas importantes

- Nunca tuve acceso a los CSV originales, solo al HTML ya renderizado. Extraje de ahí las tablas numéricas para verificar cálculos, pero toda la v2 debe correrse con tus datos reales antes de entregarla.
- El modelo de efectos fijos de la v2 usa errores estándar agrupados por país; con solo 10 países esto es estadísticamente frágil y el informe lo declara como limitación, no como hallazgo firme.
