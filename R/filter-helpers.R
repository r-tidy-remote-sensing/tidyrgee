
#' extract_condition
#'
#' @param expr_split an expr_split object
#' @noRd
#' @return a condition
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
#' extract_date
#'
#' @param expr_split an expr_split object
#' @noRd
#' @return a condition
extract_date <- function(expr_split){
  assertthat::assert_that(length(expr_split) %in% c(3,4),msg = "something wrong with conditional logic")
  if(length(expr_split)==3){
    date_component <-  expr_split[3]
  }
  if(length(expr_split)==4){
    date_component <- expr_split[4]
  }
  date_component_fmt <- stringr::str_remove_all(date_component,"\\\"") |> readr::parse_date()
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
  return(date_component_adjusted)
}

#' extract_condition
#'
#' @param x a character string
#' @noRd
#' @return a conditiont to filter on
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


