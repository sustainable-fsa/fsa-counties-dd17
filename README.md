[![GitHub Release](https://img.shields.io/github/v/release/climate-smart-usda/fsa-counties-dd17?label=GitHub%20Release&color=%239c27b0)](https://github.com/climate-smart-usda/fsa-counties-dd17)
[![DOI](https://zenodo.org/badge/967595011.svg)](https://zenodo.org/badge/latestdoi/967595011)

This repository contains an archival copy of the **FSA_Counties_dd17** dataset, originally distributed by the U.S. Department of Agriculture (USDA) Farm Service Agency (FSA) as part of the Common Land Unit (CLU) geospatial data series.

## 📦 Dataset Overview

-   **Title:** FSA_Counties_dd17
-   **Source:** USDA Farm Service Agency (FSA)
-   **Format:** ESRI File Geodatabase (.gdb)
-   **Original Reference:** [USDA FSA GIS Metadata Standards (1-GIS, Amendment 2)](https://www.fsa.usda.gov/Internet/FSA_File/1-gis_r00_a02.pdf)
-   **Distribution Type:** Public archival for research and historical purposes
-   **Date of Archive:** 2025-04-16

## 📂 Contents

The zipped geodatabase includes polygon features representing U.S. counties, attributed with identifiers used by the FSA for administrative and mapping purposes. It was prepared according to the USDA’s GIS Data Standards.

-   [`FSA_Counties_dd17.gdb.zip`](https://climate-smart-usda.github.io/fsa-counties-dd17/FSA_Counties_dd17.gdb.zip) – Original USDA File Geodatabase
-   [`fsa-counties-dd17.topojson`](https://climate-smart-usda.github.io/fsa-counties-dd17/fsa-counties-dd17.geojson) – Simplified TopoJSON version (see below)
-   [`fsa-counties-dd17-albers.topojson`](https://climate-smart-usda.github.io/fsa-counties-dd17/fsa-counties-dd17.geojson) – Simplified TopoJSON version with pre-inset Alaska/Hawaii/Puerto Rico (see below)
-   [`fsa-counties-dd17.R`](https://climate-smart-usda.github.io/fsa-counties-dd17/fsa-counties-dd17.R) – R script that produces the Simplified TopoJSON versions

## 🧾 Field Descriptions

| Field Name | Description |
|-----------------------------------|-------------------------------------|
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

A simplified version of the `FSA_Counties_dd17` dataset is included in this repository as `fsa-counties-dd17.topojson`. This version was created to reduce geometric complexity and ensure compatibility with common web mapping tools.

### 🔧 Processing Steps

The GeoJSON file was generated using the R `sf`, `tigris`, and `rmapshaper` packages, along with command line topojson tools. The following steps were performed:

1. **Ingest and normalize FSA county definitions**  
   - Reads the zipped File Geodatabase (`/vsizip/FSA_Counties_dd17.gdb.zip`).  
   - Round‑trips through a temporary GeoJSON to flatten any curved geometries.  
   - Ensures all geometries are valid.

2. **Project, clip and simplify**  
   - Reprojects to Conus Albers (EPSG:5070).  
   - Clips to the union of all U.S. counties (dropping out‑of‑bounds pieces).  
   - Simplifies topology with Mapshaper, repairs any invalid geometries, then reprojects back to WGS84 (EPSG:4326).

3. **Dissolve and filter**  
   - Excludes non‑contiguous U.S. territories (American Samoa, Guam, etc.).  
   - Keeps only the `FSA_STCOU` field (renamed to `id`).  
   - Dissolves by `id` so each FSA code is a single polygon.

4. **Export GeoJSON files**  
   - Writes **fsa‑counties‑dd17.geojson** (raw geographic layout).  
   - Applies `tigris::shift_geometry()` to inset Alaska/Hawaii, then writes **fsa‑counties‑dd17‑albers.geojson**.

5. **Inline TopoJSON conversion & cleanup**  
   Inside a single `system()` call, the script:
   - **Defines** a shell function `geojson_to_topojson()` that:
     1. Derives base names: strips `.geojson` to get `<base>`, sets `<base>.ndjson` and `<base>.topojson`.  
     2. **Converts GeoJSON → NDJSON** via `geojson2ndjson` + `ndjson-map` (extracting each feature’s `id`).  
     3. **Builds TopoJSON** with `geo2topo`, `toposimplify`, and two `topomerge` steps (first into states, then nation).  
     4. **Removes** the original `.geojson` and intermediate `.ndjson`.  
   - **Invokes** `geojson_to_topojson` on both `fsa-counties-dd17.geojson` and `fsa-counties-dd17-albers.geojson`.

## 🛠️ How to Use

1.  Unzip the `FSA_Counties_dd17.gdb.zip` file.
2.  Open the `.gdb` in a GIS software environment such as [QGIS](https://qgis.org) or [ArcGIS Pro](https://www.esri.com/en-us/arcgis/products/arcgis-pro/overview).
3.  Use the layer properties to explore attributes and spatial coverage.

## 📌 Background

The dataset originates from the **dd17** schema, a legacy geospatial data standard used by the USDA Farm Service Agency (FSA) for structuring county-level datasets. It served as a spatial index for county-level geospatial products and was used in conjunction with the **Common Land Unit (CLU)** framework.

While the dataset may no longer be updated or actively distributed by the USDA, it remains of historical and analytical interest — particularly for referencing USDA program boundaries, disaster assistance eligibility, and other geospatial analysis across agriculture and conservation.

## 📜 Citation

If using this data in published work, consider citing it as:

> USDA Farm Service Agency. *FSA_Counties_dd17 Geospatial Dataset*. Accessed via GitHub archive, YYYY. Original metadata reference: [1-GIS Amendment 2 (2009)](https://www.fsa.usda.gov/Internet/FSA_File/1-gis_r00_a02.pdf).

## 📄 License

Data in the `FSA_Counties_dd17.gdb.zip` archive were produced by the United States Department of Agriculture (USDA), which are in the public domain under U.S. law (17 USC § 105).

You are free to: 

  - Use, modify, and distribute the data for any purpose 
  - Include it in derivative works or applications, with or without attribution

If you modify or build upon the data, you are encouraged (but not required) to clearly mark any changes and cite this repository as the source of the original.

> No warranty is provided. Use at your own risk.

The derivatives `fsa-counties-dd17.topojson` and `fsa-counties-dd17-albers.topojson` were created by R. Kyle Bocinsky and are released under the [Creative Commons CCZero license](https://creativecommons.org/publicdomain/zero/1.0/).

The [`fsa-counties-dd17.R`](fsa-counties-dd17.R) script is copyright R. Kyle Bocinsky, and is released under the [MIT License](LICENSE).

## ⚠️ Disclaimer

This dataset is archived for reference and educational use. It may not reflect current administrative boundaries and should not be used for official USDA program administration. Always consult the USDA or state FSA office for current data.

## 👏 Acknowledgment

This work is part of the [*Enhancing Climate-smart Disaster Relief in FSA Programs: Non-stationarity at the Intersection of Normal Grazing Periods and US Drought Assessment*](https://www.ars.usda.gov/research/project/?accnNo=444612) project. It is supported by US Department of Agriculture Office of the Chief Economist (OCE), Office of Energy and Environmental Policy (OEEP) funds passed through to Research, Education, and Economics mission area. We also acknowledge and appreciate the assistance of the USDA Climate Hubs in securing these data.

## ✉️ Contact

Please contact Kyle Bocinsky ([kyle.bocinsky@umontana.edu](mailto:kyle.bocinsky@umontana.edu)) with any questions.
