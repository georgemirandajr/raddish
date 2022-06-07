createProject <- function(path, projectName, ...) {

  # Create a folder for the project
  dir.create( paste0( path, "/", projectName) )

  # Create the sub-folders
  subFolderNames = c('data', 'output', 'code', 'utils', 'www')
  subFolderNames = path.expand( paste0( path, "/", projectName, "/", subFolderNames) )
  sapply( subFolderNames, dir.create )

  # Copy the report template
  f = system.file("extdata", "Report_Template.Rmd", package = "raddish" )

  if ( nchar(f) > 0 ) {
    file.copy( from = f, to = paste0( path, "/", projectName) )
  }

  # Copy the global.R file
  g = system.file("extdata", "global.R", package = "raddish" )

  if ( nchar(g) > 0 ) {
    file.copy( from = g, to = paste0( path, "/", projectName, "/code"))
  }

}
