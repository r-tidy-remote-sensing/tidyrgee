
#' ee_roll
#' @description rolling statistics on imageCollection. Written to be analagous to `terra::roll`. Currently only has options
#'   for "right" aligned rolling statistcs and window units of days.
#' @param x imageCollection
#' @param window \code{numeric} look back in days
#' @param stat \code{character} stat/function to roll with
#' @return imageCollection where each image represents the rolling sum of for specified window "right" aligned
#' @section TODO: a.) include window_unit argument, b.) include alignment arg, c.) write tidyee/ic methods
#' @export
#'
#' @examples \dontrun{
#' library(rgee)
#' library(tidyverse)
#'  ee_Initialize()
#'  chirps_link <- "UCSB-CHG/CHIRPS/DAILY"
#'  chirps <- ee$ImageCollection(chirps_link)
#'  x <- chirps$filterDate("2021-01-01","2022-01-01")
#'  rolling_10_max <- ee_roll_stat(x = x,window = 10, stat="sum")
#' }

ee_roll <- function(x, window,stat){
  ee_reducer <- tidyrgee:::stat_to_reducer_full(stat)
  first_img_date <- ee$Date(x$sort("system:time_start",TRUE)$first()$get("system:time_start"))
  last_img_date <- ee$Date(x$sort("system:time_start",FALSE)$first()$get("system:time_start"))

  first_date_roll <- first_img_date$advance(window-1,"days")

  dates_to_map <- x$filterDate(first_date_roll,last_img_date)$
    aggregate_array("system:time_start")

  x_roll <- rgee::ee$ImageCollection$fromImages(
    dates_to_map$map(ee_utils_pyfunc(function(dt){
      dt_incl <- ee$Date(dt)$advance(ee$Number(1),"day")
      start_date <- ee$Date(dt)$advance(ee$Number(window-1)$multiply(-1), "day")
      x_temp <- x$filterDate(start_date, dt_incl)
      x_reduced <- ee_reducer(x_temp)
      x_reduced$set('system:time_start',dt)
    }
    )
    )
  )
  return(x_roll)
}
