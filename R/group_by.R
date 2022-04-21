

#' group_by
#'
#' @param x ee$ImageCollection
#' @param ... group_by variables  (must be "month", "year" or combination of the two)
#'
#' @return ee$ImageCollection with grouped_vars attribute
#' @export
#'
#' @examples \dontrun{
#' library(tidyrgee)
#' ee_Initialize()
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' modis_ic |>
#'    filter(date>="2016-01-01",date<="2019-12-31") |>
#'    group_by(year)
#' }

group_by <-  function(x, ...){
  UseMethod('group_by')

}


#' @export
group_by.ee.imagecollection.ImageCollection <- function(x,...){

  new_groups <- rlang::enquos(..., .ignore_empty = "all")

  class(x) <- c("grouped_imageCol", class(x))
  new_groups_list <- new_groups |> purrr::map(~rlang::quo_get_expr(.x))
  new_groups_chr <- as.character(unlist(new_groups_list))

  assertthat::assert_that(new_groups_chr %in% c("year","month") ,
                          msg = "so far can only group by year, month, or both")
  cat(glue::glue("returning imageCol grouped by {new_groups_chr}\n"))
  attr(x,"grouped_vars") <- new_groups_chr
  return(x)

}
