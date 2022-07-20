skip_if_no_pypkg()
test_that("testing filter() using year", {

  # with MODIS
  modis_ic <- rgee::ee$ImageCollection("MODIS/006/MOD13Q1")

  # with == and year
  filter_year <- modis_ic %>%
                 as_tidyee() %>%
                 filter(year == 2008)

  ee_filter <- modis_ic$filterDate('2008-01-01', '2009-01-01')

  expect_equal(filter_year$ee_ob$size()$getInfo(), 23)
  expect_equal(filter_year$ee_ob$size()$getInfo(), ee_filter$size()$getInfo())
  expect_equal(nrow(filter_year$vrt),filter_year$ee_ob$size()$getInfo())

  # with %in% and : and year
  filter_year <- modis_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2008:2010))

  ee_filter <- modis_ic$filterDate('2008-01-01', '2011-01-01')

  expect_equal(filter_year$ee_ob$size()$getInfo(), 69)
  expect_equal(filter_year$ee_ob$size()$getInfo(), ee_filter$size()$getInfo())
  expect_equal(nrow(filter_year$vrt),filter_year$ee_ob$size()$getInfo())

  # with non-sequential years
  filter_year <- modis_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2007,2012))

  ee_filter1 <- modis_ic$filterDate('2007-01-01', '2008-01-01')
  ee_filter2 <- modis_ic$filterDate('2012-01-01', '2013-01-01')
  ee_filter <- ee_filter1$merge(ee_filter2)

  expect_equal(filter_year$ee_ob$size()$getInfo(), 46)
  expect_equal(filter_year$ee_ob$size()$getInfo(), ee_filter$size()$getInfo())
  expect_equal(nrow(filter_year$vrt),filter_year$ee_ob$size()$getInfo())

  #with landsat T1/SR

  roi <- ee$Geometry$Point(-114.275, 45.891)

  ld_ic = ee$ImageCollection("LANDSAT/LC08/C01/T1_SR")$filterBounds(roi)

  # with == and year
  filter_year <- ld_ic %>%
    as_tidyee() %>%
    filter(year == 2018)

  ee_filter <- ld_ic$filterDate('2018-01-01', '2019-01-01')

  expect_equal(filter_year$ee_ob$size()$getInfo(), ee_filter$size()$getInfo())
  expect_equal(nrow(filter_year$vrt),filter_year$ee_ob$size()$getInfo())

  # with %in% and : and year
  filter_year <- ld_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2018:2020))

  ee_filter <- ld_ic$filterDate('2018-01-01', '2021-01-01')

  expect_equal(filter_year$ee_ob$size()$getInfo(), ee_filter$size()$getInfo())
  expect_equal(nrow(filter_year$vrt),filter_year$ee_ob$size()$getInfo())

  # with non-sequential years
  filter_year <- ld_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2017,2021))

  ee_filter1 <- ld_ic$filterDate('2017-01-01', '2018-01-01')
  ee_filter2 <- ld_ic$filterDate('2021-01-01', '2022-01-01')
  ee_filter <- ee_filter1$merge(ee_filter2)

  expect_equal(filter_year$ee_ob$size()$getInfo(), ee_filter$size()$getInfo())
  expect_equal(nrow(filter_year$vrt),filter_year$ee_ob$size()$getInfo())

  #with sentinel
  s_ic = ee$ImageCollection("COPERNICUS/S2")$filterBounds(roi)

  # with == and year
  filter_year <- s_ic %>%
    as_tidyee() %>%
    filter(year == 2018)

  ee_filter <- s_ic$filterDate('2018-01-01', '2019-01-01')

  expect_equal(filter_year$ee_ob$size()$getInfo(), ee_filter$size()$getInfo())
  expect_equal(nrow(filter_year$vrt),filter_year$ee_ob$size()$getInfo())

  # with %in% and : and year
  filter_year <- s_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2018:2020))

  ee_filter <- s_ic$filterDate('2018-01-01', '2021-01-01')

  expect_equal(filter_year$ee_ob$size()$getInfo(), ee_filter$size()$getInfo())

  expect_equal(nrow(filter_year$vrt),filter_year$ee_ob$size()$getInfo())

  # with non-sequential years
  filter_year <- s_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2017,2021))

  ee_filter1 <- s_ic$filterDate('2017-01-01', '2018-01-01')
  ee_filter2 <- s_ic$filterDate('2021-01-01', '2022-01-01')
  ee_filter <- ee_filter1$merge(ee_filter2)

  expect_equal(filter_year$ee_ob$size()$getInfo(), ee_filter$size()$getInfo())

  expect_equal(nrow(filter_year$vrt),filter_year$ee_ob$size()$getInfo())

})

test_that("testing filter() using month", {

  # with MODIS
  modis_ic <- rgee::ee$ImageCollection("MODIS/006/MOD13Q1")

  month = c(8,10)
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
      month_filter <- modis_ic %>%
        as_tidyee() %>%
        filter(month %in% c(8,10))

      month_filter$ee_ob$size()$getInfo()
    })

  month = c(8,12)
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
      month_filter <- modis_ic %>%
        as_tidyee() %>%
        filter(month %in% c(8,12))

      month_filter$ee_ob$size()$getInfo()
    })


})


test_that('year, month within filter',{

  # with MODIS
  modis_ic <- rgee::ee$ImageCollection("MODIS/006/MOD13Q1")

  month = c(8,10)
  year = c(2010,2011)

  yr_ic <-  ee_year_filter(modis_ic,year = year)
  yr_mo_ic <-  ee_month_filter(yr_ic,month=month)

  filter_year <- modis_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2010,2011),
           month %in% c(8,10))

  expect_equal(filter_year$ee_ob$size()$getInfo(), yr_mo_ic$size()$getInfo())

  # with landsat 8 T1/SR

  roi <- ee$Geometry$Point(-114.275, 45.891)

  ld_ic = ee$ImageCollection("LANDSAT/LC08/C01/T1_SR")$filterBounds(roi)

  month = c(8,10)
  year = c(2018,2020)

  yr_ic <-  ee_year_filter(ld_ic,year = year)
  yr_mo_ic <-  ee_month_filter(yr_ic,month=month)

  filter_year <- ld_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2018,2020),
           month %in% c(8,10))

  expect_equal(filter_year$ee_ob$size()$getInfo(), yr_mo_ic$size()$getInfo())

  })
