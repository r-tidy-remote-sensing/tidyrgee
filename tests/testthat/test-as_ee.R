skip_if_no_pypkg()

test_that("getting back ee object", {

  modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")

  # create tidyee class
  modis_ic_tidy <- as_tidyee(modis_ic)
  # convert back to origina ee$ImageCollection class
  now_a_ee <- modis_ic_tidy |>
    as_ee()

  expect_equal(class(now_a_ee)[1], 'ee.imagecollection.ImageCollection')

  now_a_ee_image <- now_a_ee$mean()

  expect_equal(class(now_a_ee_image)[1], 'ee.image.Image')

  })
