require(rstudioapi)
setupSaveRds = function() {
  rstudioapi::insertText(
    "saveRDS( robj, file = paste0(data_path, fname) )"
  )
}
