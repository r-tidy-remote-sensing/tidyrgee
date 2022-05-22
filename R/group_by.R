

#' @export
group_by.ee.imagecollection.ImageCollection <- function(x,...){
  stopifnot(!is.null(x), inherits(x, "ee.imagecollection.ImageCollection"))
  convert_to_tidyee_warning()
  x_tidy <- as_tidyee(x)
  x_tidy |>
    group_by(...)
}


#' @export
group_by.tidyee <- function(x,...){
  vrt <- x$vrt |>
    dplyr::group_by(...)
  create_tidyee(x$ee_ob,vrt)
}



#' Group an imageCollection or tidyee object with Imagecollections by a parameter
#' @name group_by
#' @rdname group_by
#' @param x ee$ImageCollection or tidyee object
#' @param ... group_by variables
#' @return ee$ImageCollection with grouped_vars attribute
#' @examples \dontrun{
#' library(tidyrgee)
#' ee_Initialize()
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' modis_ic |>
#'    filter(date>="2016-01-01",date<="2019-12-31") |>
#'    group_by(year)
#' }
#' @seealso \code{\link[dplyr]{group_by}} for information about group_by on normal data tables.
#' @importFrom dplyr group_by
#' @export
NULL
