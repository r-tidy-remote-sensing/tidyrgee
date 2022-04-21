
# Document functions and dependencies
attachment::att_to_description()
# Check the package
devtools::check()




usethis::use_build_ignore("dev_history.R")

# data set is a 2019 host community Multi-Sectoral Needs Assessment from Bangladesh.
# All coordinate have been pre-processed with `st_jitter`
# df <- read_csv("xxxxx")

bgd_msna <- df |>
  select(`_uuid`,lon = `_gps_reading_longitude`,lat= `_gps_reading_latitude`,informed_consent,survey_date, end_survey,electricity_grid,
         solar_light,illness_HH_count,`cooking_fuel/collected_firewood`,
         `income_source/agricultural_production_sale`  ,
         agricultural_land ,
         `employment_source/agricultural_casual`,
         `employment_source/non_agricultural_casual`,
         `employment_source/fishing` ) |>
  filter(informed_consent=="yes")
usethis::use_data(bgd_msna,overwrite=T)
# usethis::use_git_ignore("data/dat.rda")
# usethis::use_mit_license()
