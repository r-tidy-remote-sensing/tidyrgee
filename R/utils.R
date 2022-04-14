
#' date_range_imageCol
#'
#' @param x imageCollection or image
#' @description a fast-working helper function to extract min and max date ranges for image collections
#'
#' @return sorted date vector (length 2)
#' @export
#'
#' @examples \donrun{
#' library(tidyrgee)
#' ee_Initialize()
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' date_range_imageCol(modis_ic)
#' }
#'

date_range_imageCol <-  function(x){
  time_start_list <- x$aggregate_array("system:time_start")
  time_start_list_fmt <- time_start_list$map(
    rgee::ee_utils_pyfunc( function(x){
      ee$Date(x)$format("YYYY-MM-dd")

    })
  )
  time_start_list_fmt$sort()$getInfo()  |>
    lubridate::ymd() |>
    range()



}
