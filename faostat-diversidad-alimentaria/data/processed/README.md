# Datos procesados

Codificación UTF-8 con BOM. Fuente: FAOSTAT (balances alimentarios), procesados por los autores.

| Archivo | Filas | Contenido |
|---|---|---|
| `panel_pais_anio_definitivo.csv` | 140 | Panel país-año 2010-2023 (10 países × 14 años, sin faltantes). |
| `paises_definitivo_kpis.csv` | 10 | Indicadores por país, ventana 2019-2023. |
| `paises_pca_clusters.csv` | 10 | Lo anterior más `PC1`, `PC2` y `Cluster_KMeans`. |

## Variables principales

- Columnas por grupo de alimentos (13): oferta por persona (g/día) de cada grupo, p. ej. `Carne`, `Cereales - Exc Cerveza`.
- `Food_Diversity_Index`: índice de diversidad de la oferta, calculado con los 13 grupos.
- `Kcal_dia_total` (`Kcal_persona_dia_total` en los KPI): energía, kcal/persona/día.
- `Grasa_g_dia_total`: grasa, g/persona/día. `Pct_Energia_Grasa`: % de la energía que viene de grasa.
- `Indice_Calidad_Oferta` (0-100): índice parcial, promedio de `Score_FrutasVerduras` y `Score_Grasa`.
- `Produccion_total`, `Importaciones_total`, `Exportaciones_total`, `Suministro_interno_total` y los ratios de autosuficiencia, dependencia de importaciones y orientación exportadora.

Pendiente: confirmar unidades exactas, el dominio de FAOSTAT y la fórmula del índice de diversidad.
