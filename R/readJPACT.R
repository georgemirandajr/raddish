library(shiny)
library(miniUI)
require(rstudioapi)
library(shinycssloaders)

readJPACT = function() {

  ui <- miniPage(
    gadgetTitleBar("Import the processed JPACT data"),
    miniContentPanel(

      # Explain what will happen
      helpText("Insert code in an open script that reads the processed JPACT file"),
      actionButton("insert_code", "Insert code"),

      helpText("Import the processed JPACT file to analyze."),
      helpText("This may take 1-2 minutes."),
      actionButton("read_jpact", "Import data"),

    )
  )

  server <- function(input, output, session) {

    observeEvent( input$insert_code, {
      code_readJPACT = rstudioapi::insertText(
        "# Read jpact data
    if ( !exists('jpact') ) {
    jpact = readRDS( paste0(data_path, 'jpact.rds') )
    }"
      )
    })

    # User chooses to read jpact
    observeEvent( input$read_jpact, {

      jpact <<- readRDS( 'S:/Advantage Data/DHR-Analytics/data/jpact.rds' )

      update_time = format( Sys.time(), "%I:%M %p at %b %d, %Y")

      showModal(
        modalDialog(
          title = "Complete",
          p( paste0(
            "JPACT is done refreshing at ", update_time, " with ",
            format( nrow( jpact ), big.mark = ","), " rows and ",
            ncol( jpact ), " columns",
            ". You can close this window now.")
          )
        )
      )

    })

    output$spinner <- renderUI({
      if ( input$read_jpact ) {
        shinycssloaders::withSpinner(uiOutput("dummy") )
      } else {
        NULL
      }
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
# readJPACT()
