#'
#' #' Title
#' #'
#' #' @param .data
#' #' @param ...
#' #'
#' #' @return
#' #' @export
#' #'
#' #' @examples \dontrun{
#'
#'
#' library(rgee)
# library(lubridate)
# library(tidyrgee)
# library(tidyverse)
# ee_Initialize()
# baseline <-  2000:2021
# satellite <-  "terra"
# yoi <- 2021
# # date_range <- c()
# modis_link <- get_modis_link(satellite)
# modisIC <- ee$ImageCollection("MODIS/061/MOD13Q1")
# # modis_ndvi <- cloud_scale_modis_ndvi(x = modisIC,mask="cloud&quality")
# modis_ndvi_tidy <- as_tidyee(modisIC)
#
# recent <-  modis_ndvi_tidy |>
#   filter(year %in% yoi) |>
#   mutate(
#     ag_season = if_else(doy %in% lubridate::yday(x = as.Date("2022-06-20")):
#                           lubridate::yday(x = as.Date("2022-09-26")),
#                         "growing_season","not_growing")
#   ) |>
#
#   group_by(ag_season) |>
#   summarise(stat= list("mean"))
# recent$vrt |> arrange(time_start)
# # recent$ee_ob$sort(prop = "system:time_start")$aggregate_array("system:time_start")$getInfo()
# # recent$ee_ob$sort(prop = "system:time_start",opt_ascending = FALSE) |> ee_get_date_ic()
# recent$ee_ob$sort(prop = "system:time_start",opt_ascending = T) |> ee_get_date_ic()
# debugonce(mutate_extra)
# bla <- modis_ndvi_tidy |>
#   filter(year %in% yoi) |>
#   mutate_extra(
#     ag_season = if_else(doy %in% lubridate::yday(x = as.Date("2022-06-20")):
#                           lubridate::yday(x = as.Date("2022-09-26")),
#                         "growing_season","not_growing"),
#     rando= if_else(doy %in% 1:100,"asdf","bbb")
#   )
#
# bla$ee_ob$aggregate_array("ag_season")$getInfo()
# debugonce(summarise_pixels)
#
# debugonce(mutate)
# mutate.prop <-  function()
#
 # }
#' mutate_extra <- function(.data,
#'                          ...){
#'   new_col_names <- .data$vrt |>
#'     dplyr::transmute(...) |> colnames()
#'   vrt <- .data$vrt |>
#'     dplyr::mutate(...) |>
#'     arrange(.data$time_start)
#'
#'   ee_ob <- .data$ee_ob$sort(prop = "system:time_start",opt_ascending = T)
#'
#'   tidyrgee:::inner_join.ee.imagecollection.ImageCollection
#'   ics<-new_col_names |>
#'     purrr::map(~{
#'       ee_new_prop <- ee$List(vrt[[.x]])
#'       idx_list = ee$List$sequence(0,ee_new_prop$size()$subtract(1))
#'       ic_list = ee_ob$toList(ee_ob$size())
#'       ic_temp <- ee$ImageCollection(
#'         idx_list$map(rgee::ee_utils_pyfunc(
#'           function(idx){
#'             img = ee$Image(ic_list$get(idx))
#'             #create as string
#'             idx_string = ee$String(ee_new_prop$get(idx))
#'             img$set(.x, idx_string)
#'           }))
#'       )
#'       return(ic_temp)
#'     }
#'     )
#'  filter <- ee$Filter$equals(
#'    leftField= "system:index",
#'    rightField= "system:index"
#'  )
#'
#'  simpleJoin = ee$Join$saveAll()
#'  ic<-ee$ImageCollection(purrr::reduce(ics,simpleJoin$apply,filter))
#'  ic$aggregate_array("ag_season")$getInfo()
#'  ic$aggregate_array("rando")$getInfo()
#'  var simpleJoined = simpleJoin.apply(primary, secondary, filter);
#'   # ic <- purrr::reduce(ics, inner_join,"system:time_start")
#'
#'   create_tidyee(ics,vrt)
#'
#' }
