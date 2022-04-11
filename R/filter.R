filter <- function(x, ...){

  UseMethod('filter')

}

#' @name filter
#' @param x A imageCollection
#' @param ... filterCollection
#' @export
#'
#'


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
    cat(crayon::green(glue::glue("filtering imageCollection from {gt_date} to {lt_date}")))


    x$filterDate(date_range)}

  # gotta figure these out
  #
  # if(ftype=="month"){
  #   ee_month_filter
  # }
  # if(ftype=="year"){
  #   ee_year_filter
  # }

}


extract_condition <- function(expr_split){
  assertthat::assert_that(length(expr_split) %in% c(3,4),msg = "something wrong with conditional logic")
  if(length(expr_split)==3){
    cond <-  expr_split[2]
  }
  if(length(expr_split)==4){
    cond <- paste0(expr_split[2],expr_split[3])
  }
  return(cond)


}
extract_date <- function(expr_split){
  assertthat::assert_that(length(expr_split) %in% c(3,4),msg = "something wrong with conditional logic")
  if(length(expr_split)==3){
    date_component <-  expr_split[3]
  }
  if(length(expr_split)==4){
    date_component <- expr_split[4]
  }
  date_component_fmt <- stringr::str_remove_all(cs1[[4]],"\\\"") |> readr::parse_date()
  cond <- extract_condition(expr_split)
  if(cond==">"){
    date_component_adjusted <- lubridate::ymd(date_component_fmt)+1
  }
  if(cond=="<"){
    date_component_adjusted <- lubridate::ymd(date_component_fmt)-1
  }
  else{
    date_component_adjusted <-  lubridate::ymd(date_component_fmt)
  }
}


filter_type<- function(x){
  ymd_boolean<- stringr::str_detect(string = x, pattern = "date")
  month_boolean <- stringr::str_detect(string = x, pattern = "month")
  year_boolean <- stringr::str_detect(string = x, pattern = "year")
  if(any(ymd_boolean)){
    assertthat::assert_that(length(ymd_boolean)==2 & all(ymd_boolean==T),
                            msg = "if date (YMD) is being used there should be 2 dates supplied")
  }
  if(any(month_boolean)){
    assertthat::assert_that(all(month_boolean==T),
                            msg = "if filtering by month...")
  }

  filter_index <-  c(all(ymd_boolean),all(month_boolean),all(year_boolean))
  filter_type <-  c("ymd","month","year")
  filter_type[filter_index]
}




