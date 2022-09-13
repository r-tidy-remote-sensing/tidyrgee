
#' ee_year_filter
#'
#' @param imageCol ee$ImageCollection
#' @param year \code{numeric} vector containing years (i.e c(2001,2002,2003))
#' @param ... other arguments
#'
#' @return ee$ImageCollection or ee$Image filtered by year
#' @export

ee_year_filter <- function(imageCol,year,...){

  UseMethod('ee_year_filter')

}


#' @export


ee_year_filter.ee.imagecollection.ImageCollection <-  function(imageCol,
                                                               year,
                                                               ...){


  stopifnot(!is.null(imageCol), inherits(imageCol, "ee.imagecollection.ImageCollection"))

  # should make assertion for no duplicates

  ee_year_list <- rgee::ee$List(year) # switched from ee$List$sequence - let the user make sequence in R or suppply raw

  ic_list <-
    ee_year_list$map(rgee::ee_utils_pyfunc(function (y) {
      imageCol$filter(rgee::ee$Filter$calendarRange(y, y, 'year'))
    }

    ))

  fc_from_ic_list <- rgee::ee$FeatureCollection(ic_list)

  message("returning  ImageCollection of x\n")
  return(rgee::ee$ImageCollection(fc_from_ic_list$flatten()))

}


#' ee_month_filter
#'
#' @param imageCol ee$ImageCollection
#' @param month \code{numeric} vector containing month values (1-12)
#' @param ... other arguments
#'
#' @return ee$ImageCollection or ee$Image filtered by month
#' @export

ee_month_filter <- function(imageCol,month,...){
  UseMethod('ee_month_filter')
}


#' @export
ee_month_filter.ee.imagecollection.ImageCollection <-  function(imageCol,
                                                                month,
                                                               ...){

  stopifnot(!is.null(imageCol), inherits(imageCol, "ee.imagecollection.ImageCollection"))
  assertthat::assert_that(is.numeric(month)&length(month)>1,
                          msg = "month must be a numeric vector of lenght greater than 0")
  assertthat::assert_that(all(month %in% c(1:12)),
                          msg = "month values must be integeer inside 1-12 range")

  # should make assertion for no duplicates

  ee_month_list <- rgee::ee$List(month) # switched from ee$List$sequence - let the user make sequence in R or suppply raw

  ic_list <-
    ee_month_list$map(rgee::ee_utils_pyfunc(function (m) {
      imageCol$filter(rgee::ee$Filter$calendarRange(m, m, 'month'))
    }

    ))

  fc_from_ic_list <- rgee::ee$FeatureCollection(ic_list)

  message("returning  ImageCollection of x\n")
  return(rgee::ee$ImageCollection(fc_from_ic_list$flatten()))

}

#' ee_year_month_filter
#'
#' @param imageCol ee$ImageCollection
#' @param year \code{numeric} vector contain years to filter
#' @param month \code{numeric} vector contain months to filter
#' @param ... other arguments
#'
#' @return ee$ImageCollection or ee$Image filtered by year & month
#' @export

ee_year_month_filter <- function(imageCol,year, month,...){

  UseMethod('ee_year_month_filter')

}


#' @export

ee_year_month_filter.ee.imagecollection.ImageCollection <-  function(imageCol,
                                                                     year,
                                                                     month,
                                                                     ...){
  # assertions
  stopifnot(!is.null(imageCol), inherits(imageCol, "ee.imagecollection.ImageCollection"))
  assertthat::assert_that(is.numeric(year)&length(year)>0,
                          msg = "year must be a numeric vector of lenght greater than 0")
  assertthat::assert_that(is.numeric(month)&length(month)>0,
                          msg = "month must be a numeric vector of lenght greater than 0")

  yr_ic <-  ee_year_filter(imageCol = imageCol,year=year)
  yr_mo_ic <-  ee_month_filter(imageCol=yr_ic,month=month)
  return(yr_mo_ic)





}
