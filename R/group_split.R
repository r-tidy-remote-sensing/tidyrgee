
#' @export
group_split.ee.imagecollection.ImageCollection <-  function(.tbl,...){
  stopifnot(!is.null(.tbl), inherits(.tbl, "ee.imagecollection.ImageCollection"))
  convert_to_tidyee_warning()

  x_tidy <-  as_tidyee(.tbl)
  x_tidy |>
    group_split(...)
}



#' @export
group_split.tidyee <-  function(.tbl,...,return_tidyee=T){
  tidyee_ob <- .tbl |>
    set_idx()
  vrt_list <- tidyee_ob$vrt |>
    dplyr::group_split(...,.keep=TRUE)# unfortunately drop attributes
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
      ~.x$tidyee_index
    )


  ee_index_list=purrr::map(index_list,
                           function(x){ if(length(x)==1){
                             out_list_component <-  ee$String(as.character(x))
                           }else{
                             out_list_component <- rgee::ee$List(as.character(x))
                           }
                             return(out_list_component)
                           }
  )


  ic_filt_list<-purrr::map(ee_index_list,~ tidyee_ob$ee_ob$filter(rgee::ee$Filter$inList("tidyee_index", .x)))

  if(return_tidyee){
    return(purrr::map2(.x = ic_filt_list,.y = vrt_list,.f = ~create_tidyee(.x,.y)))
  }
  if(!return_tidyee){
    return(ic_filt_list)
  }


}



#' filter ee$ImageCollections or tidyee objects that contain imageCollections
#' @name group_split
#' @rdname group_split
#' @param .tbl ImageCollection or tidyee class object
#' @param ... other arguments
#' @param return_tidyee \code{logical} return tidyee object(default =T), if FALSE - only return ee$ImageCollection
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

