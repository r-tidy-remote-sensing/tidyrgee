#' stat_to_reducer
#' @param fun \code{character} rstats fun (i.e "mean" , "median")


# there are particular use-cases where you need this syntax vs the syntax below
stat_to_reducer <- function(fun){ switch(
  fun,
  "mean" = rgee::ee$Reducer$mean(),
  "max" = rgee::ee$Reducer$mean(),
  "min" = rgee::ee$Reducer$min(),
  "median"= rgee::ee$Reducer$median(),
  "sum"= rgee::ee$Reducer$sum(),
  "sd" = rgee::ee$Reducer$stdDev(),
  "first" = rgee::ee$Reducer$first(),
  NULL
)
}


#' stat_to_reducer_full - helper function - useful in ee_*_composite funcs
#' @param fun reducer/statistic using typical r-syntax (character)

stat_to_reducer_full <-  function(fun){switch(fun,

                                              "mean" = function(x)x$reduce(rgee::ee$Reducer$mean()),
                                              "max" = function(x)x$reduce(rgee::ee$Reducer$max()),
                                              "min" = function(x)x$reduce(rgee::ee$Reducer$min()),
                                              "median"= function(x)x$reduce(rgee::ee$Reducer$median()),
                                              "sum"= function(x)x$reduce(rgee::ee$Reducer$sum()),
                                              "sd" =  function(x)x$reduce(rgee::ee$Reducer$stdDev()),
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
#' @examples \dontrun{
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
      rgee::ee$Date(x)$format("YYYY-MM-dd")

    })
  )
  time_start_list_fmt$sort()$getInfo()  |>
    lubridate::ymd() |>
    range()



}



#' vrt_band_names
#'
#' @param x tidyee class object
#' @return a character vector of band_names
#' @export
#' @importFrom rlang .data

vrt_band_names <-  function(x){
  x$vrt |>
    dplyr::pull(.data$band_names) |>
    unique() |>
    unlist()
}

# logicals ---------------------------------------------------------------

#' geometry_type_is_unique
#' @param x sf object
#' @return \code{logical} indicating whether geometry type is unique in sf object

geometry_type_is_unique <- function(x){
  length(unique(sf::st_geometry_type(x)))==1
}


convert_to_tidyee_warning <- function(){
  cat(
    crayon::yellow("We recommend you always start your `tidyee` flow by first converting and storing your object to class `tidyee` with the function:"),
    crayon::green("`as_tidyee()`."),
    crayon::yellow("Using `tidyverse/dplyr`-style functions on `ee$ImageCollections` directly can be slow on large ImageCollections.\n"))
}

