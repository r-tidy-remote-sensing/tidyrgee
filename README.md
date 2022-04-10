
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidyrgee

<!-- badges: start -->

[![R-CMD-check](https://github.com/r-tidy-remote-sensing/tidyrgee/workflows/R-CMD-check/badge.svg)](https://github.com/r-tidy-remote-sensing/tidyrgee/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/tidyrgee)](https://CRAN.R-project.org/package=tidyrgee)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of tidyrgee is to create tidyverse style methods (filter,
group_by, summarise, etc) for Google Earth Engine (GEE) Images and
ImageCollections.

## Installation

You can install the development version of tidyrgee from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("r-tidy-remote-sensing/tidyrgee")
```

## Example

This is a basic example which shows you how to solve a common problem:
filter an ImageCollection by date and then group by year and month and
then take the mean.

``` r
## load rgee and initialize GEE auth.
# library(rgee)
# ee_Initialize()
# 
# library(tidyrgee)
```
