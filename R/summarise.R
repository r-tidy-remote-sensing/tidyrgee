#' @rdname summarise
#' @name summarise
#' @export
#' @return ee$Image or ee$ImageCollection where pixels are summarised by group_by and stat
summarise.ee.imagecollection.ImageCollection <-  function(.data,stat,...){
  stopifnot(!is.null(.data), inherits(.data, "ee.imagecollection.ImageCollection"))
  convert_to_tidyee_warning()
  x_tidy <- as_tidyee(.data)
  x_tidy |>
    summarise(
      stat=stat
    )
}

#' @rdname summarise
#' @name summarise
#' @export
#' @return ee$Image or ee$ImageCollection where pixels are summarised by group_by and stat
summarise.tidyee <-  function(.data,stat,...,join_bands=TRUE){
  summary_list <- stat |>
    purrr::map(
      ~.data |>
      summarise_pixels(stat=.x)
      )

  if(length(summary_list)==1){
    return(summary_list[[1]])
  }
  if(length(summary_list)>1 & isTRUE(join_bands)){
  return(purrr::reduce(.x = summary_list,.f = inner_join,"system:time_start"))
  }
  if(length(summary_list)>1 & join_bands==F){
    return(summary_list)
  }
}


#' Summary pixel-level stats for ee$ImageCollection or tidyrgee objects with ImageCollections
#' @rdname summarise
#' @name summarise
#' @param .data ee$Image or ee$ImageCollection
#' @param stat \code{character} stat/function to apply
#' @param ... other arguments
#' @param join_bands \code{logical} (default= TRUE) if multiple stats selected should bands be joined?
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
#' @param .data ee$Image or ee$ImageCollection
#' @param stat stat/function to apply
#' @param ... other arguments
#' @noRd

summarise_pixels <-  function(.data,stat,...){
  group_vars_chr <- dplyr::group_vars(.data$vrt)

  assertthat::assert_that(all(group_vars_chr %in% names(.data$vrt)))
  if(all(group_vars_chr %in% c("year","month"))){
    if(length(group_vars_chr)==0){
      tidyee_output <- ee_composite(x = .data,stat = stat)
    }
    if(length(group_vars_chr)>0){

      years_unique_chr <- unique(.data$vrt$year) |> sort()
      months_unique_chr <- unique(.data$vrt$month) |> sort()

      if(length(group_vars_chr)==1){
        if(group_vars_chr=="year"){
          tidyee_output <-  ee_year_composite(.data,stat = stat)
        }
        if(group_vars_chr=="month"){
          tidyee_output <- ee_month_composite(.data,stat = stat)
        }
      }
      if(length(group_vars_chr)==2 & all(c("month","year")%in%group_vars_chr)){
        # dont want to run year_month composite if there is only
        # 1 month or 1 year in vrt... mapping over ee$List of 1 value throws error.
        if(length(months_unique_chr)==1){
          tidyee_output <-  ee_year_composite(.data,stat = stat)
        }
        if(length(years_unique_chr)==1){
          tidyee_output <- ee_month_composite(.data,stat = stat)
        }else{
          tidyee_output <- ee_year_month_composite(.data,stat = stat)
        }


      }
    }
  }

  if(
    !all (group_vars_chr %in% c("month","year"))&
      length(group_vars_chr)>0
    ){
    # x_split_list <- .data |>
    #   group_split()
    # x_split_summaries <- x_split_list |>
    #   purrr::map( ~ee_composite(x = .x |>
    #                               group_by(!!!rlang::syms(group_vars_chr)),
    #                             stat = stat))

    tidyee_output <- .data |>
      group_split() |>
      purrr::map(
        ~ee_composite(
          .x |>
          group_by(!!!rlang::syms(group_vars_chr)),
          stat=stat)
        ) |>
      bind_ics()
    #previously would just call this:
    # tidyee_output <- bind_ics(x=x_split_summaries)
    #however lets see if taking it out of function gets rid of error
    # ic_only <- x_split_summaries |>
    #   purrr::map("ee_ob")
    # vrt_only <- x_split_summaries |>
    #   purrr::map("vrt")
    #
    # vrt_together<- dplyr::bind_rows(vrt_only)
    #
    # ic_container = ee$ImageCollection(list())
    # for(i in 1:length(ic_only)){
    #   ic_container=ic_container$merge(ic_only[[i]])
    #
    # }
    # tidyee_output <- create_tidyee(x = ic_container$sort(prop = "system:time_start"),vrt = vrt_together )



  }

  return(tidyee_output)
}
