require(rstudioapi)
readJpactDate = function() {
  rstudioapi::insertText(
    "# Read jpact date
    if ( !exists('jpact_date') ) {
    jpact_date = readRDS( paste0( data_path, 'jpact_file_date.rds') )
    }"
  )
}
