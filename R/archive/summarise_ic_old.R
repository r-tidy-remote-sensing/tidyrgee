summarise.grouped_imageCol <-  function(x,stat,...){
  date_range <-  date_range_imageCol(x)
  start_year <- lubridate::year(date_range[1])
  end_year <- lubridate::year(date_range[2])
  year <- c(start_year,end_year)
  if(attributes(x)$grouped_vars =="year"){
    ee_year_composite(imageCol = x,year = year,stat = stat)
  }
}
