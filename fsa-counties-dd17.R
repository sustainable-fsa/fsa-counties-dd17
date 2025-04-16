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
  dplyr::select(`FSA Code` = FSA_STCOU,
                `State Name` = STATENAME,
                `County Name` = FSA_Name) %>%
  {
    # Round-trip to geojson to get rid of strange curved geometry
    tmp <- tempfile(fileext = ".geojson")
    sf::write_sf(., tmp,
                 delete_dsn = TRUE)
    sf::read_sf(tmp)
  } %>%
  dplyr::group_by(`FSA Code`, `State Name`, `County Name`) %>%
  dplyr::summarise(.groups = "drop") %>%
  sf::st_transform("EPSG:5070") %>%
  sf::st_make_valid() %>%
  sf::st_intersection(  
    tigris::counties(cb = TRUE) %>%
      sf::st_union() %>%
      sf::st_transform("EPSG:5070")
  ) %>%
  rmapshaper::ms_simplify(keep = 0.015) %>%
  sf::st_make_valid() %>%
  sf::st_transform("OGC:CRS84") %>%
  sf::st_make_valid() %T>%
  sf::write_sf("fsa-counties-dd17.geojson",
               delete_dsn = TRUE)
