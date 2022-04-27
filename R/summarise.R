#' summarise (method for imageCollections)
#'
#' @param x ee$Image or ee$ImageCollection
#' @param stat stat/function to apply
#' @param ... other arguments
#'
#' @return ee$Image or ee$ImageCollection where pixels are summarised by group_by and stat
#' @export
#'
#' @examples \dontrun{
#' library(tidyrgee)
#' ee_Initialize()
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' modis_ic |>
#'    filter(date>="2016-01-01",date<="2019-12-31") |>
#'    group_by(year) |>
#'    summarise(stat="max")
#' }
#'

summarise <-  function(x, stat,...){
  UseMethod('summarise')

}




#' @export
summarise.grouped_imageCol <-  function(x,stat,...){
  date_range <-  date_range_imageCol(x)
  start_year <- lubridate::year(date_range[1])
  end_year <- lubridate::year(date_range[2])
  year <- c(start_year,end_year)
  if(attributes(x)$grouped_vars =="year"){


    ee_year_composite(imageCol = x,year = year,stat = stat)
  }

}

#' @export
summarise.tidyee <-  function(x,stat,...){
  group_vars_chr <- dplyr::group_vars(x$vrt)
  if(length(group_vars_chr)==0){
    ee_reducer <-  stat_to_reducer_full(stat)
    ic_summarised <-  ee_reducer(x$ee_ob)
    vrt_summarised <- x$vrt |>
      summarise(
        dates_summarised= list(date),.groups = "drop"
        )
    tidyee_output <- create_tidyee(x = ic_summarised,vrt = vrt_summarised)
  }
  if(length(group_vars_chr)>0){

    # as.character(range(x$vrt$date))

    years_unique_chr <- unique(x$vrt$year) |> sort()
    months_unique_chr <- unique(x$vrt$month) |> sort()


    if(length(group_vars_chr)==1){
      if(group_vars_chr=="year"){
      tidyee_output <-  ee_year_composite(x,stat = stat)
      # summarise vrt
    }
      if(group_vars_chr=="month"){

      tidyee_output <- ee_month_composite(x,stat = stat)
      # summarise vrt
      }
    }
    if(length(group_vars_chr)==2 & all(c("month","year")%in%group_vars_chr)){
      tidyee_output <- ee_year_month_composite(x,stat = stat)
      # summarise vrt

    }
    return(tidyee_output)






  }



}
