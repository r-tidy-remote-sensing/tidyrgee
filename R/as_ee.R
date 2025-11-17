#' @title as_ee tidyee to ee$ImageCollection or ee$Image
#'
#' @param x tidyee
#'
#' @return ee$ImageCollection or ee$Image
#' @export
#'
#' @examples \dontrun{
#' library(rgee)
#' library(tidyrgee)
#'
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#'
#' # create tidyee class
#' modis_ic_tidy <- as_tidyee(modis_ic)
#' # convert back to origina ee$ImageCollection class
#' modis_ic_tidy |>
#'   as_ee()
#' }
as_ee <- function(x) {
  UseMethod("as_ee")
}


#' @export
as_ee.tidyee <- function(x) {
  x$ee_ob
}
