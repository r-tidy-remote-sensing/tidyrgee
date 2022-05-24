#' @export
mutate.tidyee <- function(.data,
                          ...,
                          .keep = c("all", "used", "unused", "none"),
                          .before = NULL,
                          .after = NULL
                          ){
  vrt <- .data$vrt |>
    dplyr::mutate(...,.keep,.before,.after)
  create_tidyee(.data$ee_ob,vrt)
}


#' @export
mutate.ee.imagecollection.ImageCollection <- function(.data,...){
  stopifnot(!is.null(.data), inherits(.data, "ee.imagecollection.ImageCollection"))
  convert_to_tidyee_warning()
  x_tidy <- as_tidyee(.data)
  x_tidy |>
    mutate(...,.keep,.before,.after)
}

#' mutate columns into tidyee vrt which can later be used to modify tidyee ImageCollection
#' @name mutate
#' @rdname mutate
#' @param .data tidyee class object (list of ee_ob, vrt)
#' @param ... mutate arguments
#' @param .keep `r lifecycle::badge("experimental")`
#'   Control which columns from `.data` are retained in the output. Grouping
#'   columns and columns created by `...` are always kept.
#'
#'   * `"all"` retains all columns from `.data`. This is the default.
#'   * `"used"` retains only the columns used in `...` to create new
#'     columns. This is useful for checking your work, as it displays inputs
#'     and outputs side-by-side.
#'   * `"unused"` retains only the columns _not_ used in `...` to create new
#'     columns. This is useful if you generate new columns, but no longer need
#'     the columns used to generate them.
#'   * `"none"` doesn't retain any extra columns from `.data`. Only the grouping
#'     variables and columns created by `...` are kept.
#' @param .before,.after `r lifecycle::badge("experimental")`
#'   <[`tidy-select`][dplyr_tidy_select]> Optionally, control where new columns
#'   should appear (the default is to add to the right hand side). See
#'   [relocate()] for more details.

#' @examples \dontrun{
#'library(tidyrgee)
#' library(rgee)
#' ee_Initialize()
#' modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
#' modis_ic_tidy <- as_tidyee(modis_ic)
#'}

#' @seealso \code{\link[dplyr]{mutate}} for information about mutate on normal data tables.
#' @export
#' @importFrom dplyr mutate
NULL
