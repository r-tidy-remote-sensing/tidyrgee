
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidyrgee

<!-- badges: start -->

[![R-CMD-check](https://github.com/r-tidy-remote-sensing/tidyrgee/workflows/R-CMD-check/badge.svg)](https://github.com/r-tidy-remote-sensing/tidyrgee/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/tidyrgee)](https://CRAN.R-project.org/package=tidyrgee)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![codecov](https://codecov.io/gh/r-tidy-remote-sensing/tidyrgee/branch/main/graph/badge.svg)](https://app.codecov.io/gh/r-tidy-remote-sensing/tidyrgee)
[![contributions
welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues)

<!-- badges: end -->

tidyrgee brings components of
[dplyr’s](https://github.com/tidyverse/dplyr/) syntax to remote sensing
analysis, using the [rgee](https://github.com/r-spatial/rgee) package.

rgee is an R-API for the [Google Earth Engine
(GEE)](https://earthengine.google.com/) which provides R support to the
methods/functions available in the JavaScript code editor and python
API. The `rgee` syntax was written to be very similar to the GEE
Javascript/python. However, this syntax can feel unnatural and difficult
at times especially to users with less experience in GEE. Simple
concepts that are easy express verbally can be cumbersome even to
advanced users (see *Syntax Comparison*). The `tidyverse` has provided
[principals and
concepts](https://tidyr.tidyverse.org/articles/tidy-data.html) that help
data scientists/R-users efficiently write and communicate there code in
a clear and concise manner. `tidyrgee` aims to bring these principals to
GEE-remote sensing analyses.

tidyrgee provides the convenience of pipe-able dplyr style methods such
as `filter`, `group_by`, `summarise`, `select`,`mutate`,etc. using
[rlang’s](https://github.com/r-lib/rlang) style of non-standard
evaluation (NSE)

try it out!

## Installation

Install from CRAN with:

``` r
install.packages("tidyrgee")
```

You can install the development version of tidyrgee from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("r-tidy-remote-sensing/tidyrgee")
```

It is important to note that to use tidyrgee you must be signed up for a
GEE developer account. Additionally you must install the rgee package
following there [installation and setup instructions
here](https://github.com/r-spatial/rgee)

## Syntax Comparison

Below is a quick example demonstrating the simplified syntax. Note that
the `rgee` syntax is very similar to the syntax in the Javascript code
editor. In this example I want to simply calculate mean monthly NDVI
(per pixel) for every year from 2000-2015. This is clearly a fairly
simple analysis to verbalize/conceptualize. Yet, using using standard
GEE conventions, the process is not so simple. Aside, from many
peculiarities such as `flattening` a list and then calling and then
rebuilding the `imageCollection` at the end, I also have to write and
**think about** a double mapping statement using months and years (sort
of like a double for-loop). By comparison the tidyrgee syntax removes
the complexity and allows me to write the code in a more human
readable/interpretable format.

<table class='table' width="100%">
<tr>
<th>
rgee (similar to Javascript)
</th>
<th>
tidyrgee
</th>
<tr>
<tr>
<td>

``` r
modis <- ee$ImageCollection( "MODIS/006/MOD13Q1")
modis_ndvi <-  modis$select("NDVI")
month_list <- ee$List$sequence(1,12)
year_list <- ee$List$sequence(2000,2015)
  
  
mean_ndvi <- ee$ImageCollection$fromImages(
    year_list$map(
      ee_utils_pyfunc(function (y) {
        month_list$map(
          ee_utils_pyfunc(function (m) {
            # dat_pre_filt <- 
            modis_ndvi$
              filter(ee$Filter$calendarRange(y, y, 'year'))$
              filter(ee$Filter$calendarRange(m, m, 'month'))$
              mean()$
              set('year',y)$
              set('month',m)$
              set('date',ee$Date$fromYMD(y,m,1))$
              set('system:time_start',ee$Date$millis(ee$Date$fromYMD(y,m,1)))
              
            
          })
        )
      }))$flatten())
```

</td>
<td>

``` r
modis <- ee$ImageCollection( "MODIS/006/MOD13Q1")
modis_tidy <-  as_tidyee(modis) 

mean_ndvi <-  modis_tidy |> 
  select("NDVI") |> 
  filter(year %in% 2000:2015) |> 
  group_by(year, month) |> 
  summarise(stat= "mean")
```

</td>
<tr>
</table>

## Example usage

Below are a couple examples showing some of the available functions.

To load images/imageCollections you follow the standard approach using
`rgee`:

-   load libraries
-   initialize the GEE session
-   load `ee$ImageCollection`/ `ee$Image`

``` r
library(tidyrgee)
library(rgee)
ee_Initialize(quiet = T)

modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
```

Once the above steps are performed you can convert the
`ee$ImageCollection` to a `tidyee` object with the function `as_tidyee`.
The tidyee object stores the original `ee$ImageCollection` as `ee_ob`
(for earth engine object) and produces as virtual table/data.frame
stored as `vrt`. This vrt not only facilitates the use of
dplyr/tidyverse methods, but also allows the user to better view the
data stored in the accompanying imageCollection. The `ee_ob` and `vrt`
inside the tidyee object are linked, any function applied to the tidyee
object will apply to them both so that they remain in sync.

``` r
modis_tidy <-  as_tidyee(modis_ic)
```

the `vrt` comes with a few built in columns which you can use off the
bat for filtering and grouping, but you can also `mutate` additional
info for filtering and grouping (i.e using `lubridate` to create new
temporal groupings)

``` r
knitr::kable(modis_tidy$vrt |> head())
```

| id                           | time_start | system_index | date       | month | year | doy | band_names                                                                                                                                              |
|:-----------------------------|:-----------|:-------------|:-----------|------:|-----:|----:|:--------------------------------------------------------------------------------------------------------------------------------------------------------|
| MODIS/006/MOD13Q1/2000_02_18 | 2000-02-18 | 2000_02_18   | 2000-02-18 |     2 | 2000 |  49 | NDVI , EVI , DetailedQA , sur_refl_b01 , sur_refl_b02 , sur_refl_b03 , sur_refl_b07 , ViewZenith , SolarZenith , RelativeAzimuth, DayOfYear , SummaryQA |
| MODIS/006/MOD13Q1/2000_03_05 | 2000-03-05 | 2000_03_05   | 2000-03-05 |     3 | 2000 |  65 | NDVI , EVI , DetailedQA , sur_refl_b01 , sur_refl_b02 , sur_refl_b03 , sur_refl_b07 , ViewZenith , SolarZenith , RelativeAzimuth, DayOfYear , SummaryQA |
| MODIS/006/MOD13Q1/2000_03_21 | 2000-03-21 | 2000_03_21   | 2000-03-21 |     3 | 2000 |  81 | NDVI , EVI , DetailedQA , sur_refl_b01 , sur_refl_b02 , sur_refl_b03 , sur_refl_b07 , ViewZenith , SolarZenith , RelativeAzimuth, DayOfYear , SummaryQA |
| MODIS/006/MOD13Q1/2000_04_06 | 2000-04-06 | 2000_04_06   | 2000-04-06 |     4 | 2000 |  97 | NDVI , EVI , DetailedQA , sur_refl_b01 , sur_refl_b02 , sur_refl_b03 , sur_refl_b07 , ViewZenith , SolarZenith , RelativeAzimuth, DayOfYear , SummaryQA |
| MODIS/006/MOD13Q1/2000_04_22 | 2000-04-22 | 2000_04_22   | 2000-04-22 |     4 | 2000 | 113 | NDVI , EVI , DetailedQA , sur_refl_b01 , sur_refl_b02 , sur_refl_b03 , sur_refl_b07 , ViewZenith , SolarZenith , RelativeAzimuth, DayOfYear , SummaryQA |
| MODIS/006/MOD13Q1/2000_05_08 | 2000-05-08 | 2000_05_08   | 2000-05-08 |     5 | 2000 | 129 | NDVI , EVI , DetailedQA , sur_refl_b01 , sur_refl_b02 , sur_refl_b03 , sur_refl_b07 , ViewZenith , SolarZenith , RelativeAzimuth, DayOfYear , SummaryQA |

Next we demonstrate filtering by date, month, and year. The `vrt` and
`ee_ob` are always filtered together

-   **by date**

``` r
modis_tidy   |> 
  filter(date>="2021-06-01")
#> band names: [ NDVI, EVI, DetailedQA, sur_refl_b01, sur_refl_b02, sur_refl_b03, sur_refl_b07, ViewZenith, SolarZenith, RelativeAzimuth, DayOfYear, SummaryQA ] 
#> 
#> $ee_ob
#> EarthEngine Object: ImageCollection
#> $vrt
#> # A tibble: 28 x 9
#>    id              time_start          system_index date       month  year   doy
#>    <chr>           <dttm>              <chr>        <date>     <dbl> <dbl> <dbl>
#>  1 MODIS/006/MOD1~ 2021-06-10 00:00:00 2021_06_10   2021-06-10     6  2021   161
#>  2 MODIS/006/MOD1~ 2021-06-26 00:00:00 2021_06_26   2021-06-26     6  2021   177
#>  3 MODIS/006/MOD1~ 2021-07-12 00:00:00 2021_07_12   2021-07-12     7  2021   193
#>  4 MODIS/006/MOD1~ 2021-07-28 00:00:00 2021_07_28   2021-07-28     7  2021   209
#>  5 MODIS/006/MOD1~ 2021-08-13 00:00:00 2021_08_13   2021-08-13     8  2021   225
#>  6 MODIS/006/MOD1~ 2021-08-29 00:00:00 2021_08_29   2021-08-29     8  2021   241
#>  7 MODIS/006/MOD1~ 2021-09-14 00:00:00 2021_09_14   2021-09-14     9  2021   257
#>  8 MODIS/006/MOD1~ 2021-09-30 00:00:00 2021_09_30   2021-09-30     9  2021   273
#>  9 MODIS/006/MOD1~ 2021-10-16 00:00:00 2021_10_16   2021-10-16    10  2021   289
#> 10 MODIS/006/MOD1~ 2021-11-01 00:00:00 2021_11_01   2021-11-01    11  2021   305
#> # ... with 18 more rows, and 2 more variables: band_names <list>,
#> #   tidyee_index <chr>
#> 
#> attr(,"class")
#> [1] "tidyee"
```

-   **by year**

``` r
modis_tidy   |> 
  filter(year%in% 2010:2011)
#> band names: [ NDVI, EVI, DetailedQA, sur_refl_b01, sur_refl_b02, sur_refl_b03, sur_refl_b07, ViewZenith, SolarZenith, RelativeAzimuth, DayOfYear, SummaryQA ] 
#> 
#> $ee_ob
#> EarthEngine Object: ImageCollection
#> $vrt
#> # A tibble: 46 x 9
#>    id              time_start          system_index date       month  year   doy
#>    <chr>           <dttm>              <chr>        <date>     <dbl> <dbl> <dbl>
#>  1 MODIS/006/MOD1~ 2010-01-01 00:00:00 2010_01_01   2010-01-01     1  2010     1
#>  2 MODIS/006/MOD1~ 2010-01-17 00:00:00 2010_01_17   2010-01-17     1  2010    17
#>  3 MODIS/006/MOD1~ 2010-02-02 00:00:00 2010_02_02   2010-02-02     2  2010    33
#>  4 MODIS/006/MOD1~ 2010-02-18 00:00:00 2010_02_18   2010-02-18     2  2010    49
#>  5 MODIS/006/MOD1~ 2010-03-06 00:00:00 2010_03_06   2010-03-06     3  2010    65
#>  6 MODIS/006/MOD1~ 2010-03-22 00:00:00 2010_03_22   2010-03-22     3  2010    81
#>  7 MODIS/006/MOD1~ 2010-04-07 00:00:00 2010_04_07   2010-04-07     4  2010    97
#>  8 MODIS/006/MOD1~ 2010-04-23 00:00:00 2010_04_23   2010-04-23     4  2010   113
#>  9 MODIS/006/MOD1~ 2010-05-09 00:00:00 2010_05_09   2010-05-09     5  2010   129
#> 10 MODIS/006/MOD1~ 2010-05-25 00:00:00 2010_05_25   2010-05-25     5  2010   145
#> # ... with 36 more rows, and 2 more variables: band_names <list>,
#> #   tidyee_index <chr>
#> 
#> attr(,"class")
#> [1] "tidyee"
```

-   **by month**

``` r
modis_tidy   |> 
  filter(month%in% c(7,8))
#> band names: [ NDVI, EVI, DetailedQA, sur_refl_b01, sur_refl_b02, sur_refl_b03, sur_refl_b07, ViewZenith, SolarZenith, RelativeAzimuth, DayOfYear, SummaryQA ] 
#> 
#> $ee_ob
#> EarthEngine Object: ImageCollection
#> $vrt
#> # A tibble: 91 x 9
#>    id              time_start          system_index date       month  year   doy
#>    <chr>           <dttm>              <chr>        <date>     <dbl> <dbl> <dbl>
#>  1 MODIS/006/MOD1~ 2000-07-11 00:00:00 2000_07_11   2000-07-11     7  2000   193
#>  2 MODIS/006/MOD1~ 2000-07-27 00:00:00 2000_07_27   2000-07-27     7  2000   209
#>  3 MODIS/006/MOD1~ 2000-08-12 00:00:00 2000_08_12   2000-08-12     8  2000   225
#>  4 MODIS/006/MOD1~ 2000-08-28 00:00:00 2000_08_28   2000-08-28     8  2000   241
#>  5 MODIS/006/MOD1~ 2001-07-12 00:00:00 2001_07_12   2001-07-12     7  2001   193
#>  6 MODIS/006/MOD1~ 2001-07-28 00:00:00 2001_07_28   2001-07-28     7  2001   209
#>  7 MODIS/006/MOD1~ 2001-08-13 00:00:00 2001_08_13   2001-08-13     8  2001   225
#>  8 MODIS/006/MOD1~ 2001-08-29 00:00:00 2001_08_29   2001-08-29     8  2001   241
#>  9 MODIS/006/MOD1~ 2002-07-12 00:00:00 2002_07_12   2002-07-12     7  2002   193
#> 10 MODIS/006/MOD1~ 2002-07-28 00:00:00 2002_07_28   2002-07-28     7  2002   209
#> # ... with 81 more rows, and 2 more variables: band_names <list>,
#> #   tidyee_index <chr>
#> 
#> attr(,"class")
#> [1] "tidyee"
```

### Putting a dplyr-like chain together:

In this next example we pipe together multiple functions (`select`,
`filter`, `group_by`, `summarise`) to

1.  select the `NDVI` band from the ImageCollection
2.  filter the imageCollection to a desired date range
3.  group the filtered ImageCollection by month
4.  summarizing each pixel by year and month.

The result will be an `ImageCollection` with the one `Image` per month
(12 images) where each pixel in each image represents the average NDVI
value for that month calculated using monthly data from 2000 2015.

``` r
modis_tidy |> 
  select("NDVI") |> 
  filter(year %in% 2000:2015) |> 
  group_by(month) |> 
  summarise(stat= "mean")
#> band names: [ NDVI_mean ] 
#> 
#> $ee_ob
#> EarthEngine Object: ImageCollection
#> $vrt
#> # A tibble: 12 x 6
#>    month dates_summarised number_images time_start          time_end           
#>    <dbl> <list>                   <int> <dttm>              <dttm>             
#>  1     1 <date [30]>                 30 2001-01-01 00:00:00 2001-01-01 00:00:00
#>  2     2 <date [31]>                 31 2000-02-18 00:00:00 2000-02-18 00:00:00
#>  3     3 <date [32]>                 32 2000-03-05 00:00:00 2000-03-05 00:00:00
#>  4     4 <date [32]>                 32 2000-04-06 00:00:00 2000-04-06 00:00:00
#>  5     5 <date [32]>                 32 2000-05-08 00:00:00 2000-05-08 00:00:00
#>  6     6 <date [32]>                 32 2000-06-09 00:00:00 2000-06-09 00:00:00
#>  7     7 <date [32]>                 32 2000-07-11 00:00:00 2000-07-11 00:00:00
#>  8     8 <date [32]>                 32 2000-08-12 00:00:00 2000-08-12 00:00:00
#>  9     9 <date [32]>                 32 2000-09-13 00:00:00 2000-09-13 00:00:00
#> 10    10 <date [20]>                 20 2000-10-15 00:00:00 2000-10-15 00:00:00
#> 11    11 <date [28]>                 28 2000-11-16 00:00:00 2000-11-16 00:00:00
#> 12    12 <date [32]>                 32 2000-12-02 00:00:00 2000-12-02 00:00:00
#> # ... with 1 more variable: band_names <list>
#> 
#> attr(,"class")
#> [1] "tidyee"
```

You can easily `group_by` more than 1 property to calculate different
summary stats. Below we

1.  filter to only data from 2021-2022
2.  group by year, month and calculate the median NDVI pixel value

As we are using the MODIS 16-day composite we summarising approximately
2 images per month to create median composite image fo reach month in
the specified years. The `vrt` holds a `list-col` containing all the
dates summarised per new composite image.

``` r
modis_tidy |> 
  select("NDVI") |> 
  filter(year %in% 2021:2022) |> 
  group_by(year,month) |> 
  summarise(stat= "median")
#> band names: [ NDVI_median ] 
#> 
#> $ee_ob
#> EarthEngine Object: ImageCollection
#> $vrt
#> # A tibble: 20 x 7
#>     year month dates_summarised number_images time_start time_end   band_names
#>    <dbl> <dbl> <list>                   <int> <date>     <date>     <list>    
#>  1  2021     1 <date [2]>                   2 2021-01-01 2021-01-17 <chr [1]> 
#>  2  2021     2 <date [2]>                   2 2021-02-02 2021-02-18 <chr [1]> 
#>  3  2021     3 <date [2]>                   2 2021-03-06 2021-03-22 <chr [1]> 
#>  4  2021     4 <date [2]>                   2 2021-04-07 2021-04-23 <chr [1]> 
#>  5  2021     5 <date [2]>                   2 2021-05-09 2021-05-25 <chr [1]> 
#>  6  2021     6 <date [2]>                   2 2021-06-10 2021-06-26 <chr [1]> 
#>  7  2021     7 <date [2]>                   2 2021-07-12 2021-07-28 <chr [1]> 
#>  8  2021     8 <date [2]>                   2 2021-08-13 2021-08-29 <chr [1]> 
#>  9  2021     9 <date [2]>                   2 2021-09-14 2021-09-30 <chr [1]> 
#> 10  2021    10 <date [1]>                   1 2021-10-16 2021-10-16 <chr [1]> 
#> 11  2021    11 <date [2]>                   2 2021-11-01 2021-11-17 <chr [1]> 
#> 12  2021    12 <date [2]>                   2 2021-12-03 2021-12-19 <chr [1]> 
#> 13  2022     1 <date [2]>                   2 2022-01-01 2022-01-17 <chr [1]> 
#> 14  2022     2 <date [2]>                   2 2022-02-02 2022-02-18 <chr [1]> 
#> 15  2022     3 <date [2]>                   2 2022-03-06 2022-03-22 <chr [1]> 
#> 16  2022     4 <date [2]>                   2 2022-04-07 2022-04-23 <chr [1]> 
#> 17  2022     5 <date [2]>                   2 2022-05-09 2022-05-25 <chr [1]> 
#> 18  2022     6 <date [2]>                   2 2022-06-10 2022-06-26 <chr [1]> 
#> 19  2022     7 <date [2]>                   2 2022-07-12 2022-07-28 <chr [1]> 
#> 20  2022     8 <date [1]>                   1 2022-08-13 2022-08-13 <chr [1]> 
#> 
#> attr(,"class")
#> [1] "tidyee"
```

To improve interoperability with `rgee` we have included the `as_ee`
function to return the `tidyee` object back to `rgee` classes when
necessary

``` r
modis_ic <- modis_tidy |> as_ee()
```
