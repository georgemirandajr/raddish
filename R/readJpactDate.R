require(shiny)
require(miniUI)
require(rstudioapi)
require(shinycssloaders)

readJpactDate = function() {

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("Import the processed JPACT data"),
    miniUI::miniContentPanel(

      # Explain what will happen
      shiny::helpText("Insert code in an open script that reads the JPACT file date"),
      shiny::actionButton("insert_code", "Insert code"),

      shiny::helpText("Directly read the JPACT file date."),
      shiny::actionButton("read_jpact", "Import date"),

    )
  )

  server <- function(input, output, session) {

    shiny::observeEvent( input$insert_code, {
      code_read = rstudioapi::insertText(
        "
# Read jpact date
if ( !exists('jpact_date') ) {
  jpact_date = readRDS( paste0( data_path, 'output/jpact_file_date.rds') )
}"
      )
    })

    # User chooses to read jpact
    shiny::observeEvent( input$read_jpact, {

      jpact_date <<- readRDS( 'S:/Advantage Data/DHR-Analytics/data/output/jpact_file_date.rds' )

      shiny::showModal(
        shiny::modalDialog(
          title = "Complete",
          shiny::p( paste0(
            "JPACT file date is now updated. The date of the file is ",
            jpact_date,
            ". You can close this window now.")
          ))
      )

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
# readJpactDate()
