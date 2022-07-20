skip_if_no_pypkg()
test_that("ee_year_filter works", {

  # with MODIS
  modis_ic <- rgee::ee$ImageCollection("MODIS/006/MOD13Q1")

  num_img_2003 <- modis_ic$filterDate("2003-01-01","2003-12-31")$size()$getInfo()
  num_img_2007 <- modis_ic$filterDate("2007-01-01","2007-12-31")$size()$getInfo()
  num_images_2003_and_2007 <- num_img_2003+num_img_2007

  modis_ic_year_filtered <- modis_ic |>
    ee_year_filter(year= c(2003,2007))


  expect_equal(modis_ic_year_filtered$
                 size()$
                 getInfo() ,
               num_images_2003_and_2007)

  #with landsat T1/SR

  roi <- ee$Geometry$Polygon(list(
    c(-114.275, 45.891),
    c(-108.275, 45.868),
    c(-108.240, 48.868),
    c(-114.240, 48.891)
  ))

  imageCol = ee$ImageCollection("LANDSAT/LC08/C01/T1_SR")$filterBounds(roi)

  num_img_2014 <- imageCol$filterDate("2014-01-01","2014-12-31")$size()$getInfo()
  num_img_2017 <- imageCol$filterDate("2017-01-01","2017-12-31")$size()$getInfo()
  num_images_2014_and_2017 <- num_img_2014+num_img_2017

  filter_by_year = imageCol %>%
                   ee_year_filter(year = c(2014,2017))

  expect_equal(filter_by_year$size()$getInfo(), num_images_2014_and_2017)

  #with COPERNICUS/S2

  roi = ee$Geometry$Point(-115.11353, 48.1380)
  imageCol = ee$ImageCollection("COPERNICUS/S2")$filterBounds(roi)

  num_img_2018 <- imageCol$filterDate("2018-01-01","2018-12-31")$size()$getInfo()
  num_img_2020 <- imageCol$filterDate("2020-01-01","2020-12-31")$size()$getInfo()
  num_images_2018_and_2020 <- num_img_2018+num_img_2020

  filter_by_year = imageCol %>%
    ee_year_filter(year = c(2018,2020))

  expect_equal(filter_by_year$size()$getInfo(), num_images_2018_and_2020)

  #with three years
  num_img_2018 <- imageCol$filterDate("2018-01-01","2018-12-31")$size()$getInfo()
  num_img_2020 <- imageCol$filterDate("2020-01-01","2020-12-31")$size()$getInfo()
  num_img_2021 <- imageCol$filterDate("2021-01-01","2021-12-31")$size()$getInfo()

    num_images_2018_and_2020_and_2021 <- num_img_2018+num_img_2020+num_img_2021

  filter_by_year = imageCol %>%
    ee_year_filter(year = c(2018,2020, 2021))

  expect_equal(filter_by_year$size()$getInfo(), num_images_2018_and_2020_and_2021)


  # there are differences though depending on size; see below

  imageCol = ee$ImageCollection("LANDSAT/LC08/C01/T1_SR")

  num_img_2014 <- imageCol$filterDate("2014-01-01","2014-12-31")$size()$getInfo()
  num_img_2017 <- imageCol$filterDate("2017-01-01","2017-12-31")$size()$getInfo()
  num_images_2014_and_2017 <- num_img_2014+num_img_2017

  filter_by_year = imageCol %>%
    ee_year_filter(year = c(2014,2017))

  expect_error(expect_equal(filter_by_year$size()$getInfo(), num_images_2014_and_2017))

  # for IDAHO_EPSCOR/GRIDMET

  roi = ee$Geometry$Point(-115.11353, 48.1380)
  imageCol = ee$ImageCollection("IDAHO_EPSCOR/GRIDMET")$filterBounds(roi)

  num_img_2018 <- imageCol$filterDate("2018-01-01","2018-12-31")$size()$getInfo()
  num_img_2020 <- imageCol$filterDate("2020-01-01","2020-12-31")$size()$getInfo()
  num_images_2018_and_2020 <- num_img_2018+num_img_2020

  filter_by_year = imageCol %>%
    ee_year_filter(year = c(2018,2020))

  expect_error(expect_equal(filter_by_year$size()$getInfo(), num_images_2018_and_2020))

  #reason for errors is that filterDate only goes to 12-30 and not 12-31; see below
  iterate_over_final_ic <- function(image, newlist){
    date = ee$Number$parse(image$date()$format("YYYYMMdd"))
    newlist = ee$List(newlist)
    return(ee$List(newlist$add(date)$sort()))
  }

  year_list = filter_by_year$iterate(iterate_over_final_ic, ee$List(list()))

  year_list <- year_list$getInfo()

  num_img_2018 <- imageCol$filterDate("2018-01-01","2018-12-31")
  num_img_2020 <- imageCol$filterDate("2020-01-01","2020-12-31")

  merged <- num_img_2018$merge(num_img_2020)

  merge_list = merged$iterate(iterate_over_final_ic, ee$List(list()))

  merge_list <- merge_list$getInfo()

  dates_not_in <- year_list[!(year_list %in% merge_list)]

  expect_equal(dates_not_in, c(20181231,20201231))

  # now fix with 01-01 as last date for IDAHO_EPSCOR/GRIDMET

  roi = ee$Geometry$Point(-115.11353, 48.1380)
  imageCol = ee$ImageCollection("IDAHO_EPSCOR/GRIDMET")$filterBounds(roi)

  num_img_2018 <- imageCol$filterDate("2018-01-01","2019-01-01")$size()$getInfo()
  num_img_2020 <- imageCol$filterDate("2020-01-01","2021-01-01")$size()$getInfo()
  num_images_2018_and_2020 <- num_img_2018+num_img_2020

  filter_by_year = imageCol %>%
    ee_year_filter(year = c(2018,2020))

  expect_equal(filter_by_year$size()$getInfo(), num_images_2018_and_2020)

  })


test_that("ee_month_filter works", {

  # with MODIS
  modis_ic <- rgee::ee$ImageCollection("MODIS/006/MOD13Q1")

  month = c(3,7)
  expect_equal({

    ee_month_list <- rgee::ee$List(month) # switched from ee$List$sequence - let the user make sequence in R or suppply raw

    ic_list <-
      ee_month_list$map(rgee::ee_utils_pyfunc(function (m) {
        modis_ic$filter(rgee::ee$Filter$calendarRange(m, m, 'month'))
      }

      ))

    fc_from_ic_list <- rgee::ee$FeatureCollection(ic_list)
    first_month_filter <- rgee::ee$ImageCollection(fc_from_ic_list$flatten())
    first_month_filter$size()$getInfo()},
    {
   month_filter <- modis_ic |>
    ee_month_filter(month= c(3,7))

   month_filter$size()$getInfo()
  })

  #with four months
  month = c(3,7,9,11)
  expect_equal({

    ee_month_list <- rgee::ee$List(month) # switched from ee$List$sequence - let the user make sequence in R or suppply raw

    ic_list <-
      ee_month_list$map(rgee::ee_utils_pyfunc(function (m) {
        modis_ic$filter(rgee::ee$Filter$calendarRange(m, m, 'month'))
      }

      ))

    fc_from_ic_list <- rgee::ee$FeatureCollection(ic_list)
    first_month_filter <- rgee::ee$ImageCollection(fc_from_ic_list$flatten())
    first_month_filter$size()$getInfo()},
    {
      month_filter <- modis_ic |>
        ee_month_filter(month= c(3,7,9,11))

      month_filter$size()$getInfo()
    })

  # with landsat T1/SR

  roi = ee$Geometry$Point(-115.11353, 48.1380)
  ld_ic <- rgee::ee$ImageCollection("LANDSAT/LC08/C01/T1_SR")$filterBounds(roi)

  month = c(3,7)
  expect_equal({

    ee_month_list <- rgee::ee$List(month) # switched from ee$List$sequence - let the user make sequence in R or suppply raw

    ic_list <-
      ee_month_list$map(rgee::ee_utils_pyfunc(function (m) {
        ld_ic$filter(rgee::ee$Filter$calendarRange(m, m, 'month'))
      }

      ))

    fc_from_ic_list <- rgee::ee$FeatureCollection(ic_list)
    first_month_filter <- rgee::ee$ImageCollection(fc_from_ic_list$flatten())
    first_month_filter$size()$getInfo()},
    {
      month_filter <- ld_ic |>
        ee_month_filter(month= c(3,7))

      month_filter$size()$getInfo()
    })

})




