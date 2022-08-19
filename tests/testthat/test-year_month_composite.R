skip_if_no_pypkg()
test_that("year_month_composite; issue #28", {

  geom <- ee$Geometry$Polygon(list(
    c(44.2354847930793, 34.83077069846819),
    c(44.261577322376176, 34.692001577255105),
    c(44.40851946104805, 34.511140220037795),
    c(44.607646658313676, 34.47152432533435),
    c(44.687297537219926, 34.58918498051208),
    c(44.5211293243293, 34.75069665768057),
    c(44.393413259876176, 34.810477595189816),
    c(44.28217668761055, 34.88598770009403),
    c(44.223125173938676, 34.84316957807562)
  ))

  l8_ic <-  ee$ImageCollection('LANDSAT/LC08/C02/T1_L2')$
    filterDate("2013-01-01","2022-12-31")$
    filterBounds(geom)$
    filter(ee$Filter$lt('CLOUD_COVER', 25))

  l8_ic_tidy <-   as_tidyee(l8_ic)


  l8_median_compsites <- l8_ic_tidy |>
    group_by(year, month) |>
    summarise(
      stat="median"
    )

  # this is not good they should be the same
  expect_equal(l8_median_compsites$ee_ob$size()$getInfo(),l8_median_compsites$vrt|> nrow())

})
