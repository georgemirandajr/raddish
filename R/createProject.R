createProject <- function(path, projectName, ...) {

  # Create a folder for the project
  dir.create( paste0( path, "/", projectName) )

  # Create the sub-folders
  subFolderNames = c('data', 'output', 'code', 'utils', 'www')
  subFolderNames = path.expand( paste0( path, "/", projectName, "/", subFolderNames) )
  sapply( subFolderNames, dir.create )

}
