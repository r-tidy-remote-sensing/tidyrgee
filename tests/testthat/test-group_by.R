skip_if_no_pypkg()
test_that("grouping by year", {

  #### group_by method doesn't do anything with ee.ImageCollection so
  ## just testing vrt essentially.

  # with MODIS
  modis_ic <- rgee::ee$ImageCollection("MODIS/006/MOD13Q1")

  # with %in% and year
  group_year <- modis_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2008:2015)) %>%
    group_by(year)

  expect_equal(inherits(group_year$vrt, "grouped_df"), TRUE)

  # with == and year

  group_year <- modis_ic %>%
    as_tidyee() %>%
    filter(year == 2008) %>%
    group_by(year)

  expect_equal(inherits(group_year$vrt, "grouped_df"), TRUE)

  #with landsat T1/SR

  roi <- ee$Geometry$Point(-114.275, 45.891)

  ld_ic = ee$ImageCollection("LANDSAT/LC08/C01/T1_SR")$filterBounds(roi)

  # with == and year
  filter_year <- ld_ic %>%
    as_tidyee() %>%
    filter(year == 2018) %>%
    group_by(year)

  expect_equal(inherits(group_year$vrt, "grouped_df"), TRUE)


})


test_that("grouping by year", {

  #### group_by method doesn't do anything with ee.ImageCollection so
  ## just testing vrt essentially.

  # with MODIS
  modis_ic <- rgee::ee$ImageCollection("MODIS/006/MOD13Q1")

  # with %in% and month
  group_month <- modis_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2008:2015)) %>%
    group_by(month)

  expect_equal(inherits(group_month$vrt, "grouped_df"), TRUE)

  # with == and year

  group_month <- modis_ic %>%
    as_tidyee() %>%
    filter(year == 2008) %>%
    group_by(month)

  expect_equal(inherits(group_month$vrt, "grouped_df"), TRUE)

  #with landsat T1/SR

  roi <- ee$Geometry$Point(-114.275, 45.891)

  ld_ic = ee$ImageCollection("LANDSAT/LC08/C01/T1_SR")$filterBounds(roi)

  # with == and year
  filter_month <- ld_ic %>%
    as_tidyee() %>%
    filter(year == 2018) %>%
    group_by(month)

  expect_equal(inherits(group_month$vrt, "grouped_df"), TRUE)


})

test_that("grouping by year and month", {

  #### group_by method doesn't do anything with ee.ImageCollection so
  ## just testing vrt essentially.

  # with MODIS
  modis_ic <- rgee::ee$ImageCollection("MODIS/006/MOD13Q1")

  # with %in% and year
  group_year_month <- modis_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2008:2015)) %>%
    group_by(year, month)

  expect_equal(inherits(group_year_month$vrt, "grouped_df"), TRUE)

  # with == and year

  group_year_month <- modis_ic %>%
    as_tidyee() %>%
    filter(year == 2008) %>%
    group_by(year, month)

  expect_equal(inherits(group_year_month$vrt, "grouped_df"), TRUE)

  #with landsat T1/SR

  roi <- ee$Geometry$Point(-114.275, 45.891)

  ld_ic = ee$ImageCollection("LANDSAT/LC08/C01/T1_SR")$filterBounds(roi)

  # with == and year
  filter_year_month <- ld_ic %>%
    as_tidyee() %>%
    filter(year == 2018) %>%
    group_by(year, month)

  expect_equal(inherits(group_year_month$vrt, "grouped_df"), TRUE)

  # with == and year
  filter_year_month <- ld_ic %>%
    as_tidyee() %>%
    filter(year == 2018) %>%
    group_by(month, year)

  expect_equal(inherits(group_year_month$vrt, "grouped_df"), TRUE)


})

