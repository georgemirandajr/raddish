require(shiny)
require(miniUI)
require(rstudioapi)
require(shinycssloaders)

readJPACT = function() {

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("Import the processed JPACT data"),
    miniUI::miniContentPanel(

      # Explain what will happen
      shiny::helpText("Insert code in an open script that reads the processed JPACT file"),
      shiny::actionButton("insert_code", "Insert code"),

      shiny::helpText("Import the processed JPACT file to analyze."),
      shiny::helpText("This may take 1-2 minutes."),
      shiny::actionButton("read_jpact", "Import data"),

    )
  )

  server <- function(input, output, session) {

    shiny::observeEvent( input$insert_code, {
      code_readJPACT = rstudioapi::insertText(
        "# Read jpact data
    if ( !exists('jpact') ) {
    jpact = readRDS( paste0(data_path, 'jpact.rds') )
    }"
      )
    })

    # User chooses to read jpact
    shiny::observeEvent( input$read_jpact, {

      jpact <<- readRDS( 'S:/Advantage Data/DHR-Analytics/data/jpact.rds' )

      update_time = format( Sys.time(), "%I:%M %p at %b %d, %Y")

      shiny::showModal(
        shiny::modalDialog(
          title = "Complete",
          shiny::p( paste0(
            "JPACT is done refreshing at ", update_time, " with ",
            format( nrow( jpact ), big.mark = ","), " rows and ",
            ncol( jpact ), " columns",
            ". You can close this window now.")
          )
        )
      )

    })

    output$spinner <- shiny::renderUI({
      if ( input$read_jpact ) {
        shinycssloaders::withSpinner( shiny::uiOutput("dummy") )
      } else {
        NULL
      }
    })

    # Listen for the 'done' event.
    shiny::observeEvent(input$done, {
      shiny::stopApp()
    })
  }

  # We'll use a dialog viwer
  viewer <- shiny::dialogViewer("JPACT File")

  shiny::runGadget(ui, server, viewer = viewer)

}

# Call the addin
# readJPACT()
