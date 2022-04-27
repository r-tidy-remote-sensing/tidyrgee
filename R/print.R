
#' print tidyee
#'
#' @param x tidyee object
#'
#' @return printed tidyee object
#' @export

print <-  function(x){
  UseMethod("print")
}

#' @export
print.tidyee <-  function(x){
  cat(crayon::green("band names: [",glue::glue_collapse(attributes(x$vrt)$band_names,sep = ", "),"]","\n\n"))
  print(head(x$vrt))
}
