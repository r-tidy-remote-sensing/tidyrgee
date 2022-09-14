#' clip flexible wrapper for rgee::ee$Image$clip()
#' @description allows clipping of tidyee,ee$Imagecollection, or ee$Image classes. Also allows objects to be clipped to sf object in addition to ee$FeatureCollections/ee$Feature
#' @param x object to be clipped (tidyee, ee$ImageCollection, ee$Image)
#' @param y geometry object to clip to (sf, ee$Feature,ee$FeatureCollections)
#' @param return_tidyee \code{logical} return tidyee class (default = TRUE) object or ee$ImageCollection. Faster performance if F
#'
#' @return x as tidyee or ee$Image/ee$ImageCollection depending on `return_tidyee` argument.
#' @export
#'
#' @examples \dontrun{

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
#' roi <- ee$Geometry$Polygon(list(
#'   c(-114.275, 45.891),
#'   c(-108.275, 45.868),
#'   c(-108.240, 48.868),
#'   c(-114.240, 48.891)
#' ))
#'
#' # load landsat
#' ls = ee$ImageCollection("LANDSAT/LC08/C01/T1_SR")
#'
#' # create tidyee class
#' ls_tidy <-  as_tidyee(ls)
#'
#' #  filter_bounds on sf object
#' #  return tidyee object
#' ls_tidy |>
#'   filter_bounds(y = roi,return_tidyee = FALSE) |>
#'   clip(roi,return_tidyee = FALSE)
#'
#' # pretty instant with return_tidyee=FALSE
#' ls_clipped_roi_ic <- ls_tidy |>
#'   filter_bounds(y = roi,return_tidyee = FALSE) |>
#'   clip(roi,return_tidyee = FALSE)
#'
#' # takes more time with return_tidyee=T, but you get the vrt
#' ls_clipped__roi_tidyee <- ls_tidy |>
#'   filter_bounds(y = roi,return_tidyee = FALSE) |>
#'   clip(roi,return_tidyee = TRUE)
#'
#' # demonstrating on sf object
#' ls_clipped_sf_ob_ic <- ls_tidy |>
#'   filter_bounds(y = sf_ob,return_tidyee = FALSE) |>
#'   clip(roi,return_tidyee = FALSE)
#'
#' ls_clipped_sf_ob_tidyee <- ls_tidy |>
#'   filter_bounds(y = roi,return_tidyee = FALSE) |>
#'   clip(roi,return_tidyee = TRUE)
#' }

clip<-  function(x,y, return_tidyee=TRUE){
  UseMethod("clip")
}





#' @export
clip.tidyee <-  function(x,y,return_tidyee=TRUE){
  assertthat::assert_that(rlang::inherits_any(y, c("sf","ee.geometry.Geometry",
                                                   "ee.featurecollection.FeatureCollection",
                                                   "ee.feature.Feature")))
  assertthat::assert_that(inherits(x, c("tidyee")))

  if(inherits(y,"sf")){
    y_ee <- rgee::sf_as_ee(y)
  }
  if(rlang::inherits_any(y,c("ee.geometry.Geometry",
                             "ee.featurecollection.FeatureCollection",
                             "ee.feature.Feature"))){
    y_ee <- y
  }
  if(inherits(x$ee_ob,"ee.imagecollection.ImageCollection")){
    x_clipped <- x$ee_ob$map(
      function(img){
        img$clip(y_ee)
      }
    )
  }
  if(inherits(x$ee_ob,"ee.image.Image")){
    x_clipped <- x$ee_ob$clip(y_ee)
  }


  if(!return_tidyee){
    res <-  x_clipped
  }
  if(return_tidyee){
    res <-  as_tidyee(x_clipped)
  }
  return(res)
}

#' @export
clip.ee.image.Image <-  function(x,y,return_tidyee=TRUE){
  assertthat::assert_that(rlang::inherits_any(y, c("sf","ee.geometry.Geometry",
                                                   "ee.featurecollection.FeatureCollection",
                                                   "ee.feature.Feature")))
  assertthat::assert_that(inherits(x, c("ee.image.Image")))

  if(inherits(y,"sf")){
    y_ee <- rgee::sf_as_ee(y)
  }
  if(rlang::inherits_any(y,c("ee.geometry.Geometry",
                             "ee.featurecollection.FeatureCollection",
                             "ee.feature.Feature"))){
    y_ee <- y
  }
  x_clipped <- x$clip(y_ee)
  if(!return_tidyee){
    res <-  x_clipped
  }
  if(return_tidyee){
    res <-  as_tidyee(x_clipped)
  }
  return(res)
}

#' @export
clip.ee.imagecollection.ImageCollection <-  function(x,y,return_tidyee=TRUE){
  assertthat::assert_that(rlang::inherits_any(y, c("sf","ee.geometry.Geometry",
                                                   "ee.featurecollection.FeatureCollection",
                                                   "ee.feature.Feature")))
  assertthat::assert_that(inherits(x, c("ee.imagecollection.ImageCollection")))

  if(inherits(y,"sf")){
    y_ee <- rgee::sf_as_ee(y)
  }
  if(rlang::inherits_any(y,c("ee.geometry.Geometry",
                             "ee.featurecollection.FeatureCollection",
                             "ee.feature.Feature"))){
    y_ee <- y
  }
  x_clipped <- x$map(
    function(img){
      img$clip(y_ee)
    }
  )
  if(!return_tidyee){
    res <-  x_clipped
  }
  if(return_tidyee){
    res <-  as_tidyee(x_clipped)
  }
  return(res)
}

