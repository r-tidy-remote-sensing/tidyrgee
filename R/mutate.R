#' @export
mutate.tidyee <- function(x,...){
  vrt <- x$vrt |>
    dplyr::mutate(...)
  create_tidyee(x$ee_ob,vrt)
}


#' @export
mutate.ee.imagecollection.ImageCollection <- function(x,...){
  stopifnot(!is.null(x), inherits(x, "ee.imagecollection.ImageCollection"))
  cat(crayon::yellow("`mutate` does not work directly on ImageCollections.\nTherefore, your object is being converted to a `tidyee` class object. This could take a handful of seconds on a huge imageCollection. It's recommended to run `as_tidyee(imageCollection_object)` as a first step in your tidyee workflows")
  )
  x_tidy <- as_tidyee(x)
  x_tidy |>
    mutate(...)
}

#' mutate columns into tidyee vrt which can later be used to modify tidyee ImageCollection
#' @name mutate
#' @rdname mutate
#' @param x tidyee class object (list of ee_ob, vrt)
#' @param ... mutate arguments
#' @return tidyee object with vrt component containing new mutated cols
#' @examples \dontrun{
#'library(tidyrgee)
#' library(rgee)
#' ee_Initialize()
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' modis_ic_tidy <- as_tidyee(modis_ic)
#'}

#' @seealso \code{\link[dplyr]{mutate}} for information about mutate on normal data tables.
#' @export
#' @importFrom dplyr mutate
NULL
