
#' ee_year_filter
#'
#' @param imageCol ee$ImageCollection
#' @param ... other arguments
#'
#' @return ee$ImageCollection or ee$Image filtered by year
#' @export

ee_year_filter <- function(imageCol,...){

  UseMethod('ee_year_filter')

}


#' @export


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

  years = rgee::ee$List$sequence(start_year, end_year)

  ic_list <-
    years$map(rgee::ee_utils_pyfunc(function (y) {
      imageCol$filter(rgee::ee$Filter$calendarRange(y, y, 'year'))
    }

    ))

  fc_from_ic_list <- rgee::ee$FeatureCollection(ic_list)

  cat("returning  ImageCollection of x\n")
  return(rgee::ee$ImageCollection(fc_from_ic_list$flatten()))

}
