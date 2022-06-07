
pkgs = c('data.table', 'readr')

sapply(pkgs, require, character.only = TRUE)

# Set Paths ---------------------------------------------------------------

# PATH TO YOUR PROJECT FOLDER
project_path = '//ISDOWFSV04.HOSTED.LAC.COM/D100SHARE/Advantage Data/YOUR PROJECT FOLDER PATH/'

# PATH TO JPACT SOURCE DATA
source_path = '//ISDOWFSV04.HOSTED.LAC.COM/D100SHARE/Advantage Data/DHR-Analytics/data/'

# If you want to save data to a SharePoint folder
user_root = Sys.getenv("USERPROFILE")
user_root = gsub("\\\\", "/", user_root)
# REPLACE THE PATH BELOW WITH YOUR SHAREPOINT FOLDER (must be synced to your desktop)
share_point_path = "/County of Los Angeles/Countywide Succession Planning Program - SP Profiles/Data for Report/"
share_point_path = paste0( user_root, share_point_path )

# Call Main Helper --------------------------------------------------------

# IMPORTS HELPERS TO DO THINGS LIKE CALCULATE INCUMBENTS, TURNOVER, ETC.
source( paste0( source_path,  'main.R' ) )

# Read JPACT and TAPPS data ----------------------------------------------------

if ( !exists('jpact') ) {
  jpact = readRDS( paste0( source_path, 'jpact.rds') )
}

jpact = data.table( jpact )

load( paste0( source_path, 'taps.RDS' ) )


# Call on another script that does the analysis --------------------------------

source( paste0( project_path, "code/your_script.R" ) )


# Save --------------------------------------------------------------------

# YOUR PROJECT FOLDER
readr::write_csv( ehr_emp_list, file = paste0( project_path, "output/ehr_emp_list.csv" ) )

# SOME SHAREPOINT FOLDER
readr::write_csv( ehr_emp_list, file = paste0( share_point_path, "ehr_emp_list.csv" ) )

