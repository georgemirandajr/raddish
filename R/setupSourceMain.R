require(rstudioapi)

setupSourceMain = function() {
  rstudioapi::insertText(
    "source( paste0(data_path, 'main.R') )"
  )
}
