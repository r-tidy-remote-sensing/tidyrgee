skip_if_no_pypkg()
test_that("working with summarise by filter and grouping", {

  ## Landsat 8
  roi <- ee$Geometry$Point(-114.275, 45.891)

  ld_ic = ee$ImageCollection("LANDSAT/LC08/C01/T1_SR")$filterBounds(roi)

  # with == and year
  filter_year_month <- ld_ic %>%
    as_tidyee() %>%
    filter(year == 2018) %>%
    group_by(year, month) %>%
    summarise(stat = c('mean', 'median'))

  meta <- filter_year_month$ee_ob$getInfo()

  expect_equal(length(meta[["features"]][[1]][["bands"]]), 24)

  expect_equal(filter_year_month$vrt$band_names[[1]], c("B1_mean", "B2_mean",
                                                            "B3_mean", "B4_mean",
                                                            "B5_mean", "B6_mean",
                                                            "B7_mean", "B10_mean",
                                                            "B11_mean","sr_aerosol_mean",
                                                            "pixel_qa_mean", "radsat_qa_mean",
                                                            "B1_median", "B2_median",
                                                            "B3_median", "B4_median",
                                                            "B5_median", "B6_median",
                                                            "B7_median", "B10_median",
                                                            "B11_median","sr_aerosol_median",
                                                            "pixel_qa_median","radsat_qa_median" ))

  # related to issue #24
  # just comment out and watch for bugs/etc...

  # filter_year_month <- ld_ic %>%
  #   as_tidyee() %>%
  #   filter(year %in% c(2016:2019)) %>%
  #   group_by(year, month) %>%
  #   summarise(stat = c('mean', 'median'))
  #
  # meta <- filter_year_month$ee_ob$getInfo()
  #
  # expect_equal(length(meta[["features"]][[1]][["bands"]]), 24)

  # with MODIS
  modis_ic <- rgee::ee$ImageCollection("MODIS/006/MOD13Q1")

  # with %in% and year
  filter_year_month <- modis_ic %>%
    as_tidyee() %>%
    filter(year %in% c(2008:2015)) %>%
    group_by(year, month) %>%
    summarise(stat = c('mean', 'median'))


  meta <- filter_year_month$ee_ob$getInfo()

  expect_equal(length(meta[["features"]][[1]][["bands"]]), 24)

  })

