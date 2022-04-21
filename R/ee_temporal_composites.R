#' ee_year_composite
#' @param imageCol ee$ImageCollection
#' @param stat A \code{character} indicating what to reduce the imageCollection by,
#'  e.g. 'median' (default), 'mean',  'max', 'min', 'sum', 'sd', 'first'.
#' @param start_date \code{character} format date, e.g. "2018-10-23".
#' @param end_date \code{character} format date, e.g. "2018-10-23".
#' @param ... other arguments
#' @export
#'

ee_year_composite<-  function(imageCol,
                              stat,
                              start_date,
                              end_date,
                              ...){

  stopifnot(!is.null(imageCol), inherits(imageCol, "ee.imagecollection.ImageCollection"))

  start_year = lubridate::year(start_date)
  end_year = lubridate::year(end_date)
  years = rgee::ee$List$sequence(start_year, end_year)
  ee_reducer <-  stat_to_reducer_full(stat)

  # dont really think this pre-filter simplifies code or saves any time...leaving for now

  ic_temp_pre_filt <- imageCol |> ee_year_filter(start_date=start_date,
                                                 end_date=end_date)

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
