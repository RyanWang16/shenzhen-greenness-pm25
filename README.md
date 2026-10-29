# Shenzhen Greenness and PM2.5 (2025)

An exploratory analysis of district-level greenness and PM2.5 in Shenzhen, China. This project combines satellite-derived vegetation indicators with district-level air-quality summaries for 2025 and visualizes their spatial patterns.

## Research Question

How do greenness and PM2.5 levels vary across Shenzhen districts? Do districts with higher greenness tend to have lower PM2.5?

This project describes patterns in the available data. It does not establish that greenness causes lower PM2.5.

## Project Overview

The analysis uses Shenzhen district boundaries to summarize and map two measures:

- **Greenness:** annual Sentinel-2 NDVI and a vegetation percentage indicator processed in Google Earth Engine.
- **Air quality:** district-level PM2.5 summaries for 2025.
- **Visualizations:** maps of greenness and PM2.5, a district summary table, and a scatter plot comparing the two measures.

## Data Sources

### Greenness

- **Satellite imagery:** Sentinel-2 data accessed and processed in Google Earth Engine (GEE).
- **Study period:** January 1 to December 31, 2025.
- **Index:** Normalized Difference Vegetation Index (NDVI), calculated as `(NIR - Red) / (NIR + Red)`.
- **Summary:** annual median NDVI summarized across valid land pixels within each district.
- **GEE export script:** `scripts/gee_ndvi_export.js`
- **Exported file:** `data/greenness/shenzhen_district_greenness_2025.csv`

The vegetation percentage is calculated using a threshold in the GEE script. Check that script for the exact threshold and masking settings before interpreting or reusing this measure.

### PM2.5

- **Data file:** `data/air_quality/pm25_district_2025.csv`
- **Study period:** 2025.
- **Unit:** micrograms per cubic meter (`µg/m³`).
- **Summary fields:** mean, median, observation count, and coverage percentage by district.

The project uses the district-level PM2.5 data in the file above. The original provider and details about how monitoring observations were assigned to districts should be documented with the data before public redistribution.

### District Boundaries

- **Files:** `data/boundaries/shenzhen_districts.shp` and its companion shapefile files.
- **Use:** district polygons for mapping and spatial summaries.
- **Source:** Shenzhen district boundary data provided for the course.

## Data Processing Settings

- **Analysis year:** 2025.
- **Spatial unit:** Shenzhen administrative districts.
- **Join field:** `dist_zh`.
- **Greenness processing:** Sentinel-2 NDVI summarized by district in GEE.
- **PM2.5 processing:** district-level annual summaries read from the provided CSV.
- **Projection, cloud masking, and vegetation threshold:** see `scripts/gee_ndvi_export.js` and the source-data documentation.

The data are annual summaries. Differences in valid satellite pixels, air-quality monitoring coverage, or the number of observation days can affect comparisons.

## Column Definitions

### Greenness CSV

| Column | Description | Unit |
|---|---|---|
| `dist_zh` | District name used to join datasets | Text |
| `district` | District name | Text |
| `ndvi_mean` | District-level annual NDVI summary | Unitless |
| `vegetated_pct_mean` | Vegetation percentage indicator calculated in GEE | Percent |
| `ndvi_count` | Number of valid NDVI pixels or observations included in the summary | Count |

### PM2.5 CSV

| Column | Description | Unit |
|---|---|---|
| `dist_zh` | District name used to join datasets | Text |
| `mean_pm25` | Mean PM2.5 concentration | `µg/m³` |
| `median_pm25` | Median PM2.5 concentration | `µg/m³` |
| `n_pm25` | Number of PM2.5 observations included | Count |
| `coverage_pct` | PM2.5 data coverage percentage reported in the source data | Percent |

## Repository Structure

    shenzhen-greenness-pm25/
    ├── data/
    │   ├── air_quality/
    │   ├── boundaries/
    │   └── greenness/
    ├── scripts/
    │   ├── analyze_greenness.R
    │   └── gee_ndvi_export.js
    ├── figures/
    └── README.md

## Requirements

- R
- R packages: `sf`, `dplyr`, and `ggplot2`
- A Google Earth Engine account to rerun the satellite-data export

Install the required R packages in R:

    install.packages(c("sf", "dplyr", "ggplot2"))

## Setup and Rerun

1. Download or clone this repository.
2. Check that the boundary files and both CSV files are in the locations listed in the repository structure.
3. To regenerate the greenness CSV, open `scripts/gee_ndvi_export.js` in the Google Earth Engine Code Editor. Check the date range, district boundary asset, cloud masking, and vegetation threshold; then run the export.
4. Download the exported CSV and save it as `data/greenness/shenzhen_district_greenness_2025.csv`.
5. Open the project in RStudio and set the working directory to the project root.
6. Run the analysis script:

    source("scripts/analyze_greenness.R")

7. Review the generated summary table, maps, and scatter plot.

## Preliminary Findings

The 2025 district summaries show differences in both greenness and PM2.5. In this dataset, Dapeng has the highest vegetation indicator and a relatively low mean PM2.5 value. The scatter plot suggests a negative association between greenness and PM2.5 across the districts.

These are descriptive findings from a small district-level sample. They should be treated as preliminary and not as evidence that greenness directly reduces PM2.5.

## Limitations

- The analysis includes about ten districts, so the sample is small.
- District-level results do not describe individual residents or locations within a district.
- An association between greenness and PM2.5 does not prove cause and effect.
- Monitoring coverage and observation counts may vary across districts.
- Annual summaries can hide seasonal and day-to-day changes.
- Other factors, including traffic, weather, industry, and urban form, are not controlled for in this analysis.

## Data Use

Check the original data providers' terms before redistributing the PM2.5 data or district boundary files. If a dataset cannot be shared publicly, do not upload it; instead, document its source and explain how to obtain it.
