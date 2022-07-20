
skip_if_no_pypkg()
test_that("initial tidyee objects are", {
  modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
  modis_ic_tidy <- tidyrgee::as_tidyee(modis_ic)

  vrt_rows <-  modis_ic_tidy$vrt |> nrow()
  ic_length <-  modis_ic_tidy$ee_ob$size()$getInfo()
  expect_equal(vrt_rows, ic_length)
})


test_that("tidyee objects aligned after month summary", {
  modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
  modis_ic_tidy <- tidyrgee::as_tidyee(modis_ic)
  modis_summarised <-  modis_ic_tidy |>
    group_by(month) |>
    summarise(
      stat= "mean"
    )
  vrt_rows <-  modis_summarised$vrt |> nrow()
  ic_length <-  modis_summarised$ee_ob$size()$getInfo()
  expect_equal(vrt_rows, ic_length)
})

test_that("tidyee objects aligned after year summary", {
  modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
  modis_ic_tidy <- tidyrgee::as_tidyee(modis_ic)
  modis_summarised <-  modis_ic_tidy |>
    group_by(year) |>
    summarise(
      stat= "mean"
    )
  vrt_rows <-  modis_summarised$vrt |> nrow()
  ic_length <-  modis_summarised$ee_ob$size()$getInfo()
  expect_equal(vrt_rows, ic_length)
})

test_that("tidyee objects aligned after year-month summary", {
  modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
  modis_ic_tidy <- tidyrgee::as_tidyee(modis_ic)
  modis_summarised <-  modis_ic_tidy |>
    group_by(year,month) |>
    summarise(
      stat= "mean"
    )
  vrt_rows <-  modis_summarised$vrt |> nrow()
  ic_length <-  modis_summarised$ee_ob$size()$getInfo()
  expect_equal(vrt_rows, ic_length)
})
