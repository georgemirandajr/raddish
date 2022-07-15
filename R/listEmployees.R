require(shiny)
require(miniUI)
require(rstudioapi)
require(shinycssloaders)
require(purrr)

list_emps = function() {

  employee_list_at <- function( df, date = Sys.Date(),
                                sub_list = c("A", "D", "L", "N"),
                                filter_list = NULL ) {

    require(data.table)

    if ( !data.table::is.data.table( df ) ) {
      df = data.table::data.table( df )
    }

    df = df[ get('EFFECTIVE_DT') <= date &
               get('EXPIRATION_DT') >= date ]

    df = df[, .SD[.N], by = get('EMPLOYEE_ID')]

    df = df[ get('EMPLMT_STA_CD') %chin% c("A") &
               !get('HOME_DEPT_CD') %chin% c("GJ", "NL", "SC") ]

    if ( !is.null( sub_list) ) {
      df = df[ get('SUB_TITLE_CD') %chin% sub_list ]
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

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("DHR Analytics"),
    miniUI::miniContentPanel(

      # Explain what will happen
      shiny::helpText("Select the JPACT data:"),
      shiny::uiOutput("data_input"),
      shiny::checkboxGroupInput("emp_type_input", "Employment Type",
                         selected = "ft",
                         inline = TRUE,
                         choiceNames = c("Full-Time Permanent",
                                         "Part-Time Permanent",
                                         "Temporary"),
                         choiceValues = c("ft", "pt", "temp") ),
      shiny::dateInput("date_selected", "Active on This Date", value = Sys.Date(),
                min = "2012-04-01", max = Sys.Date(), format = "mm-dd-yyyy"),
      shiny::actionButton("apply_filters", "Apply Filters")
    )
  )

  server <- function(input, output, session) {

    output$data_input <- shiny::renderUI({

      my_objs = ls( envir = .GlobalEnv )
      my_objs_df = unlist( purrr::map(my_objs, ~ is.data.frame( eval( parse( text = .x ) ) ) ) )
      my_objs = my_objs[ my_objs_df ]

      shiny::selectInput("tbl_selected", "",
                  choices = my_objs )

    })

    subs_in <- shiny::reactive({

      selected_subs = unlist( all_choices[ input$emp_type_input ], use.names = FALSE )

      selected_subs

    })

    shiny::observeEvent( input$apply_filters, {

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

        shiny::showModal(
          shiny::modalDialog( title = "Success!",
                       h4("Your data is ready. You can close this app now.") )
        )

      } else {
        shiny::showModal(
          shiny::modalDialog( title = "JPACT Needed",
                       shiny::p("You need to use the JPACT dataset with columns"),
                       shiny::tags$ul(
                         shiny::tags$li("EFFECTIVE_DT"),
                         shiny::tags$li("EXPIRATION_DT"),
                         shiny::tags$li("EMPLOYEE_ID"),
                         shiny::tags$li("EMPLMT_STA_CD"),
                         shiny::tags$li("HOME_DEPT_CD"),
                         shiny::tags$li("SUB_TITLE_CD")
                       )
          )
        )

      }

    })

    # Listen for the 'done' event.
    shiny::observeEvent(input$done, {
      shiny::stopApp( paste0( input$tbl_selected, "_copy" ) )
    })
  }

  # We'll use a dialog viwer
  viewer <- shiny::browserViewer()

  shiny::runGadget(ui, server, viewer = viewer)

}

# Call the addin
# list_emps()
