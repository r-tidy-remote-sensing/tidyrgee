
#' @export
filter.tidyee <- function(x,...){
  vrt <- x$vrt |>
    dplyr::filter(...)
  date_chr <-  vrt$date |>
    lubridate::as_date() |>
    as.character()

  add_date_meta_to_ic = function(x) {
    return(x$set('Date', ee$Date(x$get('system:time_start'))$format("YYYY-MM-dd")))}

  new_collection <- x$ee_ob$map(rgee::ee_utils_pyfunc(add_date_meta_to_ic))

  ic_filt = new_collection$filter(ee$Filter$inList("Date", date_chr))

  # adding this assertion add 1-2 secs onto the process-- maybe should just be a test....
  # assertthat::assert_that(nrow(vrt)==ic_filt$size()$getInfo(),
  #                         msg = "mismatch in vrt and ee_ob - check function and objects" )

  return(create_tidyee(x=ic_filt,vrt=vrt))
}


#' @export
filter.ee.imagecollection.ImageCollection <- function(x,...){
  stopifnot(!is.null(x), inherits(x, "ee.imagecollection.ImageCollection"))
  quo_list <- rlang::quos(...)
  quo_chr <- as.character(quo_list) |> purrr::map_chr(~trimws(.x))

  ftype <- filter_type(quo_chr)
  if(ftype=="ymd"){
    date_gt <- stringr::str_subset(stringr::str_remove(quo_chr,"~"),"^date+.>")
    date_lt <- stringr::str_subset(stringr::str_remove(quo_chr,"~"),"^date+.<")
    #split at condition ">",">=", etc
    gt_cond_split <- unlist(strsplit(date_gt, "(?=[><=)])", perl = TRUE))
    lt_cond_split <- unlist(strsplit(date_lt, "(?=[><=)])", perl = TRUE))
    # extract specific conditon
    lt_cond <- extract_condition(lt_cond_split)
    gt_cond <- extract_condition(gt_cond_split)

    # etract date and modify if necessary (i.e if ">" need to +1 to start date)
    lt_date <- extract_date(lt_cond_split)
    gt_date <- extract_date(gt_cond_split)

    date_range <-  c(gt_date,lt_date)
    # cat(crayon::green(glue::glue("filtering imageCollection from {gt_date} to {lt_date}")),"\m")



    # x$filterDate(ee$Date$fromYMD(gt_date),ee$Date$fromYMD(lt_date))
    x$filterDate(as.character(gt_date),as.character(lt_date))
  }

  # gotta figure these out
  #
  # if(ftype=="month"){
  #   ee_month_filter
  # }
  # if(ftype=="year"){
  #   ee_year_filter
  # }


}

#' filter ee$ImageCollections or tidyee objects that contain imageCollections
#' @name filter
#' @rdname filter
#' @param x imageCollection or tidyee class object
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


