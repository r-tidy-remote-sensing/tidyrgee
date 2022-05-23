group_by.ee.imagecollection.ImageCollection <- function(x,...){

  new_groups <- rlang::enquos(..., .ignore_empty = "all")

  class(x) <- c("grouped_imageCol", class(x))
  new_groups_list <- new_groups |> purrr::map(~rlang::quo_get_expr(.x))
  new_groups_chr <- as.character(unlist(new_groups_list))

  assertthat::assert_that(new_groups_chr %in% c("year","month") ,
                          msg = "so far can only group by year, month, or both")
  cat(glue::glue("returning imageCol grouped by {new_groups_chr}\n"))
  attr(x,"grouped_vars") <- new_groups_chr
  return(x)

}

