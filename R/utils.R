
#' @export
isErrorMessage <- function(object) {
  inherits(object, "error_message")
}

#' @export
errorMessage <- function(type, message) {
  structure(
    list(type = type, message = message),
    class = "error_message"
  )
}

#' @export
stableColumnLayout <- function(...) {
  dots <- list(...)
  n <- length(dots)
  width <- 12 / n
  class <- sprintf("col-xs-%s col-md-%s", width, width)
  shiny::fluidRow(
    lapply(dots, function(el) {
      div(class = class, el)
    })
  )
}

#' @export
myFilter <- function( df, sub_list ) {
  df %>%
    group_by( EMPLOYEE_ID ) %>%
    dplyr::filter( SUB_TITLE_CD %in% sub_list &
                     EMPLMT_STA_CD %in% c("A") &
                     !HOME_DEPT_CD %in% c("GJ", "NL", "SC") )
}


