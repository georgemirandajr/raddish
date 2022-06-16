library(shiny)
library(miniUI)
require(rstudioapi)
library(shinycssloaders)
library(data.table)
library(purrr)

employee_list_at <- function( df, date = Sys.Date(),
                              sub_list = c("A", "D", "L", "N"),
                              filter_list = NULL ) {

  df = df[ EFFECTIVE_DT <= date &
             EXPIRATION_DT >= date ]

  df = df[, .SD[.N], by = EMPLOYEE_ID]

  df = df[ EMPLMT_STA_CD %chin% c("A") &
             !HOME_DEPT_CD %chin% c("GJ", "NL", "SC") ]

  if ( !is.null( sub_list) ) {
    df = df[ SUB_TITLE_CD %chin% sub_list ]
  }

  if ( !is.null( filter_list ) ) {
    df = df[ eval( parse( text = filter_list ) ) ]
  }

  return( df )
}

all_choices = list(
  ft = c( 'A', 'D', 'L', 'N' ),
  pt = c( LETTERS[16:26] ),
  temp = c( c('B', 'C', 'E', 'F', 'G', 'J', 'H', 'M', 'O'),
            paste0( c('B', 'C', 'E', 'F', 'G', 'J', 'H', 'M', 'O' ), 'R' ) )
)

list_emps = function() {

  ui <- miniPage(
    gadgetTitleBar("DHR Analytics"),
    miniContentPanel(

      # Explain what will happen
      helpText("Select the JPACT data:"),
      uiOutput("data_input"),
      checkboxGroupInput("emp_type_input", "Employment Type",
                         selected = "ft",
                         inline = TRUE,
                         choiceNames = c("Full-Time Permanent",
                                         "Part-Time Permanent",
                                         "Temporary"),
                         choiceValues = c("ft", "pt", "temp") ),
      dateInput("date_selected", "Active on This Date", value = Sys.Date(),
                min = "2012-04-01", max = Sys.Date(), format = "mm-dd-yyyy"),
      actionButton("apply_filters", "Apply Filters")
    )
  )

  server <- function(input, output, session) {

    output$data_input <- renderUI({

      my_objs = ls( envir = .GlobalEnv )
      my_objs_df = unlist( my_objs %>% purrr::map( ~ is.data.frame( eval( parse( text = .x ) ) ) ) )
      my_objs = my_objs[ my_objs_df ]

      selectInput("tbl_selected", "",
                  choices = my_objs )

    })

    subs_in <- reactive({

      selected_subs = unlist( all_choices[ input$emp_type_input ], use.names = FALSE )

      selected_subs

    })

    observeEvent( input$apply_filters, {

      columnNames = names( get(input$tbl_selected, envir = .GlobalEnv) )
      colsNeeded = c("EFFECTIVE_DT", "EXPIRATION_DT", "EMPLOYEE_ID",
                     "EMPLMT_STA_CD", "HOME_DEPT_CD", "SUB_TITLE_CD" )

      if ( all( colsNeeded %in% columnNames ) ) {

        out_data = employee_list_at(
          get( input$tbl_selected, envir = .GlobalEnv  ),
          date = input$date_selected,
          sub_list = subs_in()
        )

        assign( paste0( input$tbl_selected, "_copy" ), value = out_data, pos = 1, envir = globalenv() )

        showModal(
          modalDialog( title = "Success!",
                       h4("Your data is ready. You can close this app now.") )
        )

      } else {
        showModal(
          modalDialog( title = "JPACT Needed",
                       p("You need to use the JPACT dataset with columns"),
                       tags$ul(
                         tags$li("EFFECTIVE_DT"),
                         tags$li("EXPIRATION_DT"),
                         tags$li("EMPLOYEE_ID"),
                         tags$li("EMPLMT_STA_CD"),
                         tags$li("HOME_DEPT_CD"),
                         tags$li("SUB_TITLE_CD")
                       )
          )
        )

      }

    })

    # Listen for the 'done' event.
    observeEvent(input$done, {
      stopApp( paste0( input$tbl_selected, "_copy" ) )
    })
  }

  # We'll use a dialog viwer
  viewer <- shiny::browserViewer()

  runGadget(ui, server, viewer = viewer)

}

# Call the addin
# list_emps()
