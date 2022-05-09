require(rstudioapi)
setupDataPath = function() {
  rstudioapi::insertText("data_path = 'S:/Advantage Data/DHR-Analytics/data/'"
  )
}
