#' @name ee_year_composite
#' @param imageCol ee$ImageCollection
#' @param stat A \code{character} indicating what to reduce the imageCollection by,
#'  e.g. 'median' (default), 'mean',  'max', 'min', 'sum', 'sd', 'first'.
#' @param startDate \code{character} format date, e.g. "2018-10-23".
#' @param endDate \code{character} format date, e.g. "2018-10-23".
#'
#'

ee_year_composite<-  function(imageCol,
                              stat,
                              start_date,
                              end_date,
                              ...){

  stopifnot(!is.null(imageCol), inherits(imageCol, "ee.imagecollection.ImageCollection"))

  start_year = lubridate::year(start_date)
  end_year = lubridate::year(end_date)
  years = ee$List$sequence(start_year, end_year)
  ee_reducer <-  stat_to_reducer_full(stat)

  # dont really think this pre-filter simplifies code or saves any time...leaving for now

  ic_temp_pre_filt <- imageCol |> ee_year_filter(start_date=start_date,
                                                 end_date=end_date)

  ee$ImageCollection$fromImages(
    years$map(rgee::ee_utils_pyfunc(function (y) {
      ic_temp_filtered <- ic_temp_pre_filt$filter(ee$Filter$calendarRange(y, y, 'year'))
      indexString = ee$Number(y)$format('%03d')
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
