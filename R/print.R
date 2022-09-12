
#' print tidyee
#'
#' @param x tidyee object
#' @param ... additional arguments
#' @return printed tidyee object
#' @export

# print <-  function(x){
#   UseMethod("print")
# }


print.tidyee <-  function(x,...){
  band_names <- vrt_band_names(x)
  cat(crayon::green("band names: [",glue::glue_collapse(band_names,sep = ", "),"]","\n\n"))
   NextMethod()
}


# print.tidyee <-  function(x){
#   cat(crayon::green("band names: [",glue::glue_collapse(attributes(x$vrt)$band_names,sep = ", "),"]","\n\n"))
#   if(inherits(x$vrt,"tbl_df")){
#   NextMethod()
#   }else{
#     printme <-  x$vrt[1:10,]
#     print.data.frame(printme)
#     }
#   invisible(x$vrt)
# }


