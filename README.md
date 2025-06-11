
[![GitHub
Release](https://img.shields.io/github/v/release/sustainable-fsa/fsa-counties-dd17?label=GitHub%20Release&color=%239c27b0)](https://github.com/sustainable-fsa/fsa-counties-dd17)
[![DOI](https://zenodo.org/badge/967595011.svg)](https://zenodo.org/badge/latestdoi/967595011)

This repository contains an archival copy of the **FSA_Counties_dd17**
dataset, originally distributed by the U.S. Department of Agriculture
(USDA) Farm Service Agency (FSA) as part of the Common Land Unit (CLU)
geospatial data series.

## 📦 Dataset Overview

- **Title:** FSA_Counties_dd17
- **Source:** USDA Farm Service Agency (FSA)
- **Format:** ESRI File Geodatabase (.gdb)
- **Original Reference:** [USDA FSA GIS Metadata Standards (1-GIS,
  Amendment
  2)](https://www.fsa.usda.gov/Internet/FSA_File/1-gis_r00_a02.pdf)
- **Distribution Type:** Public archival for research and historical
  purposes
- **Date of Archive:** 2025-04-16

## 📂 Contents

The zipped geodatabase includes polygon features representing U.S.
counties, attributed with identifiers used by the FSA for administrative
and mapping purposes. It was prepared according to the USDA’s GIS Data
Standards.

- [`FSA_Counties_dd17.gdb.zip`](https://sustainable-fsa.github.io/fsa-counties-dd17/FSA_Counties_dd17.gdb.zip)
  – Original USDA File Geodatabase
- [`fsa-counties-dd17.topojson`](https://sustainable-fsa.github.io/fsa-counties-dd17/fsa-counties-dd17.topojson)
  – Simplified TopoJSON version with pre-inset Alaska/Hawaii/Puerto Rico
  (see below)
- [`fsa-counties-dd17.R`](https://sustainable-fsa.github.io/fsa-counties-dd17/fsa-counties-dd17.R)
  – R script that produces the Simplified TopoJSON versions

## 🧾 Field Descriptions

| Field Name | Description |
|----|----|
| `STPO` | A two-letter USPS abbreviation for the state |
| `FSA_Name` | The FSA-assigned administrative county name |
| `FSA_ST` | A two-digit FSA-assigned administrative state code |
| `FSA_STCOU` | A five-digit FSA-assigned administrative state and county code |
| `STATENAME` | The full name of the state |
| `FIPS_C` | A five-digit FIPS state and county code |
| `COUNTYNAME` | The county Name |
| `FIPSST` | A two-digit FIPS state code |
| `FIPSCO` | A three-digit FIPS county code |
| `NOTE` | Miscellaneous and historical notes on FSA boundary definitions |
| `utm_lookup_identifier` | A numeric identifier used for joining county geometries to internal USDA lookup tables related to UTM projection metadata. |
| `state_county_fips_code` | A five-digit FIPS state and county code; Identical to `FIPS_C`. |
| `utm_zone_number` | The Universal Transverse Mercator (UTM) zone in which the county falls. |
| `utm_zone_designator` | The Universal Transverse Mercator (UTM) latitude band designator in which the county falls. |
| `Shape_Length` | The polygon edge length in meters |
| `Shape_Area` | The polygon area in square meters |

## 🗂️ Simplified TopoJSON Version

A simplified version of the `FSA_Counties_dd17` dataset is included in
this repository as `fsa-counties-dd17.topojson`. This version was
created to reduce geometric complexity and ensure compatibility with
common web mapping tools.

### 🔧 Processing Steps

This workflow processes the USDA Farm Service Agency (FSA) county
definitions to produce a clean, simplified, and TopoJSON-compatible
version of the dataset, suitable for use in web mapping applications.

#### 1. Load and Preprocess FSA County Data

- Load the original county boundaries from a zipped file geodatabase:  
  `FSA_Counties_dd17.gdb.zip`
- Exclude U.S. territories by filtering out counties with `FIPSST`
  codes:
  - American Samoa (`60`), Guam (`66`), Northern Mariana Islands (`69`),
    Puerto Rico (`72`), U.S. Virgin Islands (`78`), etc.
- Retain only the `FSA_STCOU` field and rename it to `id` for clarity.

#### 2. Normalize Geometries

- Perform a **round-trip** to GeoJSON:
  - Write the filtered data to a temporary `.geojson` file.
  - Read it back into R using `sf::read_sf()`.
- This step removes non-standard geometries (e.g., curved edges or arcs)
  that may interfere with simplification or projection.

#### 3. Transform and Simplify Geometries

- Project all features to the WGS84 coordinate reference system.
- Use `rmapshaper::ms_explode()` to break multi-part polygons into
  single-part features.
- Recombine features by `id` using `ms_dissolve()` to ensure unique
  county geometries.
- Apply `ms_simplify(keep = 0.01)` to reduce geometric complexity while
  preserving topology.

#### 4. Clip to Official TIGER/Line Boundaries

- Download generalized U.S. county boundaries via the `tigris` package:
  - Use `cb = TRUE` and `resolution = "5m"` for cartographic accuracy.
- Use `ms_explode()` and `ms_dissolve()` to produce a clean national
  boundary.
- Clip FSA geometries to the national boundary using `ms_clip()`,
  removing slivers and enforcing alignment.

#### 5. Further Geometry Cleaning

- Use `sf::st_make_valid()` to repair any topological errors.
- Repeat explode/dissolve operations as needed to clean up geometry
  structure.
- Reposition Alaska, Hawaii, and outlying areas using
  `tigris::shift_geometry()` for optimal layout in web maps.
- Convert all features to `MULTIPOLYGON` geometries.
- Sort features by `id` to ensure consistent ordering.

#### 6. Export Cleaned Data

- Save the cleaned and simplified geometries to
  `fsa-counties-dd17.geojson`.

#### 7. Post-process with Mapshaper (CLI)

- Use Mapshaper to:
  - Clean and reorient geometry: `-clean rewind`
  - Derive a new `state` field from the first two characters of `id`:  
    `-each 'state=id.slice(0,2)'`
  - Merge counties into states: `-dissolve field=state`
  - Rename layers: `counties` and `states`
  - Quantize coordinates for TopoJSON compression: `quantization=1e5`
- Export the result as `fsa-counties-dd17.topojson`.

#### 8. Cleanup

- Remove the temporary GeoJSON file to tidy the workspace.

------------------------------------------------------------------------

## 🛠️ How to Use

1.  Unzip the `FSA_Counties_dd17.gdb.zip` file.
2.  Open the `.gdb` in a GIS software environment such as
    [QGIS](https://qgis.org) or [ArcGIS
    Pro](https://www.esri.com/en-us/arcgis/products/arcgis-pro/overview).
3.  Use the layer properties to explore attributes and spatial coverage.

------------------------------------------------------------------------

## 📍 Quick Start: Visualize the FSA_Counties_dd17 topojson data in R

This snippet shows how to load the fsa-counties-dd17.topojson file from
the archive and create a simple map using `sf` and `ggplot2`.

``` r
# Load required libraries
library(sf)
library(ggplot2) # For plotting
library(tigris)  # For state boundaries
library(rmapshaper) # For innerlines function

## Download the FSA_Counties_dd17 archive
counties <- 
  sf::read_sf("https://sustainable-fsa.github.io/fsa-counties-dd17/fsa-counties-dd17.topojson",
              layer = "counties") |>
  sf::st_set_crs("EPSG:4326") |>
  sf::st_transform("EPSG:5070")

# Plot the map
ggplot(counties) +
  geom_sf(data = sf::st_union(counties),
          fill = "grey80",
          color = NA) +
  geom_sf(data = counties,
          aes(fill = state), 
          color = NA,
          show.legend = FALSE) +
  geom_sf(data = rmapshaper::ms_innerlines(counties),
          fill = NA,
          color = "white",
          linewidth = 0.1) +
  geom_sf(data = counties |>
            dplyr::group_by(state) |>
            dplyr::summarise() |>
            rmapshaper::ms_innerlines(),
          fill = NA,
          color = "white",
          linewidth = 0.2) +
  labs(title = "FSA County Administrative Boundaries",
       subtitle = "Derived from the FSA_Counties_dd17 dataset") +
  theme_void()
```

<img src="./example-1.png" style="display: block; margin: auto;" />

------------------------------------------------------------------------

## 📌 Background

The dataset originates from the **dd17** schema, a legacy geospatial
data standard used by the USDA Farm Service Agency (FSA) for structuring
county-level datasets. It served as a spatial index for county-level
geospatial products and was used in conjunction with the **Common Land
Unit (CLU)** framework.

While the dataset may no longer be updated or actively distributed by
the USDA, it remains of historical and analytical interest —
particularly for referencing USDA program boundaries, disaster
assistance eligibility, and other geospatial analysis across agriculture
and conservation.

## 📜 Citation

If using this data in published work, consider citing it as:

> USDA Farm Service Agency. *FSA_Counties_dd17 Geospatial Dataset*.
> Accessed via GitHub archive, YYYY. Original metadata reference: [1-GIS
> Amendment 2
> (2009)](https://www.fsa.usda.gov/Internet/FSA_File/1-gis_r00_a02.pdf).

## 📄 License

Data in the `FSA_Counties_dd17.gdb.zip` archive were produced by the
United States Department of Agriculture (USDA), which are in the public
domain under U.S. law (17 USC § 105).

You are free to:

- Use, modify, and distribute the data for any purpose
- Include it in derivative works or applications, with or without
  attribution

If you modify or build upon the data, you are encouraged (but not
required) to clearly mark any changes and cite this repository as the
source of the original.

> No warranty is provided. Use at your own risk.

The derivative `fsa-counties-dd17.topojson` file was created by R. Kyle
Bocinsky and is released under the [Creative Commons CCZero
license](https://creativecommons.org/publicdomain/zero/1.0/).

The [`fsa-counties-dd17.R`](fsa-counties-dd17.R) script is copyright R.
Kyle Bocinsky, and is released under the [MIT License](LICENSE).

## ⚠️ Disclaimer

This dataset is archived for reference and educational use. It may not
reflect current administrative boundaries and should not be used for
official USDA program administration. Always consult the USDA or state
FSA office for current data.

## 👏 Acknowledgment

This work is part of the [*Enhancing Sustainable Disaster Relief in
FSA Programs: Non-stationarity at the Intersection of Normal Grazing
Periods and US Drought
Assessment*](https://www.ars.usda.gov/research/project/?accnNo=444612)
project. It is supported by US Department of Agriculture Office of the
Chief Economist (OCE), Office of Energy and Environmental Policy (OEEP)
funds passed through to Research, Education, and Economics mission area.
We also acknowledge and appreciate the assistance of the USDA Climate
Hubs in securing these data.

## ✉️ Contact

Please contact Kyle Bocinsky (<kyle.bocinsky@umontana.edu>) with any
questions.
