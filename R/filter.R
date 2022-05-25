
#' @export
filter.tidyee <- function(.data,...,filter_with="time_start"){
  vrt <- .data$vrt |>
    dplyr::filter(...)
  #this is literally just a "hotfix" i need to make a training work tomorrow
  # will delete this conditional fix after... filtering with index should be better
  # but i think it requires some work on the temporal composite functions
    if(filter_with=="time_start"){
  date_chr <-  vrt$date |>
    lubridate::as_date() |>
    as.character()
  ee_date_list = rgee::ee$List(date_chr)$
    map(rgee::ee_utils_pyfunc(
      function(date){
        rgee::ee$Date$millis(date)
      }
    )
    )
  ic_filt = .data$ee_ob$filter(ee$Filter$inList("system:time_start", ee_date_list))
  }
  else{

    ee_index_list <-  ee$List(vrt$system_index )
    ic_filt = .data$ee_ob$filter(ee$Filter$inList("system:index", ee_index_list))
  }




  # adding this assertion add 1-2 secs onto the process-- maybe should just be a test....
  # assertthat::assert_that(nrow(vrt)==ic_filt$size()$getInfo(),
  #                         msg = "mismatch in vrt and ee_ob - check function and objects" )

  return(create_tidyee(x=ic_filt,vrt=vrt))
}


#' @export
filter.ee.imagecollection.ImageCollection <- function(.data,...){
  stopifnot(!is.null(.data), inherits(.data, "ee.imagecollection.ImageCollection"))

  convert_to_tidyee_warning()

  x_tidy <- as_tidyee(.data)
  x_tidy |>
    filter(...) |>
    as_ee()

  }



#' filter ee$ImageCollections or tidyee objects that contain imageCollections
#' @name filter
#' @rdname filter
#' @param .data imageCollection or tidyee class object
#' @param ... other arguments
#' @return filtered image or imageCollection form filtered imageCollection
#' @examples \dontrun{
#'
#' library(rgee)
#' library(tidyrgee)
#' ee_Initialize()
#' l8 = ee$ImageCollection('LANDSAT/LC08/C01/T1_SR')
#' l8 |>
#'     filter(date>"2016-01-01",date<"2016-03-04")
#'
#'
#'  # example with tidyee ckass
#
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' modis_ic_tidy <- as_tidyee(modis_ic)
#'
#' # filter by month
#' modis_march_april <- modis_ic_tidy |>
#' filter(month %in% c(3,4))
#' }
#' @seealso \code{\link[dplyr]{filter}} for information about filter on normal data tables.
#' @importFrom dplyr filter
#' @export

NULL


