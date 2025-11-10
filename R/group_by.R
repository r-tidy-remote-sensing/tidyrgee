

#' @export
group_by.ee.imagecollection.ImageCollection <- function(.data,
                                                        ...,
                                                        .add=FALSE,
                                                        .drop=dplyr::group_by_drop_default(.data)){
  stopifnot(!is.null(.data), inherits(.data, "ee.imagecollection.ImageCollection"))
  convert_to_tidyee_warning()
  x_tidy <- as_tidyee(.data)
  x_tidy |>
    group_by(...)
}


#' @export
group_by.tidyee <- function(.data,...,.add=FALSE,.drop=dplyr::group_by_drop_default(.data)){
  vrt <- .data$vrt |>
    dplyr::group_by(...)
  create_tidyee(.data$ee_ob,vrt)
}



#' Group an imageCollection or tidyee object with Imagecollections by a parameter
#' @name group_by
#' @rdname group_by
#' @param .data ee$ImageCollection or tidyee object
#' @param ... group_by variables
#' @param .add When `FALSE`, the default, `group_by()` will
#'   override existing groups. To add to the existing groups, use
#'   `.add = TRUE`.
#'
#'   This argument was previously called `add`, but that prevented
#'   creating a new grouping variable called `add`, and conflicts with
#'   our naming conventions.
#' @param .drop Drop groups formed by factor levels that don't appear in the
#'   data? The default is `TRUE` except when `.data` has been previously
#'   grouped with `.drop = FALSE`. See [dplyr::group_by_drop_default()] for details.
#' @return ee$ImageCollection with grouped_vars attribute
#' @examples \dontrun{
#' library(tidyrgee)
#' ee_Initialize()
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' modis_ic |>
#'    filter(date>="2016-01-01",date<="2019-12-31") |>
#'    group_by(year)
#' }
#' @seealso \code{\link[dplyr]{group_by}} for information about group_by on normal data tables.
#' @importFrom dplyr group_by
#' @export
NULL
