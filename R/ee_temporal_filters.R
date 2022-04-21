
ee_year_filter <- function(imageCol,...){

  UseMethod('ee_year_filter')

}

#' @name ee_year_filter
#' @param stat A \code{character} indicating what to reduce the imageCollection by,
#'  e.g. 'median' (default), 'mean',  'max', 'min', 'sum', 'sd', 'first'.
#' @param startDate \code{character} format date, e.g. "2018-10-23".
#' @param endDate \code{character} format date, e.g. "2018-10-23".
#' @export
#'
#'

ee_year_filter.ee.imagecollection.ImageCollection <-  function(imageCol,
                                                               start_date,
                                                               end_date,
                                                               ...){

  stopifnot(!is.null(imageCol), inherits(imageCol, "ee.imagecollection.ImageCollection"))
  if(is.numeric(start_date) & nchar(start_date)==4){
    start_year = start_date
    end_year = end_date
  }else{
    start_year = lubridate::year(start_date)
    end_year = lubridate::year(end_date)
  }

  years = ee$List$sequence(start_year, end_year)

  ic_list <-
    years$map(rgee::ee_utils_pyfunc(function (y) {
      imageCol$filter(ee$Filter$calendarRange(y, y, 'year'))
    }

    ))

  fc_from_ic_list <- ee$FeatureCollection(ic_list)

  cat("returning  ImageCollection of x\n")
  return(ee$ImageCollection(fc_from_ic_list$flatten()))

}
