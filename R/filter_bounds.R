
#' filter_bounds a wrapper for rgee::ee$ImageCollection$filterBounds
#'
#' @param x tidyee object containing ee$ImageCollection or ee$ImageCollection
#' @param y feature to filter bounds by (sf, ee$FeatureCollection, ee$Feature, ee$Geometry)
#' @param use_tidyee_index filter on tidyee_index (default = F) or system_index (by default)
#' @param return_tidyee \code{logical} return tidyee class (default = TRUE) object or ee$ImageCollection. Faster performance if set to FALSE
#'
#' @return tidyee class or ee$ImageCollection class object with scenes filtered to bounding box of y geometry
#' @importFrom rlang .data
#' @export
#'
#' @examples \dontrun{
#'
#' library(tidyrgee)
#' library(tidyverse)
#' library(rgee)
#' rgee::ee_Initialize()
#'
#' # create geometry and convert to sf
#' coord_tibble <- tibble::tribble(
#'   ~X,               ~Y,
#'   92.2303683692011, 20.9126490153521,
#'   92.2311567217866, 20.9127410439304,
#'   92.2287527311594, 20.9124072954926,
#'   92.2289221219251, 20.9197352745068,
#'   92.238724724534, 20.9081803233546
#' )
#' sf_ob <- sf::st_as_sf(coord_tibble, coords=c("X","Y"),crs=4326)
#'
#' # load landsat
#' ls = ee$ImageCollection("LANDSAT/LC08/C01/T1_SR")
#'
#' #create tidyee class
#' ls_tidy <-  as_tidyee(ls)
#'
#' # filter_bounds on sf object
#' # return tidyee object
#' ls_tidy |>
#'   filter_bounds(sf_ob)
#' # return ee$ImageCollection
#' ls_tidy |>
#'   filter_bounds(sf_ob,return_tidyee = FALSE)
#'
#' # filter_bounds on ee$Geometry object
#' # return tidyee object
#' ee_geom_ob <- sf_ob |> rgee::ee_as_sf()
#' ls_tidy |>
#'   filter_bounds(ee_geom_ob)
#'
#'
#' }

filter_bounds <- function(x,y,use_tidyee_index=FALSE,return_tidyee=TRUE){
  UseMethod('filter_bounds')
}




#' @export
filter_bounds.tidyee <-  function(x,y,use_tidyee_index=FALSE,return_tidyee=TRUE){
  assertthat::assert_that(rlang::inherits_any(y, c("sf","ee.geometry.Geometry",
                                                   "ee.featurecollection.FeatureCollection",
                                                   "ee.feature.Feature")))
  assertthat::assert_that(inherits(x, c("tidyee")))

  if(inherits(y,"sf")){
    y <- sf::st_bbox(y) |>
      sf::st_as_sfc()
    y_ee <- rgee::sf_as_ee(y)
    class(y_ee)
  }
  if(rlang::inherits_any(y,c("ee.geometry.Geometry",
                             "ee.featurecollection.FeatureCollection",
                             "ee.feature.Feature"))){
    y_ee <- y
  }

  if(!return_tidyee){
    x_ic <-  x$ee_ob
    return(x_ic$filterBounds(y_ee))
  }

  # not sure this is necessary  - would like to remove soon.
  if(use_tidyee_index){
  x <- x |> set_idx()
  x_ee_spatial_filtered<- x$ee_ob$filterBounds(y_ee)
  x_ee_spatial_filtered_idx<- x_ee_spatial_filtered$aggregate_array("tidyee_index")$getInfo()
  vrt_spatial_filtered <- x$vrt |>
    filter(.data$tidyee_index %in%x_ee_spatial_filtered_idx )
  create_tidyee(x = x_ee_spatial_filtered,vrt = vrt_spatial_filtered)
  }
  if(!use_tidyee_index)
  x_ee_spatial_filtered<- x$ee_ob$filterBounds(y_ee)
  x_ee_spatial_filtered_idx <- x_ee_spatial_filtered$aggregate_array("system:index")$getInfo()
  vrt_spatial_filtered <- x$vrt |>
      filter(.data$system_index %in% x_ee_spatial_filtered_idx )
  create_tidyee(x = x_ee_spatial_filtered,vrt = vrt_spatial_filtered)
  }


#' @export
filter_bounds.ee.imagecollection.ImageCollection <-  function(x,y,use_tidyee_index=FALSE,return_tidyee=TRUE){

  assertthat::assert_that(rlang::inherits_any(y, c("sf","ee.geometry.Geometry",
                                                   "ee.featurecollection.FeatureCollection",
                                                   "ee.feature.Feature")))

  assertthat::assert_that(inherits(x, c("ee.imagecollection.ImageCollection")))

  if(inherits(y,"sf")){
    y <- sf::st_bbox(y) |>
      sf::st_as_sfc()
    y_ee <- rgee::sf_as_ee(y)
  }
  if(rlang::inherits_any(y,c("ee.geometry.Geometry",
                             "ee.featurecollection.FeatureCollection",
                             "ee.feature.Feature"))){
    y_ee <- y
  }
  x_ee <-  x$ee_ob
  x_ee_spatial_filtered <- x_ee$filterBounds(y_ee)
  if(!return_tidyee){
    res <- x_ee_spatial_filtered
  }
  if(return_tidyee){
    res <- as_tidyee(x_ee_spatial_filtered)
  }
  return(res)
}
