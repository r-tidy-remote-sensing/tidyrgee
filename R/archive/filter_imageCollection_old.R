
#' @export
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
    # cat(crayon::green(glue::glue("filtering imageCollection from {gt_date} to {lt_date}")),"\m")



    # x$filterDate(ee$Date$fromYMD(gt_date),ee$Date$fromYMD(lt_date))
    x$filterDate(as.character(gt_date),as.character(lt_date))
  }

  # gotta figure these out
  #
  # if(ftype=="month"){
  #   ee_month_filter
  # }
  # if(ftype=="year"){
  #   ee_year_filter
  # }


}
