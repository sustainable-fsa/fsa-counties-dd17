# install.packages("pak")
# pak::pak(
#   c("magrittr",
#     "tidyverse",
#     "sf",
#     "tigris",
#     "rmapshaper")
# )

library(magrittr)
library(tidyverse)
library(sf)
library(tigris)
library(rmapshaper)

## The FSA county definitions
## Create a simplified version
sf::read_sf("/vsizip/FSA_Counties_dd17.gdb.zip") %>%
  {
    # Round-trip to geojson to get rid of strange curved geometry
    tmp <- tempfile(fileext = ".geojson")
    sf::write_sf(., tmp,
                 delete_dsn = TRUE)
    sf::read_sf(tmp)
  } %>%
  sf::st_transform("EPSG:5070") %>%
  sf::st_make_valid() %>%
  sf::st_intersection(  
    tigris::counties(cb = TRUE) %>%
      sf::st_union() %>%
      sf::st_transform("EPSG:5070")
  ) %>%
  #presimplify
  rmapshaper::ms_simplify() %>%
  sf::st_make_valid() %>%
  sf::st_transform("EPSG:4326") %>%
  dplyr::filter(!(STATENAME %in%
                    c("American Samoa",
                      "Northern Mariana Islands",
                      "Guam",
                      "Virgin Islands of the U.S."))) %>%
  dplyr::select(id = FSA_STCOU) %>%
  dplyr::group_by(id) %>%
  dplyr::summarise(.groups = "drop") %>%
  sf::st_cast("MULTIPOLYGON") %>%
  sf::st_make_valid() %T>%
  geojsonio::geojson_write(input = ., 
                           file = "fsa-counties-dd17.geojson",
                           object_name = "counties",
                           convert_wgs84 = FALSE,
                           crs = 4326,
                           overwrite = TRUE) %>%
  tigris::shift_geometry() %>%
  sf::st_make_valid() %>%
  sf::st_transform("EPSG:4326") %>%
  sf::st_make_valid() %>%
  sf::st_cast("MULTIPOLYGON") %>%
  sf::st_make_valid() %>%
  geojsonio::geojson_write(input = ., 
                           file = "fsa-counties-dd17-albers.geojson",
                           object_name = "counties",
                           convert_wgs84 = FALSE,
                           crs = 4326,
                           overwrite = TRUE)

system(
'
#   Converts a GeoJSON to TopoJSON, cleaning up intermediates.
geojson_to_topojson() {
  local GEOJSON="$1"
  if [[ -z "$GEOJSON" || ! -f "$GEOJSON" ]]; then
    echo "Usage: geojson_to_topojson <input.geojson> [<output.topojson>]" >&2
    return 1
  fi

  # derive base name and defaults
  local BASE="${GEOJSON%.geojson}"
  local NDJSON="${BASE}.ndjson"
  local TOPOJSON="${2:-${BASE}.topojson}"

  echo "📤 Converting $GEOJSON → $NDJSON"
  geojson2ndjson "$GEOJSON" \\
    | ndjson-map "d.id = d.properties.id, delete d.properties, d" \\
    > "$NDJSON"

  echo "🧭 Building TopoJSON → $TOPOJSON"
  geo2topo -q 1e5 -n counties="${NDJSON}" \\
    | toposimplify -f -s 1e-7 \\
    | topomerge states=counties -k "d.id.slice(0,2)" \\
    | topomerge nation=states \\
    > "$TOPOJSON"

  echo "🧹 Removing intermediates: $GEOJSON, $NDJSON"
  rm -f "$GEOJSON" "$NDJSON"

  echo "✅ Done: $TOPOJSON"
}

geojson_to_topojson fsa-counties-dd17.geojson
geojson_to_topojson fsa-counties-dd17-albers.geojson
'
)
