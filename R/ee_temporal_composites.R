#' @title Pixel level composite by year
#' @rdname ee_year_composite
#' @param x An earth engine ImageCollection or tidyee class.
#' @param stat A \code{character} indicating what to reduce the imageCollection by,
#'  e.g. 'median' (default), 'mean',  'max', 'min', 'sum', 'sd', 'first'.
#' @param year \code{numeric} vector containing years (i.e c(2001,2002,2003))

#' @param ... other arguments
#' @export
#'

ee_year_composite <- function(x,...){
  UseMethod('ee_year_composite')
}


#' @name ee_year_composite
#' @export
ee_year_composite.ee.imagecollection.ImageCollection<-  function(x,
                                                                 stat,
                                                                 year,
                                                                 ...){

  stopifnot(!is.null(x), inherits(x, "ee.imagecollection.ImageCollection"))

  # start_year = lubridate::year(start_date)
  # end_year = lubridate::year(end_date)
  years = rgee::ee$List(year)
  ee_reducer <-  stat_to_reducer_full(stat)

  # dont really think this pre-filter simplifies code or saves any time...leaving for now

  ic_temp_pre_filt <- x |>
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

#' @name ee_year_composite
#' @export
ee_year_composite.tidyee<-  function(x,
                                     stat,
                                     ...){

  stopifnot(!is.null(x), inherits(x, "tidyee"))
  years_unique_chr <- unique(x$vrt$year) |> sort()
  # start_year = lubridate::year(start_date)
  # end_year = lubridate::year(end_date)
  ee_years_list = rgee::ee$List(years_unique_chr)
  ee_reducer <-  stat_to_reducer_full(stat)


  ic_summarised <- rgee::ee$ImageCollection$fromImages(
    ee_years_list$map(rgee::ee_utils_pyfunc(function (y) {
      ic_temp_filtered <- x$ee_ob$filter(rgee::ee$Filter$calendarRange(y, y, 'year'))
      indexString <-  rgee::ee$Number(y)$format('%03d')
      idString <- ee$String("composited_yyyy_")$cat(indexString)
      ee_reducer(ic_temp_filtered)$
        set('system:id',idString)$
        set('system:index', indexString)$
        set('year',y)$
        set('month',1)$
        set('date',rgee::ee$Date$fromYMD(y,1,1))$
        # set('system:time_start',ee$Date$fromYMD(y,m,1))$
        set('system:time_start',rgee::ee$Date$millis(rgee::ee$Date$fromYMD(y,1,1)))
    }

    ))
  )
  client_bandnames<- paste0(vrt_band_names(x),"_",stat)
  vrt_summarised <- x$vrt |>
    dplyr::summarise(
      dates_summarised= list(date),
      number_images= n(),
      time_start= min(time_start),
      time_end= max(time_start),
      .groups = "drop"
    ) |>
    mutate(
      band_names= list(client_bandnames),
      tidyee_index= dplyr::row_number()-1
      )
  create_tidyee(ic_summarised,vrt_summarised)
}








#' @title Pixel-level composite by month
#' @rdname ee_month_composite
#' @param x An earth engine ImageCollection or tidyee class.
#' @param stat A \code{character} indicating what to reduce the imageCollection by,
#'  e.g. 'median' (default), 'mean',  'max', 'min', 'sum', 'sd', 'first'.
#' @param months A vector of months, e.g. c(1, 12).
#' @param ... extra args to pass on
#' @export
#'

ee_month_composite <- function(x, ...){

  UseMethod('ee_month_composite')

}




#' @name ee_month_composite
#' @export
ee_month_composite.ee.imagecollection.ImageCollection <- function(x, stat, months, ...){

  ee_month_list = rgee::ee$List(months)

  stopifnot(!is.null(x), inherits(x, "ee.imagecollection.ImageCollection"))

  ee_reducer <- stat_to_reducer_full(stat)

  rgee::ee$ImageCollection$fromImages(
    ee_month_list$map(rgee::ee_utils_pyfunc(function (m) {
      indexString = rgee::ee$Number(m)$format('%03d')
      ic_temp_filtered <- x$filter(rgee::ee$Filter$calendarRange(m, m, 'month'))
      ee_reducer(ic_temp_filtered)$
        set('system:index', indexString)$
        set('year',0000)$
        set('month',m)$
        set('date',rgee::ee$Date$fromYMD(1,m,1))$
        # set('system:time_start',ee$Date$fromYMD(y,m,1))$
        set('system:time_start',rgee::ee$Date$millis(rgee::ee$Date$fromYMD(1,m,1)))
    }
    )))

}

#' @name ee_month_composite
#' @export
ee_month_composite.tidyee <- function(x, stat, ...){

  stopifnot(!is.null(x), inherits(x, "tidyee"))
  months_unique_chr <- unique(x$vrt$month) |> sort()
  ee_months_list = rgee::ee$List(months_unique_chr)

  ee_reducer <- stat_to_reducer_full(stat)

  ic_summarised <- rgee::ee$ImageCollection$fromImages(
    ee_months_list$map(rgee::ee_utils_pyfunc(function (m) {
      indexString = rgee::ee$Number(m)$format('%03d')
      ic_temp_filtered <- x$ee_ob$filter(rgee::ee$Filter$calendarRange(m, m, 'month'))
      ee_reducer(ic_temp_filtered)$
        set('system:id',indexString)$
        set('system:index', indexString)$
        set('year',0000)$
        set('month',m)$
        set('date',rgee::ee$Date$fromYMD(1,m,1))$
        # set('system:time_start',ee$Date$fromYMD(y,m,1))$
        set('system:time_start',rgee::ee$Date$millis(rgee::ee$Date$fromYMD(1,m,1)))
    }
    )))
  client_bandnames<- paste0(vrt_band_names(x),"_",stat)

  vrt_summarised <- x$vrt |>
    dplyr::summarise(
      dates_summarised= list(date),.groups = "drop",
      number_images= n(),
      time_start= min(time_start),
      time_end= max(time_start)
    ) |>
    mutate(
      band_names = list(client_bandnames)
    )



  create_tidyee(ic_summarised,vrt_summarised)

}


#' @title Pixel-level composite by year and month
#' @rdname ee_year_month_composite
#' @param x An earth engine ImageCollection or tidyee class.
#' @param stat A \code{character} indicating what to reduce the ImageCollection by,
#'  e.g. 'median' (default), 'mean',  'max', 'min', 'sum', 'sd', 'first'.
#' @param startDate \code{character} format date, e.g. "2018-10-23".
#' @param endDate \code{character} format date, e.g. "2018-10-23".
#' @param months \code{numeric} vector, e.g. c(1,12).
#' @param ... args to pass on.
#' @export
#'
#'
ee_year_month_composite <- function(x,
                                    ...){

  UseMethod('ee_year_month_composite')

}

#' @name ee_year_month_composite
#' @export
ee_year_month_composite.ee.imagecollection.ImageCollection <-  function(x,
                                                                     stat,
                                                                     startDate,
                                                                     endDate,
                                                                     months,
                                                                     ...
){

  stopifnot(!is.null(x), inherits(x, "ee.imagecollection.ImageCollection"))


  startYear = lubridate::year(startDate)
  endYear = lubridate::year(endDate)

  years = rgee::ee$List$sequence(startYear, endYear)

  months = rgee::ee$List$sequence(months[1], months[2])

  ee_reducer <-  stat_to_reducer_full(stat)

  rgee::ee$ImageCollection(rgee::ee$FeatureCollection(years$map(rgee::ee_utils_pyfunc(function (y) {

    yearCollection = x$filter(rgee::ee$Filter$calendarRange(y, y, 'year'))

    rgee::ee$ImageCollection$fromImages(

      months$map(rgee::ee_utils_pyfunc(function (m) {

        indexString = rgee::ee$Number(m)$format('%03d')
        ic_temp_filtered <- yearCollection$filter(rgee::ee$Filter$calendarRange(m, m, 'month'))
        ee_reducer(ic_temp_filtered)$
          set('system:index', indexString)$
          set('year',y)$
          set('month',m)$
          set('date',rgee::ee$Date$fromYMD(y,m,1))$
          # set('system:time_start',ee$Date$fromYMD(y,m,1))$
          set('system:time_start',rgee::ee$Date$millis(rgee::ee$Date$fromYMD(y,m,1)))

      }))
    )

  })))$flatten())
}

#' @name ee_year_month_composite
#' @export
ee_year_month_composite.tidyee <-  function(x, stat, ...
){

  stopifnot(!is.null(x), inherits(x, "tidyee"))


  # after running the calendarRange maps there is a strange behavior which
  # warrants the need to post-filter.
  start_post_filter <- lubridate::floor_date(min(x$vrt$date),"month") |> as.character()
  end_post_filter <- lubridate::as_date(max(x$vrt$date)) |> as.character()


  years_unique_chr <- unique(x$vrt$year) |> sort()
  months_unique_chr <- unique(x$vrt$month) |> sort()

  # if(length(years_unique_chr)==1){
  #   ee_years_list = rgee::ee$List(ee$Number(years_unique_chr))
  # }
  # if(length(years_unique_chr)>1){
  #   ee_years_list = rgee::ee$List(years_unique_chr)
  # }
  # if(length(months_unique_chr)==1){
  #   ee_months_list = rgee::ee$List(ee$Number(months_unique_chr))
  # }
  # if(length(months_unique_chr)>1){
  #   ee_months_list = rgee::ee$List(months_unique_chr)
  # }
  ee_months_list = rgee::ee$List(months_unique_chr)
  ee_years_list = rgee::ee$List(years_unique_chr)

  ee_reducer <-  stat_to_reducer_full(stat)

  ic_summarised <- rgee::ee$ImageCollection(
    rgee::ee$FeatureCollection(ee_years_list$map(rgee::ee_utils_pyfunc(function (y) {

    yearCollection = x$ee_ob$filter(rgee::ee$Filter$calendarRange(y, y, 'year'))

    rgee::ee$ImageCollection$fromImages(

      ee_months_list$map(rgee::ee_utils_pyfunc(function (m) {
        yearString <- rgee::ee$Number(y)$format('%04d')
        monthString <- rgee::ee$Number(m)$format('%03d')
        # indexString <-  rgee::ee$Number(m)$format('%03d')
        indexString <-  yearString$cat(monthString)
        idString <- ee$String("composited_yyyymmm_")$cat(indexString)
        ic_temp_filtered <- yearCollection$filter(rgee::ee$Filter$calendarRange(m, m, 'month'))
        ee_reducer(ic_temp_filtered)$
          # set('system:id',idString)$
          set('system:index', indexString)$
          set('year',y)$
          set('month',m)$
          set('date',rgee::ee$Date$fromYMD(y,m,1))$
          # set('system:time_start',ee$Date$fromYMD(y,m,1))$
          set('system:time_start',rgee::ee$Date$millis(rgee::ee$Date$fromYMD(y,m,1)))

      }))
    )

  })))$flatten())


  # think we could recreate the new index client side for filter with `system:index` eventually
  # yrmo_combinations <- x$vrt |>
  #   distinct(year,month) |>
  #   dplyr::mutate(yrmo=paste0(year,month)) |>
  #   pull(yrmo)
  #
  # index_vec <- years_unique_chr |>
  #   expand.grid(months_unique_chr) |>
  #   dplyr::mutate(
  #     yrmo=paste0(Var1,Var2),
  #     index_vec=paste0(Var1,sprintf("%03d",Var2))
  #   ) |>
  #   filter(yrmo %in% yrmo_combinations) |>
  #   pull(index_vec)
  #

  # Need to filter yrmo composite to original date range or you can end up with empty slots
  # for months that didn't occur yet

  ic_summarised <-  ic_summarised$filterDate(start_post_filter,end_post_filter)
  client_bandnames<- paste0(vrt_band_names(x),"_",stat)
  vrt_summarised <- x$vrt |>
    # nest(data=date)
    dplyr::summarise(
      dates_summarised= list(date),.groups = "drop",
      number_images= n(),
      time_start= min(date),
      time_end= max(date)
    ) |>
    mutate(
      band_names= list(client_bandnames)
    )

  create_tidyee(ic_summarised,vrt_summarised)

}



#' @title ee_composite
#'
#' @param x tidyee object containing `ee$ImageCollection`
#' @param stat  A \code{character} indicating what to reduce the imageCollection by,
#'  e.g. 'median' (default), 'mean',  'max', 'min', 'sum', 'sd', 'first'.
#' @param ... other arguments
#'
#' @export
#'


ee_composite <-  function(x,
                          ...){
  UseMethod("ee_composite")
}

#' @name ee_composite
#' @export
ee_composite.tidyee <-  function(x,
                                 stat,
                                 ...){

  ee_reducer <-  stat_to_reducer_full(stat)
  ic_summarised <- ee_reducer(x$ee_ob)
  min_year <- min(x$vrt$year)
  min_month <- min(x$vrt$month)

  ic_summarised <- ic_summarised$
    set('year',min_year)$
    set('month',min_month)$
    set('date',rgee::ee$Date$fromYMD(min_year,min_month,1))$
    set('system:time_start',rgee::ee$Date$millis(rgee::ee$Date$fromYMD(min_year,min_month,1)))

  client_bandnames<- paste0(vrt_band_names(x),"_",stat)

  vrt_summarised <- x$vrt |>
    # dplyr::tibble() |>
    dplyr::summarise(
      dates_summarised= list(date),.groups = "drop"
    ) |>
    mutate(
      band_names= list(client_bandnames)
    )


  create_tidyee(ic_summarised,vrt_summarised)


}

