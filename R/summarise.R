
#' @export
summarise.ee.imagecollection.ImageCollection <-  function(x,stat,...){
  stopifnot(!is.null(x), inherits(x, "ee.imagecollection.ImageCollection"))
  convert_to_tidyee_warning()
  x_tidy <- as_tidyee(x)
  x_tidy |>
    summarise(
      stat=stat
    )
}



#' @export
summarise.tidyee <-  function(x,stat,...){
  summary_list <- stat |>
    purrr::map(
      ~x |>
      summarise_pixels(stat=.x)
      )

  # will this have issue when length(summary_list)==1? dont think so
  purrr::reduce(.x = summary_list,.f = inner_join,"system:time_start")


}


#' Summary pixel-level stats for ee$ImageCollection or tidyrgee objects with ImageCollections
#' @rdname summarise
#' @name summarise
#' @param x ee$Image or ee$ImageCollection
#' @param stat \code{character} stat/function to apply
#' @param ... other arguments
#' @return ee$Image or ee$ImageCollection where pixels are summarised by group_by and stat
#' @examples \dontrun{
#' library(tidyrgee)
#' library(rgee)
#' ee_Initialize()
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' modis_ic |>
#'    filter(date>="2016-01-01",date<="2019-12-31") |>
#'    group_by(year) |>
#'    summarise(stat="max")
#' }
#' @seealso \code{\link[dplyr]{summarise}} for information about summarise on normal data tables.
#' @export
#' @importFrom dplyr summarise
NULL





#' Summary pixel-level stats for ee$ImageCollection or tidyrgee objects with ImageCollections
#' @rdname summarise_pixels
#' @name summarise_pixels
#' @param x ee$Image or ee$ImageCollection
#' @param stat stat/function to apply
#' @param ... other arguments
#' @export

summarise_pixels <-  function(x,stat,...){
  group_vars_chr <- dplyr::group_vars(x$vrt)

  assertthat::assert_that(all(group_vars_chr %in% names(x$vrt)))
  if(all(group_vars_chr %in% c("year","month"))){
    if(length(group_vars_chr)==0){
      tidyee_output <- ee_composite(x = x,stat = stat)
    }
    if(length(group_vars_chr)>0){

      years_unique_chr <- unique(x$vrt$year) |> sort()
      months_unique_chr <- unique(x$vrt$month) |> sort()

      if(length(group_vars_chr)==1){
        if(group_vars_chr=="year"){
          tidyee_output <-  ee_year_composite(x,stat = stat)
        }
        if(group_vars_chr=="month"){
          tidyee_output <- ee_month_composite(x,stat = stat)
        }
      }
      if(length(group_vars_chr)==2 & all(c("month","year")%in%group_vars_chr)){
        # dont want to run year_month composite if there is only
        # 1 month or 1 year in vrt... mapping over ee$List of 1 value throws error.
        if(length(months_unique_chr)==1){
          tidyee_output <-  ee_year_composite(x,stat = stat)
        }
        if(length(years_unique_chr)==1){
          tidyee_output <- ee_month_composite(x,stat = stat)
        }else{
          tidyee_output <- ee_year_month_composite(x,stat = stat)
        }


      }
    }
  }

  if(!any(group_vars_chr %in% c("month","year"))& length(group_vars_chr)>0){
    x_split_list <- x |>
      group_split()
    x_split_summaries <- x_split_list |>
      purrr::map( ~ee_composite(x = .x |>
                                  group_by(!!!rlang::syms(group_vars_chr)),
                                stat = stat))
    tidyee_output <- bind_ics(x_split_summaries)


  }

  return(tidyee_output)
}
