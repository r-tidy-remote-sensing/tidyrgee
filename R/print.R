
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


