#' ungroup
#' @param x tidyee object
#'
#' @param ... ungroup args
#'
#' @export
ungroup <-  function(x, ...){
  UseMethod("ungroup")
}


#' @export
ungroup.tidyee <- function(x,...){
  vrt <- x$vrt |>
    dplyr::ungroup(...)
  create_tidyee(x$ee_ob,vrt)
}
