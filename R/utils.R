isErrorMessage <- function(object) {
  inherits(object, "error_message")
}

errorMessage <- function(type, message) {
  structure(
    list(type = type, message = message),
    class = "error_message"
  )
}

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

myFilter <- function( df, sub_list ) {
  df %>%
    group_by( EMPLOYEE_ID ) %>%
    dplyr::filter( SUB_TITLE_CD %in% sub_list &
                     EMPLMT_STA_CD %in% c("A") &
                     !HOME_DEPT_CD %in% c("GJ", "NL", "SC") )
}


employee_list_at <- function( df, date = Sys.Date(),
                              sub_list = c("A", "D", "L", "N"),
                              filter_list = NULL,
                              grp = NULL
                              ) {

  require(data.table)

  if ( !data.table::is.data.table( df ) ) {
    df = data.table::data.table( df )
  }

  df = data.table:::`[.data.table`( df, i = is.na( APPOINTMENT_ID )  )

  df = data.table:::`[.data.table`( df, i = EFFECTIVE_DT <= date & EXPIRATION_DT >= date  )

  df = data.table:::`[.data.table`( df, j = .SD[.N] , by = "EMPLOYEE_ID"  )

  df = data.table:::`[.data.table`( df,
                                    i = EMPLMT_STA_CD %chin% c("A") &
                                      !HOME_DEPT_CD %chin% c("GJ", "NL", "SC")
  )

  if ( !is.null( sub_list) ) {
    df = data.table:::`[.data.table`( df, i = SUB_TITLE_CD %chin% sub_list  )
  }

  if ( !is.null( filter_list ) ) {
    df = df[ eval( parse( text = filter_list ) ) ]
  }

  if ( !is.null( grp ) ) {
    df = df[, .(Count = .N), keyby = grp ]
  }

  return( df )
}
