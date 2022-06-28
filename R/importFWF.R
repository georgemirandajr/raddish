require(shiny)
require(miniUI)
require(rstudioapi)
require(shinycssloaders)
require(data.table)
require(readr)

importFWF = function() {

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("Read an e-HR extract text file"),
    miniUI::miniContentPanel(

      # Explain what will happen
      shiny::helpText( "Choose the name of the extract file to read" ),
      shiny::uiOutput( "chooseSpec_ui" ),
      shiny::fileInput( "choose_file", "Choose a File", accept = "*.txt" ),

      shiny::helpText("Provide a name for the loaded data. It can't start with a number or contain spaces."),
      shiny::textInput("objName", ""),
      shiny::actionButton("read_file", "Read File")
    )
  )

  server <- function(input, output, session) {
    options(shiny.maxRequestSize=9000*1024^2)

    output$chooseSpec_ui <- shiny::renderUI({
      file_specs = raddish::file_specs

      shiny::selectInput("choose_spec", label = "",
                         choices = unique( file_specs$SpecName),
                         selected = "JPACT")
    })

    # User chooses to read e-HR extract text file
    shiny::observeEvent( input$read_file, {

      file <- input$choose_file

      ext <- tools::file_ext(file$datapath)

      req(file)
      validate( need( ext == "txt", "Please upload a txt file") )

      chosen_specs = raddish::file_specs[ raddish::file_specs$SpecName == input$choose_spec, ]

      data <- data.table::setDT( readr::read_fwf( file$datapath,
                                                  progress = FALSE,
                                                  col_types = paste(rep('c', length( chosen_specs$FieldName ) ), collapse = ''),
                                                  readr::fwf_positions( chosen_specs$Start,
                                                                        chosen_specs$End,
                                                                        col_names = chosen_specs$FieldName) ) )

      assign( input$objName, value = data, pos = 1, envir = globalenv() )

      shiny::showModal(
        shiny::modalDialog(
          title = "Complete",
          p(
            paste0(
              input$objName,
              " is done loading. It may take a few moments to appear in your environment."
            )
          )
        )
      )

    })

    # Listen for the 'done' event.
    shiny::observeEvent(input$done, {
      shiny::stopApp( input$objName )
    })

    shiny::observeEvent(input$cancel, {
      shiny::stopApp(NULL)
    })
  }

  # We'll use a dialog viwer
  viewer <- shiny::dialogViewer("Import Extract File")

  shiny::runGadget(ui, server, viewer = viewer)

}

# Call the addin
# importFWF()
