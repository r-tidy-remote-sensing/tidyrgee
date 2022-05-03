#' @export
select.tidyee <-  function(x,...){
  dots <- list(...)
  if(is.null(names(dots))){
    ic_selected=x$ee_ob$select(unname(dots))
    attributes(x$vrt)$band_names <- unname(dots)
  }
  if(!is.null(names(dots))){
    name_lookup <- data.frame(
      new_name= names(dots),
      old_name=dots |>
        unname() |>
        unlist()
    )
    name_lookup <- name_lookup |> dplyr::mutate(new_name=dplyr::if_else(new_name=="",old_name,new_name))
    ic_selected <- x$ee_ob$map(
      function(img){
        img$select(unname(dots))$rename(name_lookup$new_name)
      }
    )
    attributes(x$vrt)$band_names <- name_lookup$new_name
  }
  tidyrgee:::create_tidyee(ic_selected, x$vrt)
}

#' Select bands from ee$Image or ee$ImageCollection
#' @name select
#' @rdname select
#' @param x tidyee class object containing ee$ImageCollection or ee$Image
#' @param ... one or more quoted or unquoted expressions separated by commas.
#' @return tidyee class object with specified (...) bands selected
#' @examples \dontrun{
#' library(tidyrgee)
#' ee_Initialize()
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' modis_ic_tidy <- as_tidyee(modis_ic)
#'
#' # select NDVI band
#' modis_ndvi <- modis_ic_tidy |>
#'    select("NDVI")
#'
#' # select NDVI band, but change band to new name
#' modis_ndvi_renamed <- modis_ic_tidy |>
#'    select(ndvi_new= "NDVI")
#'
#'
#' }
#' @seealso \code{\link[dplyr]{select}} for information about select on normal data tables.
#' @export
#' @importFrom dplyr select
NULL



