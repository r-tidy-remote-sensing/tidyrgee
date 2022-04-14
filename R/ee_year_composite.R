
#' @title Filter by Year
#' @param imageCol An earth engine ImageCollection
#' @param ... extra args to pass on
#'
#' @export
#'


#' @name ee_year_composite
#' @param stat A \code{character} indicating what to reduce the imageCollection by,
#'  e.g. 'median' (default), 'mean',  'max', 'min', 'sum', 'sd', 'first'.
#' @param startDate \code{character} format date, e.g. "2018-10-23".
#' @param endDate \code{character} format date, e.g. "2018-10-23".
#'
#'

ee_year_composite<-  function(imageCol,
                              stat,
                              startDate,
                              endDate,
                              ...){

  stopifnot(!is.null(imageCol), inherits(imageCol, "ee.imagecollection.ImageCollection"))

  startYear = lubridate::year(startDate)
  endYear = lubridate::year(endDate)
  years = ee$List$sequence(startYear, endYear)

  ee_reducer <-  stat_to_reducer(stat)

  ee$ImageCollection$fromImages(
    years$map(rgee::ee_utils_pyfunc(function (y) {
      indexString = ee$Number(y)$format('%03d')
      ic_temp_filtered <- imageCol$filter(ee$Filter$calendarRange(y, y, 'year'))
      ee_reducer(ic_temp_filtered)$
        set('system:index', indexString)$
        set('year',y)$
        set('month',1)$
        set('date',ee$Date$fromYMD(y,1,1))$
        # set('system:time_start',ee$Date$fromYMD(y,m,1))$
        set('system:time_start',ee$Date$millis(ee$Date$fromYMD(y,1,1)))
    }

    ))
  )
}
