
#' @export
filter.tidyee <- function(x,...){
  vrt <- x$vrt |>
    dplyr::filter(...)
  date_chr <-  vrt$date |>
    lubridate::as_date() |>
    as.character()

  ee_date_list = rgee::ee$List(date_chr)$
    map(rgee::ee_utils_pyfunc(
      function(date){
        rgee::ee$Date$millis(date)
      }
    )
    )
  ic_filt = x$ee_ob$filter(ee$Filter$inList("system:time_start", ee_date_list))
  # adding this assertion add 1-2 secs onto the process-- maybe should just be a test....
  # assertthat::assert_that(nrow(vrt)==ic_filt$size()$getInfo(),
  #                         msg = "mismatch in vrt and ee_ob - check function and objects" )

  return(create_tidyee(x=ic_filt,vrt=vrt))
}


#' @export
filter.ee.imagecollection.ImageCollection <- function(x,...){
  stopifnot(!is.null(x), inherits(x, "ee.imagecollection.ImageCollection"))

  convert_to_tidyee_warning()

  x_tidy <- as_tidyee(x)
  x_tidy |>
    filter(...) |>
    as_ee()

  }



#' filter ee$ImageCollections or tidyee objects that contain imageCollections
#' @name filter
#' @rdname filter
#' @param x imageCollection or tidyee class object
#' @param ... other arguments
#' @return filtered image or imageCollection form filtered imageCollection
#' @examples \dontrun{
#'
#' library(rgee)
#' library(tidyrgee)
#' ee_Initialize()
#' l8 = ee$ImageCollection('LANDSAT/LC08/C01/T1_SR')
#' l8 |>
#'     filter(date>"2016-01-01",date<"2016-03-04")
#'
#'
#'  # example with tidyee ckass
#
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' modis_ic_tidy <- as_tidyee(modis_ic)
#'
#' # filter by month
#' modis_march_april <- modis_ic_tidy |>
#' filter(month %in% c(3,4))
#' }
#' @seealso \code{\link[dplyr]{filter}} for information about filter on normal data tables.
#' @importFrom dplyr filter
#' @export

NULL


