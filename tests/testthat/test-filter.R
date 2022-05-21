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

  # with %in% and : and year
  filter_year <- modis_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2008:2010))

  ee_filter <- modis_ic$filterDate('2008-01-01', '2011-01-01')

  expect_equal(filter_year$ee_ob$size()$getInfo(), 69)
  expect_equal(filter_year$ee_ob$size()$getInfo(), ee_filter$size()$getInfo())

  # with non-sequential years
  filter_year <- modis_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2007,2012))

  ee_filter1 <- modis_ic$filterDate('2007-01-01', '2008-01-01')
  ee_filter2 <- modis_ic$filterDate('2012-01-01', '2013-01-01')
  ee_filter <- ee_filter1$merge(ee_filter2)

  expect_equal(filter_year$ee_ob$size()$getInfo(), 46)
  expect_equal(filter_year$ee_ob$size()$getInfo(), ee_filter$size()$getInfo())

  #with landsat T1/SR

  roi <- ee$Geometry$Polygon(list(
    c(-114.275, 45.891),
    c(-108.275, 45.868),
    c(-108.240, 48.868),
    c(-114.240, 48.891)
  ))

  ld_ic = ee$ImageCollection("LANDSAT/LC08/C01/T1_SR")$filterBounds(roi)

  # with == and year
  filter_year <- ld_ic %>%
    as_tidyee() %>%
    filter(year == 2018)

  ee_filter <- ld_ic$filterDate('2018-01-01', '2019-01-01')

  expect_equal(filter_year$ee_ob$size()$getInfo(), 308)
  expect_equal(filter_year$ee_ob$size()$getInfo(), ee_filter$size()$getInfo())

  # with %in% and : and year
  filter_year <- ld_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2018:2020))

  ee_filter <- ld_ic$filterDate('2018-01-01', '2021-01-01')

  expect_equal(filter_year$ee_ob$size()$getInfo(), 946)
  expect_equal(filter_year$ee_ob$size()$getInfo(), ee_filter$size()$getInfo())

  # with non-sequential years
  filter_year <- ld_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2017,2021))

  ee_filter1 <- ld_ic$filterDate('2017-01-01', '2018-01-01')
  ee_filter2 <- ld_ic$filterDate('2021-01-01', '2022-01-01')
  ee_filter <- ee_filter1$merge(ee_filter2)

  expect_equal(filter_year$ee_ob$size()$getInfo(), 660)
  expect_equal(filter_year$ee_ob$size()$getInfo(), ee_filter$size()$getInfo())

})
