
#' @export
set_idx.tidyee <- function(x,idx_name="tidyee_index"){
  ic_indexed <- set_idx(x$ee_ob, idx_name = idx_name)
  vrt_sorted <- x$vrt |>
    dplyr::arrange(.data$time_start) |>
    dplyr::mutate(
      !!idx_name:=(dplyr::row_number()-1)
    )


  create_tidyee(x = ic_indexed,vrt = vrt_sorted,tidyee_index = F)

}

#' @export
set_idx.ee.imagecollection.ImageCollection <-  function(x,idx_name="tidyee_index"){
  x <- x$sort("sytem:time_start")
  idx_list = ee$List$sequence(0,x$size()$subtract(1))
  ic_list = x$toList(x$size())
  ic_with_idx = ee$ImageCollection(
    idx_list$map(rgee::ee_utils_pyfunc(
      function(idx){
        img = ee$Image(ic_list$get(idx))
        # // format number to string (system:index must be a string)
        idx_string = ee$Number(idx)$format('%03d')
        img$set(idx_name, idx_string)
      }))
  )
  return(ic_with_idx)
}



#' set_idx
#'
#' @param x tidyee or `ee$ImageCollection` class object
#' @param idx_name name for index to create (default = "tidyee_index")
#'
#' @return tidyee or `ee$ImageCollection` class object with new index containing sequential 0-based indexing
#' @export
#'
#' @examples \dontrun{
#' library(rgee)
#' library(tidyrgee)
#' ee_Initialize()
#
#' modis_link <- "MODIS/006/MOD13Q1"
#' modisIC <- ee$ImageCollection(modis_link)
#' modis_ndvi_tidy <- as_tidyee(modisIC) |>
#'   select("NDVI")
#' modis_ndvi_tidy |>
#   set_idx()
#'
#' }

set_idx <-  function(x, idx_name= "tidyee_index"){
  UseMethod("set_idx")
}
