% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/group_split.R
\name{group_split}
\alias{group_split}
\title{filter ee$ImageCollections or tidyee objects that contain imageCollections}
\arguments{
\item{.tbl}{ImageCollection or tidyee class object}

\item{...}{other arguments}

\item{return_tidyee}{\code{logical} return tidyee object(default =T), if FALSE - only return ee$ImageCollection}
}
\value{
filtered image or imageCollection form filtered imageCollection
}
\description{
filter ee$ImageCollections or tidyee objects that contain imageCollections
}
\examples{
\dontrun{

library(rgee)
library(tidyrgee)
ee_Initialize()
l8 = ee$ImageCollection('LANDSAT/LC08/C01/T1_SR')
l8 |>
    filter(date>"2016-01-01",date<"2016-03-04")


 # example with tidyee ckass
modis_ic <- ee$ImageCollection("MODIS/006/MOD13Q1")
modis_ic_tidy <- as_tidyee(modis_ic)

# filter by month
modis_march_april <- modis_ic_tidy |>
filter(month \%in\% c(3,4))
}
}
\seealso{
\code{\link[dplyr]{group_split}} for information about filter on normal data tables.
}
