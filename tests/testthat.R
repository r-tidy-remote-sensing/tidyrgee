library(testthat)
library(tidyrgee)
library(sf)
library(rgee)

ee_install_set_pyenv(
    py_path = '/usr/bin/python3/python.exe',
    py_env = "rgee" # Change it for your own Python ENV
  )
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
  ee_Initialize(user = "joshualerickson@gmail.com")
}

test_check("tidyrgee")
