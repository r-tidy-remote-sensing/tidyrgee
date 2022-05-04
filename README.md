
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidyrgee

<!-- badges: start -->

[![R-CMD-check](https://github.com/r-tidy-remote-sensing/tidyrgee/workflows/R-CMD-check/badge.svg)](https://github.com/r-tidy-remote-sensing/tidyrgee/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/tidyrgee)](https://CRAN.R-project.org/package=tidyrgee)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
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

You can install the development version of tidyrgee from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("r-tidy-remote-sensing/tidyrgee")
```

It is important to note that to use tidyrgee you must bee signed up fo
GEE developer account. Additionally you must install the rgee package
following there [installation and setup instructions
here](https://github.com/r-spatial/rgee)

## Syntax Comparison

Below is a quick example demonstrating the simplified syntax. Note that
the `rgee` syntax is very similar to the syntax in the Javascript code
editor.

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

Below are a couple examples showing some of the functionality available

First you must follow standard procedures of:

-   loading libraries
-   initializing the GEE session
-   loading an `ee$ImageCollection`

``` r
library(tidyrgee)
#> 
#> Attaching package: 'tidyrgee'
#> The following object is masked from 'package:stats':
#> 
#>     filter
library(rgee)
#> 
#> Attaching package: 'rgee'
#> The following object is masked from 'package:tidyrgee':
#> 
#>     ee_extract
ee_Initialize()
#> -- rgee 1.1.2.9000 ---------------------------------- earthengine-api 0.1.295 -- 
#>  v user: not_defined
#>  v Initializing Google Earth Engine: v Initializing Google Earth Engine:  DONE!
#>  v Earth Engine account: users/zackarno 
#> --------------------------------------------------------------------------------

modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
```

Once the above steps have been performed you can convert the
`ee$ImageCollection` to a `tidyee` object with the function `as_tidyee`.
The tidyee object contains stores the original `ee$ImageCollection` and
`ee_ob` (for earth engine object) and produces as virtual
table/data.frame stored as `vrt`. This vrt allows not only facilitates
the use of dplyr/tidyverse methods, but also allows the user to better
view the data stored in the accompanying imageCollection

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

| id                           | time_start | date       | month | year | idx |
|:-----------------------------|:-----------|:-----------|------:|-----:|----:|
| MODIS/006/MOD13Q1/2000_02_18 | 2000-02-18 | 2000-02-18 |     2 | 2000 |   0 |
| MODIS/006/MOD13Q1/2000_03_05 | 2000-03-05 | 2000-03-05 |     3 | 2000 |   1 |
| MODIS/006/MOD13Q1/2000_03_21 | 2000-03-21 | 2000-03-21 |     3 | 2000 |   2 |
| MODIS/006/MOD13Q1/2000_04_06 | 2000-04-06 | 2000-04-06 |     4 | 2000 |   3 |
| MODIS/006/MOD13Q1/2000_04_22 | 2000-04-22 | 2000-04-22 |     4 | 2000 |   4 |
| MODIS/006/MOD13Q1/2000_05_08 | 2000-05-08 | 2000-05-08 |     5 | 2000 |   5 |

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
#>                              id time_start       date month year idx
#> 1  MODIS/006/MOD13Q1/2021_06_10 2021-06-10 2021-06-10     6 2021 490
#> 2  MODIS/006/MOD13Q1/2021_06_26 2021-06-26 2021-06-26     6 2021 491
#> 3  MODIS/006/MOD13Q1/2021_07_12 2021-07-12 2021-07-12     7 2021 492
#> 4  MODIS/006/MOD13Q1/2021_07_28 2021-07-28 2021-07-28     7 2021 493
#> 5  MODIS/006/MOD13Q1/2021_08_13 2021-08-13 2021-08-13     8 2021 494
#> 6  MODIS/006/MOD13Q1/2021_08_29 2021-08-29 2021-08-29     8 2021 495
#> 7  MODIS/006/MOD13Q1/2021_09_14 2021-09-14 2021-09-14     9 2021 496
#> 8  MODIS/006/MOD13Q1/2021_09_30 2021-09-30 2021-09-30     9 2021 497
#> 9  MODIS/006/MOD13Q1/2021_10_16 2021-10-16 2021-10-16    10 2021 498
#> 10 MODIS/006/MOD13Q1/2021_11_01 2021-11-01 2021-11-01    11 2021 499
#> 11 MODIS/006/MOD13Q1/2021_11_17 2021-11-17 2021-11-17    11 2021 500
#> 12 MODIS/006/MOD13Q1/2021_12_03 2021-12-03 2021-12-03    12 2021 501
#> 13 MODIS/006/MOD13Q1/2021_12_19 2021-12-19 2021-12-19    12 2021 502
#> 14 MODIS/006/MOD13Q1/2022_01_01 2022-01-01 2022-01-01     1 2022 503
#> 15 MODIS/006/MOD13Q1/2022_01_17 2022-01-17 2022-01-17     1 2022 504
#> 16 MODIS/006/MOD13Q1/2022_02_02 2022-02-02 2022-02-02     2 2022 505
#> 17 MODIS/006/MOD13Q1/2022_02_18 2022-02-18 2022-02-18     2 2022 506
#> 18 MODIS/006/MOD13Q1/2022_03_06 2022-03-06 2022-03-06     3 2022 507
#> 19 MODIS/006/MOD13Q1/2022_03_22 2022-03-22 2022-03-22     3 2022 508
#> 20 MODIS/006/MOD13Q1/2022_04_07 2022-04-07 2022-04-07     4 2022 509
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
#>                              id time_start       date month year idx
#> 1  MODIS/006/MOD13Q1/2010_01_01 2010-01-01 2010-01-01     1 2010 227
#> 2  MODIS/006/MOD13Q1/2010_01_17 2010-01-17 2010-01-17     1 2010 228
#> 3  MODIS/006/MOD13Q1/2010_02_02 2010-02-02 2010-02-02     2 2010 229
#> 4  MODIS/006/MOD13Q1/2010_02_18 2010-02-18 2010-02-18     2 2010 230
#> 5  MODIS/006/MOD13Q1/2010_03_06 2010-03-06 2010-03-06     3 2010 231
#> 6  MODIS/006/MOD13Q1/2010_03_22 2010-03-22 2010-03-22     3 2010 232
#> 7  MODIS/006/MOD13Q1/2010_04_07 2010-04-07 2010-04-07     4 2010 233
#> 8  MODIS/006/MOD13Q1/2010_04_23 2010-04-23 2010-04-23     4 2010 234
#> 9  MODIS/006/MOD13Q1/2010_05_09 2010-05-09 2010-05-09     5 2010 235
#> 10 MODIS/006/MOD13Q1/2010_05_25 2010-05-25 2010-05-25     5 2010 236
#> 11 MODIS/006/MOD13Q1/2010_06_10 2010-06-10 2010-06-10     6 2010 237
#> 12 MODIS/006/MOD13Q1/2010_06_26 2010-06-26 2010-06-26     6 2010 238
#> 13 MODIS/006/MOD13Q1/2010_07_12 2010-07-12 2010-07-12     7 2010 239
#> 14 MODIS/006/MOD13Q1/2010_07_28 2010-07-28 2010-07-28     7 2010 240
#> 15 MODIS/006/MOD13Q1/2010_08_13 2010-08-13 2010-08-13     8 2010 241
#> 16 MODIS/006/MOD13Q1/2010_08_29 2010-08-29 2010-08-29     8 2010 242
#> 17 MODIS/006/MOD13Q1/2010_09_14 2010-09-14 2010-09-14     9 2010 243
#> 18 MODIS/006/MOD13Q1/2010_09_30 2010-09-30 2010-09-30     9 2010 244
#> 19 MODIS/006/MOD13Q1/2010_10_16 2010-10-16 2010-10-16    10 2010 245
#> 20 MODIS/006/MOD13Q1/2010_11_01 2010-11-01 2010-11-01    11 2010 246
#> 21 MODIS/006/MOD13Q1/2010_11_17 2010-11-17 2010-11-17    11 2010 247
#> 22 MODIS/006/MOD13Q1/2010_12_03 2010-12-03 2010-12-03    12 2010 248
#> 23 MODIS/006/MOD13Q1/2010_12_19 2010-12-19 2010-12-19    12 2010 249
#> 24 MODIS/006/MOD13Q1/2011_01_01 2011-01-01 2011-01-01     1 2011 250
#> 25 MODIS/006/MOD13Q1/2011_01_17 2011-01-17 2011-01-17     1 2011 251
#> 26 MODIS/006/MOD13Q1/2011_02_02 2011-02-02 2011-02-02     2 2011 252
#> 27 MODIS/006/MOD13Q1/2011_02_18 2011-02-18 2011-02-18     2 2011 253
#> 28 MODIS/006/MOD13Q1/2011_03_06 2011-03-06 2011-03-06     3 2011 254
#> 29 MODIS/006/MOD13Q1/2011_03_22 2011-03-22 2011-03-22     3 2011 255
#> 30 MODIS/006/MOD13Q1/2011_04_07 2011-04-07 2011-04-07     4 2011 256
#> 31 MODIS/006/MOD13Q1/2011_04_23 2011-04-23 2011-04-23     4 2011 257
#> 32 MODIS/006/MOD13Q1/2011_05_09 2011-05-09 2011-05-09     5 2011 258
#> 33 MODIS/006/MOD13Q1/2011_05_25 2011-05-25 2011-05-25     5 2011 259
#> 34 MODIS/006/MOD13Q1/2011_06_10 2011-06-10 2011-06-10     6 2011 260
#> 35 MODIS/006/MOD13Q1/2011_06_26 2011-06-26 2011-06-26     6 2011 261
#> 36 MODIS/006/MOD13Q1/2011_07_12 2011-07-12 2011-07-12     7 2011 262
#> 37 MODIS/006/MOD13Q1/2011_07_28 2011-07-28 2011-07-28     7 2011 263
#> 38 MODIS/006/MOD13Q1/2011_08_13 2011-08-13 2011-08-13     8 2011 264
#> 39 MODIS/006/MOD13Q1/2011_08_29 2011-08-29 2011-08-29     8 2011 265
#> 40 MODIS/006/MOD13Q1/2011_09_14 2011-09-14 2011-09-14     9 2011 266
#> 41 MODIS/006/MOD13Q1/2011_09_30 2011-09-30 2011-09-30     9 2011 267
#> 42 MODIS/006/MOD13Q1/2011_10_16 2011-10-16 2011-10-16    10 2011 268
#> 43 MODIS/006/MOD13Q1/2011_11_01 2011-11-01 2011-11-01    11 2011 269
#> 44 MODIS/006/MOD13Q1/2011_11_17 2011-11-17 2011-11-17    11 2011 270
#> 45 MODIS/006/MOD13Q1/2011_12_03 2011-12-03 2011-12-03    12 2011 271
#> 46 MODIS/006/MOD13Q1/2011_12_19 2011-12-19 2011-12-19    12 2011 272
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
#>                              id time_start       date month year idx
#> 1  MODIS/006/MOD13Q1/2000_07_11 2000-07-11 2000-07-11     7 2000   9
#> 2  MODIS/006/MOD13Q1/2000_07_27 2000-07-27 2000-07-27     7 2000  10
#> 3  MODIS/006/MOD13Q1/2000_08_12 2000-08-12 2000-08-12     8 2000  11
#> 4  MODIS/006/MOD13Q1/2000_08_28 2000-08-28 2000-08-28     8 2000  12
#> 5  MODIS/006/MOD13Q1/2001_07_12 2001-07-12 2001-07-12     7 2001  32
#> 6  MODIS/006/MOD13Q1/2001_07_28 2001-07-28 2001-07-28     7 2001  33
#> 7  MODIS/006/MOD13Q1/2001_08_13 2001-08-13 2001-08-13     8 2001  34
#> 8  MODIS/006/MOD13Q1/2001_08_29 2001-08-29 2001-08-29     8 2001  35
#> 9  MODIS/006/MOD13Q1/2002_07_12 2002-07-12 2002-07-12     7 2002  55
#> 10 MODIS/006/MOD13Q1/2002_07_28 2002-07-28 2002-07-28     7 2002  56
#> 11 MODIS/006/MOD13Q1/2002_08_13 2002-08-13 2002-08-13     8 2002  57
#> 12 MODIS/006/MOD13Q1/2002_08_29 2002-08-29 2002-08-29     8 2002  58
#> 13 MODIS/006/MOD13Q1/2003_07_12 2003-07-12 2003-07-12     7 2003  78
#> 14 MODIS/006/MOD13Q1/2003_07_28 2003-07-28 2003-07-28     7 2003  79
#> 15 MODIS/006/MOD13Q1/2003_08_13 2003-08-13 2003-08-13     8 2003  80
#> 16 MODIS/006/MOD13Q1/2003_08_29 2003-08-29 2003-08-29     8 2003  81
#> 17 MODIS/006/MOD13Q1/2004_07_11 2004-07-11 2004-07-11     7 2004 101
#> 18 MODIS/006/MOD13Q1/2004_07_27 2004-07-27 2004-07-27     7 2004 102
#> 19 MODIS/006/MOD13Q1/2004_08_12 2004-08-12 2004-08-12     8 2004 103
#> 20 MODIS/006/MOD13Q1/2004_08_28 2004-08-28 2004-08-28     8 2004 104
#> 21 MODIS/006/MOD13Q1/2005_07_12 2005-07-12 2005-07-12     7 2005 124
#> 22 MODIS/006/MOD13Q1/2005_07_28 2005-07-28 2005-07-28     7 2005 125
#> 23 MODIS/006/MOD13Q1/2005_08_13 2005-08-13 2005-08-13     8 2005 126
#> 24 MODIS/006/MOD13Q1/2005_08_29 2005-08-29 2005-08-29     8 2005 127
#> 25 MODIS/006/MOD13Q1/2006_07_12 2006-07-12 2006-07-12     7 2006 147
#> 26 MODIS/006/MOD13Q1/2006_07_28 2006-07-28 2006-07-28     7 2006 148
#> 27 MODIS/006/MOD13Q1/2006_08_13 2006-08-13 2006-08-13     8 2006 149
#> 28 MODIS/006/MOD13Q1/2006_08_29 2006-08-29 2006-08-29     8 2006 150
#> 29 MODIS/006/MOD13Q1/2007_07_12 2007-07-12 2007-07-12     7 2007 170
#> 30 MODIS/006/MOD13Q1/2007_07_28 2007-07-28 2007-07-28     7 2007 171
#> 31 MODIS/006/MOD13Q1/2007_08_13 2007-08-13 2007-08-13     8 2007 172
#> 32 MODIS/006/MOD13Q1/2007_08_29 2007-08-29 2007-08-29     8 2007 173
#> 33 MODIS/006/MOD13Q1/2008_07_11 2008-07-11 2008-07-11     7 2008 193
#> 34 MODIS/006/MOD13Q1/2008_07_27 2008-07-27 2008-07-27     7 2008 194
#> 35 MODIS/006/MOD13Q1/2008_08_12 2008-08-12 2008-08-12     8 2008 195
#> 36 MODIS/006/MOD13Q1/2008_08_28 2008-08-28 2008-08-28     8 2008 196
#> 37 MODIS/006/MOD13Q1/2009_07_12 2009-07-12 2009-07-12     7 2009 216
#> 38 MODIS/006/MOD13Q1/2009_07_28 2009-07-28 2009-07-28     7 2009 217
#> 39 MODIS/006/MOD13Q1/2009_08_13 2009-08-13 2009-08-13     8 2009 218
#> 40 MODIS/006/MOD13Q1/2009_08_29 2009-08-29 2009-08-29     8 2009 219
#> 41 MODIS/006/MOD13Q1/2010_07_12 2010-07-12 2010-07-12     7 2010 239
#> 42 MODIS/006/MOD13Q1/2010_07_28 2010-07-28 2010-07-28     7 2010 240
#> 43 MODIS/006/MOD13Q1/2010_08_13 2010-08-13 2010-08-13     8 2010 241
#> 44 MODIS/006/MOD13Q1/2010_08_29 2010-08-29 2010-08-29     8 2010 242
#> 45 MODIS/006/MOD13Q1/2011_07_12 2011-07-12 2011-07-12     7 2011 262
#> 46 MODIS/006/MOD13Q1/2011_07_28 2011-07-28 2011-07-28     7 2011 263
#> 47 MODIS/006/MOD13Q1/2011_08_13 2011-08-13 2011-08-13     8 2011 264
#> 48 MODIS/006/MOD13Q1/2011_08_29 2011-08-29 2011-08-29     8 2011 265
#> 49 MODIS/006/MOD13Q1/2012_07_11 2012-07-11 2012-07-11     7 2012 285
#> 50 MODIS/006/MOD13Q1/2012_07_27 2012-07-27 2012-07-27     7 2012 286
#> 51 MODIS/006/MOD13Q1/2012_08_12 2012-08-12 2012-08-12     8 2012 287
#> 52 MODIS/006/MOD13Q1/2012_08_28 2012-08-28 2012-08-28     8 2012 288
#> 53 MODIS/006/MOD13Q1/2013_07_12 2013-07-12 2013-07-12     7 2013 308
#> 54 MODIS/006/MOD13Q1/2013_07_28 2013-07-28 2013-07-28     7 2013 309
#> 55 MODIS/006/MOD13Q1/2013_08_13 2013-08-13 2013-08-13     8 2013 310
#> 56 MODIS/006/MOD13Q1/2013_08_29 2013-08-29 2013-08-29     8 2013 311
#> 57 MODIS/006/MOD13Q1/2014_07_12 2014-07-12 2014-07-12     7 2014 331
#> 58 MODIS/006/MOD13Q1/2014_07_28 2014-07-28 2014-07-28     7 2014 332
#> 59 MODIS/006/MOD13Q1/2014_08_13 2014-08-13 2014-08-13     8 2014 333
#> 60 MODIS/006/MOD13Q1/2014_08_29 2014-08-29 2014-08-29     8 2014 334
#> 61 MODIS/006/MOD13Q1/2015_07_12 2015-07-12 2015-07-12     7 2015 354
#> 62 MODIS/006/MOD13Q1/2015_07_28 2015-07-28 2015-07-28     7 2015 355
#> 63 MODIS/006/MOD13Q1/2015_08_13 2015-08-13 2015-08-13     8 2015 356
#> 64 MODIS/006/MOD13Q1/2015_08_29 2015-08-29 2015-08-29     8 2015 357
#> 65 MODIS/006/MOD13Q1/2016_07_11 2016-07-11 2016-07-11     7 2016 377
#> 66 MODIS/006/MOD13Q1/2016_07_27 2016-07-27 2016-07-27     7 2016 378
#> 67 MODIS/006/MOD13Q1/2016_08_12 2016-08-12 2016-08-12     8 2016 379
#> 68 MODIS/006/MOD13Q1/2016_08_28 2016-08-28 2016-08-28     8 2016 380
#> 69 MODIS/006/MOD13Q1/2017_07_12 2017-07-12 2017-07-12     7 2017 400
#> 70 MODIS/006/MOD13Q1/2017_07_28 2017-07-28 2017-07-28     7 2017 401
#> 71 MODIS/006/MOD13Q1/2017_08_13 2017-08-13 2017-08-13     8 2017 402
#> 72 MODIS/006/MOD13Q1/2017_08_29 2017-08-29 2017-08-29     8 2017 403
#> 73 MODIS/006/MOD13Q1/2018_07_12 2018-07-12 2018-07-12     7 2018 423
#> 74 MODIS/006/MOD13Q1/2018_07_28 2018-07-28 2018-07-28     7 2018 424
#> 75 MODIS/006/MOD13Q1/2018_08_13 2018-08-13 2018-08-13     8 2018 425
#> 76 MODIS/006/MOD13Q1/2018_08_29 2018-08-29 2018-08-29     8 2018 426
#> 77 MODIS/006/MOD13Q1/2019_07_12 2019-07-12 2019-07-12     7 2019 446
#> 78 MODIS/006/MOD13Q1/2019_07_28 2019-07-28 2019-07-28     7 2019 447
#> 79 MODIS/006/MOD13Q1/2019_08_13 2019-08-13 2019-08-13     8 2019 448
#> 80 MODIS/006/MOD13Q1/2019_08_29 2019-08-29 2019-08-29     8 2019 449
#> 81 MODIS/006/MOD13Q1/2020_07_11 2020-07-11 2020-07-11     7 2020 469
#> 82 MODIS/006/MOD13Q1/2020_07_27 2020-07-27 2020-07-27     7 2020 470
#> 83 MODIS/006/MOD13Q1/2020_08_12 2020-08-12 2020-08-12     8 2020 471
#> 84 MODIS/006/MOD13Q1/2020_08_28 2020-08-28 2020-08-28     8 2020 472
#> 85 MODIS/006/MOD13Q1/2021_07_12 2021-07-12 2021-07-12     7 2021 492
#> 86 MODIS/006/MOD13Q1/2021_07_28 2021-07-28 2021-07-28     7 2021 493
#> 87 MODIS/006/MOD13Q1/2021_08_13 2021-08-13 2021-08-13     8 2021 494
#> 88 MODIS/006/MOD13Q1/2021_08_29 2021-08-29 2021-08-29     8 2021 495
#> 
#> attr(,"class")
#> [1] "tidyee"
```

### Putting a dplyr-like chain together:

In this next example we pipe together multiple functions (`select`,
`filter`, `group_by`, `summarise`) to

1.  select the `NDVI` band from the ImageCollection
2.  filter the imageCollection to a desired date range
3.  grouping the filtered ImageCollection by month
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
#> # A tibble: 12 x 2
#>    month dates_summarised
#>    <dbl> <list>          
#>  1     1 <dttm [30]>     
#>  2     2 <dttm [31]>     
#>  3     3 <dttm [32]>     
#>  4     4 <dttm [32]>     
#>  5     5 <dttm [32]>     
#>  6     6 <dttm [32]>     
#>  7     7 <dttm [32]>     
#>  8     8 <dttm [32]>     
#>  9     9 <dttm [32]>     
#> 10    10 <dttm [20]>     
#> 11    11 <dttm [28]>     
#> 12    12 <dttm [32]>     
#> 
#> attr(,"class")
#> [1] "tidyee"
```

You can easily `group_by` more than 1 property to calculate different
summary stats. Below we

1.  filter to only data from 2021-2022
2.  group by year, month and calculate the median NDVI pixel value

As we are using the MODIS 16-day composite we summarising approximate 2
images per month to create median composite image fo reach month in the
specified years. The `vrt` holds a `list-col` containing all the dates
summarised per new composite image.

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
#> # A tibble: 16 x 3
#>     year month dates_summarised
#>    <dbl> <dbl> <list>          
#>  1  2021     1 <dttm [2]>      
#>  2  2021     2 <dttm [2]>      
#>  3  2021     3 <dttm [2]>      
#>  4  2021     4 <dttm [2]>      
#>  5  2021     5 <dttm [2]>      
#>  6  2021     6 <dttm [2]>      
#>  7  2021     7 <dttm [2]>      
#>  8  2021     8 <dttm [2]>      
#>  9  2021     9 <dttm [2]>      
#> 10  2021    10 <dttm [1]>      
#> 11  2021    11 <dttm [2]>      
#> 12  2021    12 <dttm [2]>      
#> 13  2022     1 <dttm [2]>      
#> 14  2022     2 <dttm [2]>      
#> 15  2022     3 <dttm [2]>      
#> 16  2022     4 <dttm [1]>      
#> 
#> attr(,"class")
#> [1] "tidyee"
```

To improve enhance backward compatibility with `rgee` we have included
the `as_ee` function to return the `tidyee` object back to `rgee`
classes where/if necessary

``` r
modis_ic <- modis_tidy |> as_ee()
```
