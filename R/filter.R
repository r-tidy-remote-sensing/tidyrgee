

#' @export
filter.tidyee <-  function(.data,...){
  .data <- .data |> set_idx()
  vrt <- .data$vrt |>
    dplyr::filter(...)

  assertthat::assert_that(nrow(vrt)>0,msg="filter out of range")

  if(length(vrt$tidyee_index)>1){
    ee_index_list <-  ee$List(vrt$tidyee_index |> as.character())
    ic_filt = .data$ee_ob$filter(ee$Filter$inList("tidyee_index", ee_index_list))
  }
  if(length(vrt$tidyee_index)==1){
    ee_index <-  rgee::ee$String(vrt$tidyee_index |> as.character())
    ic_filt = .data$ee_ob$filter(ee$Filter$eq('tidyee_index', ee_index))
    ic_filt <- rgee::ee$Image(ic_filt$first())
  }

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
#' @param .data ImageCollection or tidyee class object
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





