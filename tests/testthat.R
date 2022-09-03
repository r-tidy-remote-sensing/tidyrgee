library(testthat)
library(tidyrgee)
library(sf)
library(rgee)

Sys.setenv(EARTHENGINE_PYTHON="/usr/bin/python3")
Sys.setenv(RETICULATE_PYTHON="/usr/bin/python3")

# Necessary Python packages were loaded?
skip_if_no_pypkg <- function() {
  have_ee <- reticulate::py_module_available("ee")
  if (isFALSE(have_ee)) {
    skip("ee not available for testing")
  }
}


# Initialize credentials
# If you do not count with GCS credentials the test will be skipped
have_ee <- reticulate::py_module_available("ee")
if (have_ee) {
  ee_Initialize()
}

test_check("tidyrgee")
