library(shiny)
library(miniUI)
require(rstudioapi)
library(shinycssloaders)

readJpactDate = function() {

  ui <- miniPage(
    gadgetTitleBar("Import the processed JPACT data"),
    miniContentPanel(

      # Explain what will happen
      helpText("Insert code in an open script that reads the JPACT file date"),
      actionButton("insert_code", "Insert code"),

      helpText("Directly read the JPACT file date."),
      actionButton("read_jpact", "Import date"),

    )
  )

  server <- function(input, output, session) {

    observeEvent( input$insert_code, {
      code_read = rstudioapi::insertText(
        "# Read jpact date
    if ( !exists('jpact_date') ) {
    jpact_date = readRDS( paste0( data_path, 'jpact_file_date.rds') )
    }"
      )
    })

    # User chooses to read jpact
    observeEvent( input$read_jpact, {

      jpact_date <<- readRDS( 'S:/Advantage Data/DHR-Analytics/data/jpact_file_date.rds' )

      showModal(
        modalDialog(
          title = "Complete",
          p( paste0(
            "JPACT file date is now updated. The date of the file is ",
            jpact_date,
            ". You can close this window now.")
          ))
      )

    })

    # Listen for the 'done' event.
    observeEvent(input$done, {
      stopApp()
    })
  }

  # We'll use a dialog viwer
  viewer <- dialogViewer("JPACT File")

  runGadget(ui, server, viewer = viewer)

}

# Call the addin
# readJpactDate()
