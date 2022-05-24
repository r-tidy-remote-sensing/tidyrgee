
#' @export
group_split.ee.imagecollection.ImageCollection <-  function(.tbl,...){
  stopifnot(!is.null(.tbl), inherits(.tbl, "ee.imagecollection.ImageCollection"))
  convert_to_tidyee_warning()

  x_tidy <-  as_tidyee(.tbl)
  x_tidy |>
    group_split(...)
}



#' @export
group_split.tidyee <-  function(.tbl,...){
  vrt_list <- .tbl$vrt |>
    group_split(...,.keep=TRUE)# unfortunately drop attributes
  # is there a way to figure this out with `vctrs` package?
  # fixed by moving band_naems to list-col instead of relying on attributes
  # for print method

  # date_list <-  vrt_list |>
  #   purrr::map(
  #     ~.x$date |>
  #       lubridate::as_date() |>
  #       as.character()
  #   )
  index_list <- vrt_list |>
    purrr::map(
      ~.x$system_index
    )

  ee_index_list = purrr::map(index_list,
                             ~rgee::ee$List(.x)
    )


  ic_filt_list<-purrr::map(ee_index_list,~ .tbl$ee_ob$filter(ee$Filter$inList("system:index", .x)))

  purrr::map2(.x = ic_filt_list,.y = vrt_list,.f = ~create_tidyee(.x,.y))


}


#' filter ee$ImageCollections or tidyee objects that contain imageCollections
#' @name group_split
#' @rdname group_split
#' @param .tbl imageCollection or tidyee class object
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
#' @seealso \code{\link[dplyr]{group_split}} for information about filter on normal data tables.
#' @importFrom dplyr group_split
#' @export

NULL

