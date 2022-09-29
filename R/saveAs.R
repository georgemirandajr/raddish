require(openxlsx)

require(shiny)
require(miniUI)
require(rstudioapi)

saveAs  = function() {

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("Save Your Data"),
    miniUI::miniContentPanel(

      # Explain what will happen
      shiny::uiOutput("folder_path"),

      shiny::helpText("Select the data you want to save:"),
      shiny::uiOutput("data_input"),

      shiny::textInput("file_name", "Provide a File Name", placeholder = "my_data"),
      shiny::radioButtons("saveType",
                                label = "Which format do you want to save as?",
                                choiceNames = c( "CSV", "Excel", "RDS"),
                                choiceValues = c(".csv", ".xlsx", ".rds"),
                                selected = "CSV",
                                inline = TRUE ),

      shiny::actionButton("save", "Save")
    )
  )

  server <- function(input, output, session) {

    values = shiny::reactiveValues()

    output$folder_path <- shiny::renderUI({
      values$chooseFolder <- chooseFolder <- rstudioapi::selectDirectory(caption = "Save to this folder", label = "Select Folder")
    })

    output$data_input <- shiny::renderUI({

      my_objs = ls( envir = .GlobalEnv )
      my_objs_df = unlist( purrr::map( my_objs, ~ is.data.frame( eval( parse( text = .x ) ) ) ) )
      my_objs = my_objs[ my_objs_df ]

      shiny::selectInput("tbl_selected", "",
                  choices = my_objs )

    })

    shiny::observeEvent( input$save, {

      if ( input$saveType == ".csv" ) {

        readr::write_csv( x = get( input$tbl_selected),
                          file = paste0( values$chooseFolder, "/", input$file_name, '.csv' ) )

      } else if ( input$saveType == ".xlsx" ) {
        wb = openxlsx::createWorkbook()
        openxlsx::addWorksheet( wb, sheetName = "Sheet1" )
        openxlsx::writeDataTable( wb, "Sheet1",
                                  x = get( input$tbl_selected, envir = .GlobalEnv ),
                                  tableName = input$tbl_selected )
        openxlsx::saveWorkbook( wb,
                                file = paste0( values$chooseFolder, "/", input$file_name, '.xlsx'),
                                overwrite = TRUE )
      } else if ( input$saveType == ".rds" ) {
        saveRDS( object = get( input$tbl_selected),
                 file = paste0( values$chooseFolder, "/", input$file_name, '.rds') )
      }


      shiny::showModal(
        shiny::modalDialog( title = "Success!",
                     shiny::h4("Your data is ready. You can close this app now.") )
      )


  })

    # Listen for the 'done' event.
    shiny::observeEvent(input$done, {
      shiny::stopApp(NULL)
    })
}

# We'll use a dialog viwer
viewer <- shiny::dialogViewer("Save")

shiny::runGadget(ui, server, viewer = viewer)

}

# Call the addin
# saveAs()
