
#' @export
ungroup.tidyee <- function(x,...){
  vrt <- x$vrt |>
    dplyr::ungroup(...)
  create_tidyee(x$ee_ob,vrt)
}
#' ungroup
#' @name ungroup
#' @rdname ungroup
#' @param x tidyee object
#' @param ... ungroup args
#' @return tidyee class object with vrt ungrouped.
#' @seealso \code{\link[dplyr]{ungroup}} for information about ungroup on normal data tables.
#' @export
#' @importFrom dplyr ungroup
NULL
