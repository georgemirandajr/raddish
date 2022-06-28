require(rstudioapi)

setupPackages = function() {
  rstudioapi::insertText(
    "packages <- c('readr', 'readxl', 'stringr', 'lubridate', 'data.table', 'Hmisc',
              'dplyr', 'tidyr', 'shiny', 'openxlsx', 'xts', 'DHRInternal', 'curl', 'RCurl')
     sapply(packages, require, character.only = TRUE)
     Sys.setenv('R_ZIPCMD' = 'S:/Advantage Data/DHR-Analytics/RBuildTools/3.3/bin/zip.exe')
"
  )
}
