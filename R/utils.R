#' stat_to_reducer
#' @param fun \code{character} rstats fun (i.e "mean" , "median")


# there are particular use-cases where you need this syntax vs the syntax below
stat_to_reducer <- function(fun){ switch(
  fun,
  "mean" = ee$Reducer$mean(),
  "max" = ee$Reducer$mean(),
  "min" = ee$Reducer$min(),
  "median"= ee$Reducer$median(),
  "sum"= ee$Reducer$sum(),
  "sd" = ee$Reducer$stdDev(),
  "first" = ee$Reducer$first(),
  NULL
)
}


#' stat_to_reducer_full - helper function - useful in ee_*_composite funcs
#' @param fun reducer/statistic using typical r-syntax (character)

stat_to_reducer_full <-  function(fun){switch(fun,

                                              "mean" = function(x)x$reduce(ee$Reducer$mean()),
                                              "max" = function(x)x$reduce(ee$Reducer$max()),
                                              "min" = function(x)x$reduce(ee$Reducer$min()),
                                              "median"= function(x)x$reduce(ee$Reducer$median()),
                                              "sum"= function(x)x$reduce(ee$Reducer$sum()),
                                              "sd" =  function(x)x$reduce(ee$Reducer$stdDev()),
                                              NULL

)
}









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
