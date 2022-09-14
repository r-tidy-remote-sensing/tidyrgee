#' as_tidy_ee
#'
#' @param x ee$Image or ee$ImageCollection
#' @param time_end \code{logical} include time_end ("system:time_end") in vrt (default=F)
#' @description The function returns a list containing the original object (Image/ImageCollection)as well
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

as_tidyee <-  function(x,time_end=FALSE){

  if(inherits(x, "ee.image.Image")){
    band_names <- x$bandNames()$getInfo()
    vrt_base <- rgee::ee_get_date_img(x,time_end = time_end) |>
      data.frame() |>
      dplyr::tibble()
  }
  if(inherits(x, "ee.imagecollection.ImageCollection")){
    band_names <- x$first()$bandNames()$getInfo()
    system_index_vec <-  x$aggregate_array("system:index")$getInfo()
    vrt_base<-  rgee::ee_get_date_ic(x,time_end = time_end) |>
      dplyr::arrange(.data$time_start) |>
      mutate(
        system_index = system_index_vec
      )
  }

  vrt<-  vrt_base |>
    dplyr::mutate(
      date = lubridate::as_date(.data$time_start),
      month=lubridate::month(date),
      year= lubridate::year(date),
      doy=lubridate::yday(date),
      band_names = list(band_names)
    ) |>
    dplyr::as_tibble()

  create_tidyee(x = x,vrt = vrt)
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
  # time_start_vec <- x$aggregate_array("system:time_start")$getInfo
  # vrt <- vrt |>
  #   # dplyr::arrange(time_start) |>
  #   dplyr::mutate(
  #     tidyee_index= sprintf(dplyr::row_number()-1,fmt = "%03d")
  #     # time_start= time_start_vec
  #   )

  ee_tidy_ob <- list(ee_ob=x,vrt=vrt)
  class(ee_tidy_ob)<-c("tidyee")
  return(ee_tidy_ob)

}



