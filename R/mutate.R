#' mutate
#'
#' @param x tidyee class object (list of ee_ob, vrt)
#' @param ... mutate arguments
#'
#' @return tidyee object with vrt component containing new mutated cols
#' @export
#'
#' @examples \dontrun{
#'library(tidyrgee)
#' library(rgee)
#' ee_Initialize()
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' modis_ic_tidy <- as_tidyee(modis_ic)
#'}

mutate <-  function(x, ...){
  UseMethod("mutate")
}

#' @export
mutate.tidyee <- function(x,...){
  vrt <- x$vrt |>
    dplyr::mutate(...)
  create_tidyee(x$ee_ob,vrt)
}
