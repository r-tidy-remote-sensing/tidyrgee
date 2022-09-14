
#' bind ImageCollections
#'
#' @param x list of tidyee objects
#' @return tidyee object containing single image collection and vrt
#' @export
#'
#' @examples \dontrun{
#' library(tidyrgee)
#' library(rgee)
#' ee_Initialize()
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' modis_ic_tidy <- as_tidyee(modis_ic)
#' modis_tidy_list <- modis_tidy |>
#' group_split(month)
#' modis_tidy_list |>
#'   bind_ics()
#' }
#'

bind_ics <- function(x){
  ic_only <- x |>
    purrr::map(~.x$ee_ob)
  vrt_only <- x |>
    purrr::map(~.x$vrt)

  vrt_together<- dplyr::bind_rows(vrt_only)
  ic_container = ee$ImageCollection(list())

  for(i in 1:length(ic_only)){
    ic_container=ic_container$merge(ic_only[[i]])

  }


  create_tidyee(x = ic_container$sort(prop = "system:time_start"),vrt = vrt_together )


  }



