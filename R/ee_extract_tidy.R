
#' @export
ee_extract_tidy.tidyee <-  function(x,
                               y,
                               stat="mean",
                               scale,
                               via="getInfo",
                               container="rgee_backup",
                               sf=TRUE,
                               lazy=FALSE,
                               quiet=FALSE,
                               rgee_issue_fixed=FALSE,
                               ...){

  if(rgee_issue_fixed){
    if( any(c("sfc","sf") %in% class(y))){
      assertthat::assert_that(
        geometry_type_is_unique(y),
        msg = "Currently we can only handle a single geometry types"
      )
      message("uploading sf to ee object\n")
      y_ee <- rgee::sf_as_ee(y)

    }
    if("ee.featurecollection.FeatureCollection" %in% class(y)){
      y_ee <- y
    }
  }
  if(!rgee_issue_fixed){
    y_ee <- y
  }

  message("renaming bands with dates\n")
  ic_renamed<- x$ee_ob |>
    add_date_to_bandname()

  ee_reducer <-  stat_to_reducer(fun = stat)



  message("starting ee_extract\n")
  ic_extracted_wide <- rgee::ee_extract(x = ic_renamed,
                                           y=y_ee,
                                           scale=scale,
                                           fun= ee_reducer,
                                           via = via,
                                           container= container,
                                           sf=sf,
                                           lazy=lazy,
                                           quiet=quiet)

  if("ee.image.Image" %in% class(x$ee_ob)){
    band_names_cli<- x$ee_ob$bandNames()$getInfo()
  }

  if("ee.imagecollection.ImageCollection" %in% class(x$ee_ob)){
    band_names_cli<- x$ee_ob$first()$bandNames()$getInfo()
  }

  # regex to be removed from name to create date col
  rm_rgx <- paste0(".*",band_names_cli)
  rm_rgx <- glue::glue_collapse(rm_rgx,sep = "|")

  # regex to extract parameter identifier
  # reorder so shorter names with common prefix to another band names wont replace string before longer version
  extract_rgx <- band_names_cli[stringr::str_order(band_names_cli,decreasing=T)]
  extract_rgx <- glue::glue_collapse(extract_rgx,sep = "|")

  names_pivot <- stringr::str_subset(colnames(ic_extracted_wide),pattern = extract_rgx)

  if(isTRUE(sf)){
    ic_extracted_wide <- ic_extracted_wide |>
      sf::st_drop_geometry()
  }
  ic_extracted_wide |>
    tidyr::pivot_longer(cols = dplyr::all_of(names_pivot),names_to = "name") |>
    mutate(
      parameter=stringr::str_extract(.data$name, pattern=extract_rgx),
      date= stringr::str_remove(string = .data$name, pattern = rm_rgx) |>
        stringr::str_replace_all("_","-") |> lubridate::ymd()

    ) |>
    dplyr::select(-.data$name)


}

# image collection version
#' @export
ee_extract_tidy.ee.imagecollection.ImageCollection <-  function(x,
                               y,
                               stat="mean",
                               scale,
                               via="getInfo",
                               container="rgee_backup",
                               sf=TRUE,
                               lazy=FALSE,
                               quiet=FALSE,
                               rgee_issue_fixed=FALSE,
                               ...){
  stopifnot(!is.null(x), inherits(x, "ee.imagecollection.ImageCollection"))

  if(rgee_issue_fixed){
    if( any(c("sfc","sf") %in% class(y))){
      assertthat::assert_that(
        geometry_type_is_unique(y),
        msg = "Currently we can only handle a single geometry types"
      )
      message("uploading sf to ee object\n")
      y_ee <- rgee::sf_as_ee(y)

    }
    if("ee.featurecollection.FeatureCollection" %in% class(y)){
      y_ee <- y
    }
  }
  if(!rgee_issue_fixed){
    y_ee <- y
  }

  message("renaming bands with dates\n")
  ic_renamed<- x |>
    add_date_to_bandname()

  ee_reducer <-  stat_to_reducer(fun = stat)



  message("starting ee_extract\n")
  ic_extracted_wide <- rgee::ee_extract(x = ic_renamed,
                                           y=y_ee,
                                           scale=scale,
                                           fun= ee_reducer,
                                           via = via,
                                           container= container,
                                           sf=sf,
                                           lazy=lazy,
                                           quiet=quiet)

  if("ee.imagecollection.ImageCollection" %in% class(x)){
    band_names_cli<- x$first()$bandNames()$getInfo()
  }

  # regex to be removed from name to create date col
  rm_rgx <- paste0(".*",band_names_cli)
  rm_rgx <- glue::glue_collapse(rm_rgx,sep = "|")

  # regex to extract parameter identifier
  # reorder so shorter names with common prefix to another band names wont replace string before longer version
  extract_rgx <- band_names_cli[stringr::str_order(band_names_cli,decreasing=T)]
  extract_rgx <- glue::glue_collapse(extract_rgx,sep = "|")

  names_pivot <- stringr::str_subset(colnames(ic_extracted_wide),pattern = extract_rgx)

  if(isTRUE(sf)){
    ic_extracted_wide <- ic_extracted_wide |>
      sf::st_drop_geometry()
  }
  ic_extracted_wide |>
    tidyr::pivot_longer(cols = dplyr::all_of(names_pivot),names_to = "name") |>
    mutate(
      parameter=stringr::str_extract(.data$name, pattern=extract_rgx),
      date= stringr::str_remove(string = .data$name, pattern = rm_rgx) |>
        stringr::str_replace_all("_","-") |> lubridate::ymd()

    ) |>
    dplyr::select(-.data$name)


}
# image version
#' @export
ee_extract_tidy.ee.image.Image <-  function(x,
                               y,
                               stat="mean",
                               scale,
                               via="getInfo",
                               container="rgee_backup",
                               sf=TRUE,
                               lazy=FALSE,
                               quiet=FALSE,
                               rgee_issue_fixed=FALSE,
                               ...){
  stopifnot(!is.null(x), inherits(x, "ee.image.Image"))

  if(rgee_issue_fixed){
    if( any(c("sfc","sf") %in% class(y))){
      assertthat::assert_that(
        geometry_type_is_unique(y),
        msg = "Currently we can only handle a single geometry types"
      )
      message("uploading sf to ee object\n")
      y_ee <- rgee::sf_as_ee(y)

    }
    if("ee.featurecollection.FeatureCollection" %in% class(y)){
      y_ee <- y
    }
  }
  if(!rgee_issue_fixed){
    y_ee <- y
  }

  message("renaming bands with dates\n")
  ic_renamed<- x |>
    add_date_to_bandname()

  ee_reducer <-  stat_to_reducer(fun = stat)



  message("starting ee_extract\n")
  ic_extracted_wide <- rgee::ee_extract(x = ic_renamed,
                                           y=y_ee,
                                           scale=scale,
                                           fun= ee_reducer,
                                           via = via,
                                           container= container,
                                           sf=sf,
                                           lazy=lazy,
                                           quiet=quiet)

  if("ee.image.Image" %in% class(x)){
    band_names_cli<- x$bandNames()$getInfo()
  }

  # regex to be removed from name to create date col
  rm_rgx <- paste0(".*",band_names_cli)
  rm_rgx <- glue::glue_collapse(rm_rgx,sep = "|")

  # regex to extract parameter identifier
  # reorder so shorter names with common prefix to another band names wont replace string before longer version
  extract_rgx <- band_names_cli[stringr::str_order(band_names_cli,decreasing=T)]
  extract_rgx <- glue::glue_collapse(extract_rgx,sep = "|")

  names_pivot <- stringr::str_subset(colnames(ic_extracted_wide),pattern = extract_rgx)

  if(isTRUE(sf)){
    ic_extracted_wide <- ic_extracted_wide |>
      sf::st_drop_geometry()
  }
  ic_extracted_wide |>
    tidyr::pivot_longer(cols = dplyr::all_of(names_pivot),names_to = "name") |>
    mutate(
      parameter=stringr::str_extract(.data$name, pattern=extract_rgx),
      date= stringr::str_remove(string = .data$name, pattern = rm_rgx) |>
        stringr::str_replace_all("_","-") |> lubridate::ymd()

    ) |>
    dplyr::select(-.data$name)


}



#' ee_extract_tidy
#' @name ee_extract_tidy
#' @rdname ee_extract_tidy
#' @param x tidyee, ee$Image, or ee$ImageCollection
#' @param y sf or ee$feature or ee$FeatureCollection
#' @param stat zonal stat ("mean", "median" , "min","max" etc)
#' @param scale A nominal scale in meters of the Image projection to work in. By default 1000.
#' @param via Character. Method to export the image. Three method are implemented: "getInfo", "drive", "gcs".
#' @param container Character. Name of the folder ('drive') or bucket ('gcs') to be exported into (ignore if via is not defined as "drive" or "gcs").
#' @param sf Logical. Should return an sf object?
#' @param lazy Logical. If TRUE, a future::sequential object is created to evaluate the task in the future. Ignore if via is set as "getInfo". See details.
#' @param quiet Logical. Suppress info message.
#' @param ... additional parameters
#'
#' @return data.frame in long format with point estimates for each time-step and y feature based on statistic provided
#'
#' @examples \dontrun{
#' library(rgee)
#' library(tidyrgee)
#' ee_Initizialize()
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' point_sample_buffered <- tidyrgee::bgd_msna |>
#'     sample_n(3) |>
#'     sf::st_as_sf(coords=c("_gps_reading_longitude",
#'                        "_gps_reading_latitude"), crs=4326) |>
#'     sf::st_transform(crs=32646) |>
#'     sf::st_buffer(dist = 500) |>
#'     dplyr::select(`_uuid`)
#' modis_ic_tidy <- as_tidyee(modis_ic)
#' modis_monthly_baseline_mean <- modis_ic_tidy |>
#'  select("NDVI") |>
#'  filter(year %in% 2000:2015) |>
#'   group_by(month) |>
#'  summarise(stat="mean")
#'
#' ndvi_monthly_mean_at_pt<- modis_monthly_baseline_mean |>
#'    ee_extract(y = point_sample_buffered,
#'             fun="mean",
#'             scale = 500)
#'}
#' @seealso \code{\link[rgee]{ee_extract}} for information about ee_extract on ee$ImageCollections and ee$Images
#' @export
#' @importFrom rgee ee_extract
#' @importFrom rlang .data
#'
#'
ee_extract_tidy <- function(x,
                       y,
                       stat="mean",
                       scale,
                       via="getInfo",
                       container="rgee_backup",
                       sf=TRUE,
                       lazy=FALSE,
                       quiet=FALSE,...){
  UseMethod("ee_extract_tidy")
}
