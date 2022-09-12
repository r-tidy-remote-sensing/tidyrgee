#' @export
inner_join.tidyee<- function(x, y, by,...){
  x_ic <- x$ee_ob
  y_ic <- y$ee_ob

  if(inherits(x_ic,"ee.image.Image")) {x_ic <- ee$ImageCollection(x_ic)}
  if(inherits(y_ic,"ee.image.Image")) {y_ic <- ee$ImageCollection(y_ic)}
  # Define an inner join
  innerJoin = rgee::ee$Join$inner()

  # Specify an equals filter for image timestamps.
  filterEq <- rgee::ee$Filter$equals(leftField = by, rightField = by)

  # Apply the join.
  inner_join_output = innerJoin$apply(x_ic, y_ic, filterEq)

  # Map a function to merge the results in the output FeatureCollection.
  # in the JavaScript code-editor this seems to auto-convert/get coerced to ImageCollection
  joined_fc = inner_join_output$map(function(feature)  {
    ee$Image$cat(feature$get('primary'), feature$get('secondary'))
  })

  # with rgee is seems necessary to explicitly convert
  ic_inner_joined <- rgee::ee$ImageCollection(joined_fc)
  joined_band_names <- unique(c(vrt_band_names(x),vrt_band_names(y)))
  # joined_band_names <- unique(c(attributes(x$vrt)$band_names,attributes(y$vrt)$band_names))
  # attributes(x$vrt)$band_names <-  joined_band_names
  vrt_joined <- x$vrt |>
    dplyr::mutate(band_names= list(joined_band_names))
  # return(ic_inner_joined)
  # return(ic_inner_joined)
  create_tidyee(ic_inner_joined,vrt_joined)
}

#' @export
inner_join.ee.imagecollection.ImageCollection<- function(x, y, by,...){
  x_ic <- x
  y_ic <- y

  # Define an inner join
  innerJoin = rgee::ee$Join$inner()

  # Specify an equals filter for image timestamps.
  filterEq <- rgee::ee$Filter$equals(leftField = by, rightField = by)

  # Apply the join.
  inner_join_output = innerJoin$apply(x_ic, y_ic, filterEq)

  # Map a function to merge the results in the output FeatureCollection.
  # in the JavaScript code-editor this seems to auto-convert/get coerced to ImageCollection
  joined_fc = inner_join_output$map(function(feature)  {
    ee$Image$cat(feature$get('primary'), feature$get('secondary'))
  })

  # with rgee is seems necessary to explicitly convert
  ic_inner_joined <- rgee::ee$ImageCollection(joined_fc)
  # joined_band_names <- unique(c(vrt_band_names(x),vrt_band_names(y)))
  # joined_band_names <- unique(c(attributes(x$vrt)$band_names,attributes(y$vrt)$band_names))
  # attributes(x$vrt)$band_names <-  joined_band_names
  # vrt_joined <- x$vrt |>
  #   dplyr::mutate(band_names= list(joined_band_names))
  # # return(ic_inner_joined)
  return(ic_inner_joined)
  # create_tidyee(ic_inner_joined,vrt_joined,tidyee_index = F)
}

#' inner_join bands from different image/ImageCollections based on shared property
#' @name inner_join
#' @param x,y A	 pair of tidyee objects containing ee$ImageCollections
#' @param by A character vector of variables to join by.
#' @return An object of the same type as `x`. The output has the following properties:
#' Same number of images as `x`
#' Total number of bands equal the number of bands in `x` plus the number of bands in `y`
#' @seealso \code{\link[dplyr]{inner_join}} for information about inner_join on normal data tables.
#' @export
#' @importFrom rgee ee
#' @importFrom dplyr inner_join
NULL
