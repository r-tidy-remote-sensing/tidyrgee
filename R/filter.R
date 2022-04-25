
#' @param x A imageCollection
#' @param ... filterCollection
#' @export

filter <- function(x, ...) {
  UseMethod("filter")
}


#' @name filter
#' @export


filter.ee.imagecollection.ImageCollection <- function(x,...){

  stopifnot(!is.null(x), inherits(x, "ee.imagecollection.ImageCollection"))

  quo_list <- rlang::quos(...)

  quo_chr <- purrr::map(quo_list, ~rlang::quo_get_expr(.))

  conditions <- symbol_func(quo_chr)

  arguments <- arg_func(quo_chr)

  user_call <- vector_func(quo_chr)

  filter_setup <- tidyr::tibble(conditions,
                         arguments,
                         user_call) %>%
                  dplyr::mutate(rowid = dplyr::row_number()) %>%
                  dplyr::group_by(arg) %>%
                  dplyr::add_count() %>%
                  dplyr::ungroup()

  if(any(filter_setup$arg %in% c('year', 'date'))){
  filter_years_first <- filter_setup %>%
                  dplyr::filter(arg %in% c('year', 'date')) %>%
                  split(.$rowid) %>%
                  purrr::map(~filter_ic(x,info = .))

  final_filter <- final_merge(filter_years_first)

  }

  if(any(filter_setup$arg %in% 'month')){

  if(any(filter_setup$arg %in% c('year', 'date'))){x = final_filter}
  final_filter <- filter_setup %>%
                   dplyr::filter(arg == 'month') %>%
                   split(.$rowid) %>%
                   purrr::map(~filter_ic(x, info = .))
  final_filter <- final_merge(final_filter)
  }


  #need to filter out use cases where images are not distinct
  filter_distinct <- final_filter_distinct(final_filter)


  filter_distinct

}


#' @title Filter ImageCollection
#' @description This filters the ImageCollection based on the args passed from the user
#' @param setup_list A list with params.

filter_ic <- function(x,info){

      switch(info$arg,

      'date' = {

      do.call(date_filter, list(x, info))

      },

      'month' = {

        do.call(month_filter, list(x, info))

      },

      'year' = {

      do.call(year_filter, list(x, info))

      })

    }

date_filter <- function(x,info){

  ic_list <- list()

  for(i in info$user_call[[1]]){
    if(info$cnd == '<'){

      setup_list <- x$filterDate('1800-01-01', as.character(lubridate::ymd(i)-1))

    } else if (info$cnd == '>'){

      setup_list <- x$filterDate(as.character(lubridate::ymd(i)+1), '2500-01-01')

    } else if (info$cnd == '<='){

      setup_list <- x$filterDate('1800-01-01', i)

    } else if (info$cnd == '>='){

      setup_list <- x$filterDate(i, '2500-01-01')

    } else if (info$cnd == '==' | info$cnd == '%in%'){

      setup_list <- x$filterDate(i)

    } else {

    stop('wrong condition type, please check')

    }

    ic_list <- append(ic_list, setup_list)
  }

  ic_list <- unlist(ic_list)

  mergedCol = ee$ImageCollection(list())

  for (i in 1:length(ic_list)) {
    mergedCol = mergedCol$merge(ic_list[[i]]);
  }

  mergedCol

}

year_filter <- function(x,info){

  ic_list <- list()

  for(i in info$user_call[[1]]){

    if(info$cnd == '<'){

      setup_list <- x$filter(ee$Filter$calendarRange(1800,i-1,'year'))

    } else if (info$cnd == '>'){

      setup_list <- x$filter(ee$Filter$calendarRange(i+1,2200,'year'))

    } else if (info$cnd == '<='){

      setup_list <- x$filter(ee$Filter$calendarRange(1800,i,'year'))

    } else if (info$cnd == '>='){

      setup_list <- x$filter(ee$Filter$calendarRange(i,2200,'year'))

    } else if (info$cnd == '==' | info$cnd == '%in%'){

      setup_list <- x$filter(ee$Filter$calendarRange(i,i,'year'))

    } else {

      stop('wrong condition type, please check')

    }

    ic_list <- append(ic_list, setup_list)
  }

  ic_list <- unlist(ic_list)

  mergedCol = ee$ImageCollection(list())

  for (i in 1:length(ic_list)) {
    mergedCol = mergedCol$merge(ic_list[[i]]);
  }

  mergedCol
}

month_filter <- function(x,info){
  ic_list <- list()
  for(i in info$user_call[[1]]){

    if(info$cnd == '<'){

      setup_list <- x$filter(ee$Filter$calendarRange(1,i-1,'month'))

    } else if (info$cnd == '>'){

      setup_list <- x$filter(ee$Filter$calendarRange(i+1,12,'month'))

    } else if (info$cnd == '<='){

      setup_list <- x$filter(ee$Filter$calendarRange(1,i,'month'))

    } else if (info$cnd == '>='){

      setup_list <- x$filter(ee$Filter$calendarRange(i,12,'month'))

    } else if (info$cnd == '==' | info$cnd == '%in%'){

      setup_list <- x$filter(ee$Filter$calendarRange(i,i,'month'))

    } else {

      stop('wrong condition type, please check')

    }

    ic_list <- append(ic_list, setup_list)
  }

  ic_list <- unlist(ic_list)

  mergedCol = ee$ImageCollection(list())

  for (i in 1:length(ic_list)) {
    mergedCol = mergedCol$merge(ic_list[[i]]);
  }

  mergedCol
}

final_merge <- function(ic_list){

  mergedCol = ee$ImageCollection(list())

  for (i in 1:length(ic_list)) {
    mergedCol = mergedCol$merge(ic_list[[i]]);
  }

  mergedCol
}

symbol_func <- function(quo_chr){

  symb_list <- data.frame()

  for(i in 1:length(quo_chr)){

    sym_it <- data.frame(cnd = as.character(quo_chr[[i]][[1]]))
    symb_list <- plyr::rbind.fill(symb_list, sym_it)
  }
  symb_list
}

arg_func <- function(quo_chr){

  arg_list <- data.frame()

  for(i in 1:length(quo_chr)){

    arg_it <- data.frame(arg = as.character(quo_chr[[i]][[2]]))
    arg_list <- plyr::rbind.fill(arg_list, arg_it)
  }
  arg_list
}

vector_func <- function(quo_chr){

  arg_list <- list()

  for(i in 1:length(quo_chr)){

    arg_it <- list(eval(quo_chr[[i]][[3]]))
    arg_list <- append(arg_list, arg_it)
  }
  arg_list
}

final_filter_distinct <- function(x){

  ymd_list = x$iterate(iterate_over_final_ic, ee$List(list()))

  ymd_list <- ymd_list$getInfo()

  ymd_list_d <- duplicated(ymd_list)

  ymd_list <- ymd_list[ymd_list_d]

  ymd_list <- as.character(lubridate::ymd(ymd_list))

  new_collection <- x$map(rgee::ee_utils_pyfunc(add_date_meta_to_ic))

  if(length(ymd_list) == 1){

    new_collection = new_collection$filter(ee$Filter$inList("Date", ee$List(list(ymd_list))))

    new_collection <- new_collection$distinct("Date")

  } else if (length(ymd_list) > 1){

    new_collection = new_collection$filter(ee$Filter$inList("Date", ee$List(ymd_list)))

    new_collection <- new_collection$distinct("Date")


  } else {

  }

  new_collection
}

iterate_over_final_ic <- function(image, newlist){
  date = ee$Number$parse(image$date()$format("YYYYMMdd"))
  newlist = ee$List(newlist)
  return(ee$List(newlist$add(date)$sort()))
}

add_date_meta_to_ic = function(x) {
  return(x$set('Date', ee$Date(x$get('system:time_start'))$format("YYYY-MM-dd")))}
