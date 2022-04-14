

summarise <-  function(x, stat,...){
  UseMethod('summarise')

}


#' summarise (method for imageCollections)
#'
#' @param x ee$Image or ee$ImageCollection
#' @param stat stat/function to apply
#' @param ...
#'
#' @return
#' @export
#'
#' @examples \dontrun{
#' library(tidyrgee)
#' ee_Initialize()
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' modis_ic |>
#'    filter(date>="2016-01-01",date<="2019-12-31") |>
#'    group_by(year) |>
#'    summarise(stat="max")
#' }
#'

summarise.grouped_imageCol <-  function(x,stat,...){
  date_range <-  date_range_imageCol(x)
  if(attributes(x)$grouped_vars =="year"){


    ee_year_composite(imageCol = x,
                                stat=stat,startDate=date_range[1],
                                endDate=date_range[2])
  }

}
