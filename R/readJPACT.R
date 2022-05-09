require(rstudioapi)
readJPACT = function() {
  rstudioapi::insertText(
    "# Read jpact data
    if ( !exists('jpact') ) {
    jpact = readRDS( paste0(data_path, 'jpact.rds') )
    }"
  )
}
