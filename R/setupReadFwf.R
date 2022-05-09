require(rstudioapi)
setupReadFwf = function() {
  rstudioapi::insertText(
    "data = setDT(readr::read_fwf( fname,
                                progress = FALSE,
                                col_types = paste(rep('c', length( specs$FieldName ) ), collapse = ''),
                                fwf_positions( specs$Start,
                                               specs$End,
                                              col_names = specs$FieldName) ) )
  "
  )
}
