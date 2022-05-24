#' as_tidy_ee
#'
#' @param x ee$Image or ee$ImageCollection
#' @description The function returns a list containing the original object (image/imageCollection)as well
#' as a "virtual data.frame (vrt)" which is a data.frame holding key properties of the
#' ee$Image/ee$ImageCollection. The returned list has been assigned a new class "tidyee".
#' @return tidyee class object which contains a list with two components ("x","vrt")
#' @importFrom rlang .data
#' @export
#'
#' @examples \dontrun{
#' library(tidyrgee)
#' library(rgee)
#' ee_Initialize()
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' modis_ic_tidy <- as_tidyee(modis_ic)
#'
#'
#' }

as_tidyee <-  function(x){
  # id_vec <- x$aggregate_array("system:id")$getInfo()
  system_index_vec <-  x$aggregate_array("system:index")$getInfo()
  vrt<-  rgee::ee_get_date_ic(x) |>
    dplyr::mutate(
      date = .data$time_start,
      month=lubridate::month(date),
      year= lubridate::year(date),
      idx= dplyr::row_number()-1,
      # system_id=id_vec,
      system_index = system_index_vec
    )
  band_names <- x$first()$bandNames()$getInfo()
  vrt <- vrt |>
    mutate(
      band_names = list(band_names)
    ) |>
    dplyr::as_tibble()


  tidyrgee:::create_tidyee(x = x,vrt = vrt)

}



#' create_tidyee
#'
#' @param x ee$ImageCollection
#' @param vrt virtual table
#' @description helper function to assign new tidyee when running `as_tidyee`
#'
#' @return tidyee class list object
#' @export

create_tidyee <- function(x,vrt){
  ee_tidy_ob <- list(ee_ob=x,vrt=vrt)
  class(ee_tidy_ob)<-c("tidyee")
  return(ee_tidy_ob)

}

