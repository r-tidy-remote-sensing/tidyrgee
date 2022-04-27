#' ee_year_composite
#' @param imageCol ee$ImageCollection
#' @param stat A \code{character} indicating what to reduce the imageCollection by,
#'  e.g. 'median' (default), 'mean',  'max', 'min', 'sum', 'sd', 'first'.
#' @param year \code{numeric} vector containing years (i.e c(2001,2002,2003))

#' @param ... other arguments
#' @export
#'

ee_year_composite<-  function(imageCol,
                              stat,
                              year,
                              ...){

  stopifnot(!is.null(imageCol), inherits(imageCol, "ee.imagecollection.ImageCollection"))

  # start_year = lubridate::year(start_date)
  # end_year = lubridate::year(end_date)
  years = rgee::ee$List(year)
  ee_reducer <-  stat_to_reducer_full(stat)

  # dont really think this pre-filter simplifies code or saves any time...leaving for now

  ic_temp_pre_filt <- imageCol |>
    ee_year_filter(year = year)

  rgee::ee$ImageCollection$fromImages(
    years$map(rgee::ee_utils_pyfunc(function (y) {
      ic_temp_filtered <- ic_temp_pre_filt$filter(rgee::ee$Filter$calendarRange(y, y, 'year'))
      indexString = rgee::ee$Number(y)$format('%03d')
      ee_reducer(ic_temp_filtered)$
        set('system:index', indexString)$
        set('year',y)$
        set('month',1)$
        set('date',rgee::ee$Date$fromYMD(y,1,1))$
        # set('system:time_start',ee$Date$fromYMD(y,m,1))$
        set('system:time_start',rgee::ee$Date$millis(rgee::ee$Date$fromYMD(y,1,1)))
    }

    ))
  )
}

#' @title Filter by Month
#' @param imageCol An earth engine ImageCollection
#' @param ... extra args to pass on
#' @export
#'

ee_month_composite <- function(imageCol,stat,month, ...){

  UseMethod('ee_month_composite')

}





#' @name ee_month_composite
#' @param stat A \code{character} indicating what to reduce the imageCollection by,
#'  e.g. 'median' (default), 'mean',  'max', 'min', 'sum', 'sd', 'first'.
#' @param months \code{numeric} vector, e.g. c(1,12).
#' @export

ee_month_composite.ee.imagecollection.ImageCollection <- function(imageCol, stat, month, ...){

  ee_month_list = ee$List(month)

  stopifnot(!is.null(imageCol), inherits(imageCol, "ee.imagecollection.ImageCollection"))

  ee_reducer <- stat_to_reducer(stat)

  ee$ImageCollection$fromImages(
    ee_month_list$map(rgee::ee_utils_pyfunc(function (m) {
      indexString = ee$Number(m)$format('%03d')
      ic_temp_filtered <- imageCol$filter(ee$Filter$calendarRange(m, m, 'month'))
      ee_reducer(ic_temp_filtered)$
        set('system:index', indexString)$
        set('year',0000)$
        set('month',m)$
        set('date',ee$Date$fromYMD(1,m,1))$
        # set('system:time_start',ee$Date$fromYMD(y,m,1))$
        set('system:time_start',ee$Date$millis(ee$Date$fromYMD(1,m,1)))
    }
    )))

}



ee_year_month_composite <- function(imageCol, ...){

  UseMethod('ee_year_month_composite')

}

#' @name ee_year_month_composite
#' @param stat A \code{character} indicating what to reduce the imageCollection by,
#'  e.g. 'median' (default), 'mean',  'max', 'min', 'sum', 'sd', 'first'.
#' @param startDate \code{character} format date, e.g. "2018-10-23".
#' @param endDate \code{character} format date, e.g. "2018-10-23".
#' @param months \code{numeric} vector, e.g. c(1,12).
#' @export
#'
#'

ee_year_month_composite.ee.imagecollection.ImageCollection <-  function(imageCol,
                                                                     stat,
                                                                     startDate,
                                                                     endDate,
                                                                     months,
                                                                     ...
){

  stopifnot(!is.null(imageCol), inherits(imageCol, "ee.imagecollection.ImageCollection"))


  startYear = lubridate::year(startDate)
  endYear = lubridate::year(endDate)

  years = ee$List$sequence(startYear, endYear)

  months = ee$List$sequence(months[1], months[2])

  ee_reducer <-  stat_to_reducer(stat)

  ee$ImageCollection(ee$FeatureCollection(years$map(rgee::ee_utils_pyfunc(function (y) {

    yearCollection = imageCol$filter(ee$Filter$calendarRange(y, y, 'year'))

    ee$ImageCollection$fromImages(

      months$map(rgee::ee_utils_pyfunc(function (m) {

        indexString = ee$Number(m)$format('%03d')
        ic_temp_filtered <- yearCollection$filter(ee$Filter$calendarRange(m, m, 'month'))
        ee_reducer(ic_temp_filtered)$
          set('system:index', indexString)$
          set('year',y)$
          set('month',m)$
          set('date',ee$Date$fromYMD(y,m,1))$
          # set('system:time_start',ee$Date$fromYMD(y,m,1))$
          set('system:time_start',ee$Date$millis(ee$Date$fromYMD(y,m,1)))

      }))
    )

  })))$flatten())
}


#' @name ee_year_month_composite
#' @param stat A \code{character} indicating what to reduce the imageCollection by,
#'  e.g. 'median' (default), 'mean',  'max', 'min', 'sum', 'sd', 'first'.
#' @param startDate \code{character} format date, e.g. "2018-10-23".
#' @param endDate \code{character} format date, e.g. "2018-10-23".
#' @param months \code{numeric} vector, e.g. c(1,12).
#' @export
#'
#'

ee_year_month_composite.tidyee <-  function(x,...
){

  stopifnot(!is.null(x), inherits(x, "tidyee"))





  years = ee$List$sequence(startYear, endYear)

  months = ee$List$sequence(months[1], months[2])

  ee_reducer <-  stat_to_reducer(stat)

  ee$ImageCollection(ee$FeatureCollection(years$map(rgee::ee_utils_pyfunc(function (y) {

    yearCollection = imageCol$filter(ee$Filter$calendarRange(y, y, 'year'))

    ee$ImageCollection$fromImages(

      months$map(rgee::ee_utils_pyfunc(function (m) {

        indexString = ee$Number(m)$format('%03d')
        ic_temp_filtered <- yearCollection$filter(ee$Filter$calendarRange(m, m, 'month'))
        ee_reducer(ic_temp_filtered)$
          set('system:index', indexString)$
          set('year',y)$
          set('month',m)$
          set('date',ee$Date$fromYMD(y,m,1))$
          # set('system:time_start',ee$Date$fromYMD(y,m,1))$
          set('system:time_start',ee$Date$millis(ee$Date$fromYMD(y,m,1)))

      }))
    )

  })))$flatten())
}


