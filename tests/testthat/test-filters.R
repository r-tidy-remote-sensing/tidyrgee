library(rgee)
ee_Initialize()

test_that("ee_year_filter works", {

  modis_ic <- rgee::ee$ImageCollection("MODIS/006/MOD13Q1")

  num_img_2003 <- modis_ic$filterDate("2003-01-01","2003-12-31")$size()$getInfo()
  num_img_2007 <- modis_ic$filterDate("2007-01-01","2007-12-31")$size()$getInfo()
  num_images_2003_and_2007 <- num_img_2003+num_img_2003

  modis_ic_year_filtered <- modis_ic |>
    ee_year_filter(year= c(2003,2007))


  expect_equal(modis_ic_year_filtered$
                 size()$
                 getInfo() ,
               num_images_2003_and_2007)



})
