

#' add_date_to_band_name
#' @description append date to band name
#' @param x ee$ImageCollection or ee$Image
#' @return a date to band name in x.
#' @export

add_date_to_bandname <- function(x) {
  UseMethod('add_date_to_bandname')
}


#' @export
add_date_to_bandname.ee.imagecollection.ImageCollection <- function(x){
  x |>
    ee$ImageCollection$map(
      function(img){
        # can't use getInfo() in sever-side function
        bnames<- img$bandNames()
        date <- ee$Date(img$get("system:time_start"))$format('YYYY_MM_dd')

        # since bnames is technically a list rather than a simple string I need to map over it
        # this should make it flexible fore when there are more bands I want to rename anyways
        bnames_date <- bnames$map(
          rgee::ee_utils_pyfunc(function(x){
            ee$String(x)$cat(ee$String("_"))$cat(date)

          })
        )
        img$select(bnames)$rename(bnames_date)
      }

    )

}

#' @export
add_date_to_bandname.ee.image.Image <- function(x){
  bnames<- x$bandNames()
  date <- ee$Date(x$get("system:time_start"))$format('YYYY_MM_dd')
  bnames_date <- bnames$map(
    rgee::ee_utils_pyfunc(function(x){
      ee$String(x)$cat(ee$String("_"))$cat(date)

    })
  )
  x$
    select(bnames)$
    rename(bnames_date)

}

