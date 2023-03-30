
#' @name rename_stdDev_bands
#' @title rename_stdDev_bands
#' @param x ee$ImageCollection
#' @return x ee$Image/ImageCollection with `.*_stdDev$` bands renamed to `.*_sd$`

rename_stdDev_bands <-  function(x){
  UseMethod("rename_stdDev_bands")
}


#' @export
rename_stdDev_bands.ee.imagecollection.ImageCollection<-function(x){
   x$map(
     function(img){
       bnames_server <- img$bandNames()
       bnames_renamed_server <- bnames_server$
         map(
           rgee::ee_utils_pyfunc(
             function(bname){ee$String(bname)$replace("_stdDev$","_sd")}
           )
         )
       img$select(bnames_server,bnames_renamed_server)
       }
   )
 }

#' @export
rename_stdDev_bands.ee.image.Image<-function(x){
   bnames_server <- x$bandNames()
   bnames_renamed_server <- bnames_server$
     map(
       rgee::ee_utils_pyfunc(
         function(bname){ee$String(bname)$replace("_stdDev$","_sd")}
       )
     )
   x$select(bnames_server,bnames_renamed_server)
 }



#' @noRd
#' @title rename_summary_stat_bands
#' @name rename_summary_stat_bands
#' @param x ee$ImageCollection/ee$Image
#' @param stat statistic
#' @description helper function to rename bands that have been auto-renamed during composite. `rgee` appends on reducer name to band (i.e `band_reducer`). The r-syntax and GEE syntax are the same accept for standard deviation. When images are reduced by standard deviation - this function switches the suffix to r-syntax.
#'
#' @return x ee$Image/ImageCollection with renamed band if `.*_stdDev` bandnames

rename_summary_stat_bands <- function(x, stat){
  if(stat=="sd"){
    res <- rename_stdDev_bands(x)
  }
  else{
    res <-  x
  }
  return(res)
}



#' stat_to_reducer
#' @noRd
#'
#' @param fun \code{character} rstats fun (i.e "mean" , "median")
#'
#' @return `ee$Reducer` class function that can be supplied as reducer type arguments



stat_to_reducer <- function(fun){ switch(
  fun,
  "mean" = rgee::ee$Reducer$mean(),
  "max" = rgee::ee$Reducer$max(),
  "min" = rgee::ee$Reducer$min(),
  "median"= rgee::ee$Reducer$median(),
  "sum"= rgee::ee$Reducer$sum(),
  "sd" = rgee::ee$Reducer$stdDev(),
  "first" = rgee::ee$Reducer$first(),
  NULL
)
}

#' @noRd
#' @title  stat_to_reducer_full - helper function - useful in ee_*_composite funcs
#' @param fun reducer/statistic using typical r-syntax (character)
#' @return `ee$Reducer` function that can be piped or wrapped around `ee$ImageCollections`

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

#' @noRd
#' @name rstat_to_eestat
#' @title rstat_to_eestat - helper function - useful in ee_*_composite functions to get bandNames from vrt
#' @param fun reducer/statistic using typical r-syntax (character)
#' @return rgee/GEE equivalent typical character statistic syntax

rstat_to_eestat <-  function(fun){switch(fun,

                                              "mean" = "mean",
                                              "max" = "max",
                                              "min" = "min",
                                              "median"= "median",
                                              "sum"= "sum",
                                              "sd" =  "stdDev",
                                              NULL

)
}









#' date_range_imageCol
#'
#' @param x imageCollection or image
#' @description a fast-working helper function to extract min and max date ranges for image collections
#' @noRd
#' @return sorted date vector (length 2)
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
#' @name vrt_band_names
#' @noRd
#' @param x tidyee class object
#' @return a character vector of band_names
#' @importFrom rlang .data


vrt_band_names <-  function(x){
  x$vrt |>
    dplyr::pull(.data$band_names) |>
    unique() |>
    unlist()
}



#' last_day_of_month
#' @param year \code{numeric} year
#' @param month_numeric \code{numeric} vector containing months of interest
#' @noRd
#' @return \code{numeric} vector which the last day of each month
#'

last_day_of_month <- function(year,month_numeric){
  lubridate::day(
    lubridate::ceiling_date(
      lubridate::ymd(
        glue::glue("{year}-{c(month_numeric)}-01")
      ),"month"
    )-lubridate::days(1)
  )
}

# logicals ---------------------------------------------------------------
#' @noRd
#' @name geometry_type_is_unique
#' @title geometry_type_is_unique
#' @param x sf object
#' @return \code{logical} indicating whether geometry type is unique in sf object

geometry_type_is_unique <- function(x){
  length(unique(sf::st_geometry_type(x)))==1
}

#' @noRd
#' @return return warning message when filter/summarise is implicitly casting from `Image/ImageCollection` to tidyee class
convert_to_tidyee_warning <- function(){
  message(
    crayon::yellow("We recommend you always start your `tidyee` flow by first converting and storing your object to class `tidyee` with the function:"),
    crayon::green("`as_tidyee()`."),
    crayon::yellow("Using `tidyverse/dplyr`-style functions on `ee$ImageCollections` directly can be slow on large ImageCollections.\n"))
}


# theses `str` methods provide a work around for the "Error in .Call(_reticulate_py_str_impl, x) : reached elapsed time limit"  which was
# occurring due to the object not being able to render in the environment pane
# https://github.com/rstudio/reticulate/issues/1227#issue-1272278478

#' @export
str.ee.imagecollection.ImageCollection <- function(object,...) {
  "A short description of x"
  }


#' @export
str.ee.image.Image <- function(object,...) {
  "A short description of x"
  }

#' Compactly Display the Structure of an Arbitrary R Object
#' @noRd
#' @param object imageCollection or tidyee class object
#' @param ... potential further arguments (required for Method/Generic reasons).
#' @return return str
#' @seealso \code{\link[utils]{str}} for information about str on other R objects.
#' @importFrom utils str
#' @export
NULL





#' ic_list_to_ic
#'
#' @param x ee list made up of imageCollections
#'
#' @return imageCollection

ic_list_to_ic <- function(x){
  rgee::ee$ImageCollection(rgee::ee$FeatureCollection(x)$flatten())
}


