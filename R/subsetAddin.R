#' Subset a Data Frame.
#'
#' Interactively subset a \code{data.frame}. The resulting
#' code will be emitted as a call to the \code{\link{subset}}
#' function.
#'
#' This addin can be used to interactively subset a \code{data.frame}.
#' The intended way to use this is as follows:
#'
#' 1. Highlight a symbol naming a \code{data.frame} in your R session,
#'    e.g. \code{mtcars},
#' 2. Execute this addin, to interactively subset it.
#'
#' When you're done, the code performing this operation will be emitted
#' at the cursor position.
#'
#' @export
subsetAddin <- function() {

  all_choices = list(
    ft = c( 'A', 'D', 'L', 'N' ),
    pt = c( LETTERS[ 16:26 ] ),
    temp = c( c( 'B', 'C', 'E', 'F', 'G', 'J', 'H', 'M', 'O' ),
              paste0( c( 'B', 'C', 'E', 'F', 'G', 'J', 'H', 'M', 'O' ), 'R' ) )
  )

  # Get the document context.
  context <- rstudioapi::getActiveDocumentContext()

  # Set the default data to use based on the selection.
  text <- context$selection[[1]]$text
  defaultData <- text

  # Generate UI for the gadget.
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("Filter the JPACT Data"),
    miniUI::miniContentPanel(
      stableColumnLayout(
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
        shiny::uiOutput("grouping"),
        shiny::actionButton("apply_filters", "Apply Filters")
        # shiny::textInput("subset", "Subset Expression")
      ),
      shiny::uiOutput("pending"),
      shiny::dataTableOutput("output")
    )
  )


  # Server code for the gadget.
  server <- function(input, output, session) {

    output$data_input <- shiny::renderUI({

      my_objs = ls( envir = .GlobalEnv )
      my_objs_df = unlist( purrr::map(my_objs, ~ is.data.frame( eval( parse( text = .x ) ) ) ) )
      my_objs = my_objs[ my_objs_df ]

      shiny::selectInput("data", "",
                         choices = my_objs )

    })

    output$grouping <- shiny::renderUI({
      d <- get( input$data, envir = .GlobalEnv )
      grp_vars <- names( d )

      shiny::selectInput( "grpVarInput", label = "Group Results",
                          choices = grp_vars, multiple = TRUE )
    })

    reactiveData <- shiny::eventReactive( input$apply_filters, {

      # Collect inputs.
      dataString <- input$data
      # subsetString <- input$subset
      date_picked <- input$date_selected
      selected_subs <- unlist( all_choices[ input$emp_type_input ], use.names = FALSE )

      if (!exists(dataString, envir = .GlobalEnv))
        return(errorMessage("data", paste("No dataset named '", dataString, "' available.")))

      data <- get(dataString, envir = .GlobalEnv)

      # if (!nzchar(subsetString))
      #   return(data)

      # Try evaluating the subset expression within the data.
      # condition <- try(parse(text = subsetString)[[1]], silent = TRUE)
      # if (inherits(condition, "try-error"))
      #   return(errorMessage("expression", paste("Failed to parse expression '", subsetString, "'.")))

      filter_list <- NULL

      call <- as.call(
        list(
          as.name("raddish::employee_list_at"),
          data,
          date = date_picked,
          sub_list = selected_subs,
          filter_list,
          grp = input$grpVarInput
        )
      )

      out_data <- eval( call, envir = .GlobalEnv )
      out_data

      assign( paste0( input$data, "_copy" ), value = out_data, pos = 1, envir = globalenv() )
    })

    output$pending <- shiny::renderUI({
      data <- reactiveData()
      if (isErrorMessage(data))
        h4(style = "color: #AA7732;", data$message)
    })

    output$output <- shiny::renderDataTable({
      data <- reactiveData()
      if (isErrorMessage(data))
        return(NULL)
      data
    })

    # Listen for 'done'.
    shiny::observeEvent(input$done, {

      # Emit a subset call if a dataset has been specified.
      # if (nzchar(input$data) && nzchar(input$subset)) {
      #   code <- paste("subset(", input$data, ", ", input$subset, ")", sep = "")
      #   rstudioapi::insertText(text = code)
      # }
      assign( paste0( input$data, "_copy" ), value = reactiveData(), pos = 1, envir = globalenv() )

      invisible( stopApp() )
    })
  }

  # Use a modal dialog as a viewr.
  viewer <- shiny::dialogViewer("Subset", width = 1000, height = 800)
  shiny::runGadget(ui, server, viewer = viewer)

}
