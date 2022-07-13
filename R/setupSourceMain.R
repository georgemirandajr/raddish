require(rstudioapi)

setupSourceMain = function() {
  rstudioapi::insertText(
    "source( 'S:/Advantage Data/DHR-Analytics/code/main.R' )"
  )
}
