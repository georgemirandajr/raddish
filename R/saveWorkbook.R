require(openxlsx)

require(shiny)
require(miniUI)
require(rstudioapi)

saveAsExcel  = function() {

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("Save As Excel Workbook"),
    miniUI::miniContentPanel(

      # Explain what will happen
      shiny::uiOutput("folder_path"),

      shiny::helpText("Select the data to save:"),
      shiny::uiOutput("data_input"),

      shiny::textInput("wb_name", "Workbook Name", placeholder = "my_spreadsheet"),

      shiny::actionButton("saveExcel", "Save")
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

    shiny::observeEvent( input$saveExcel, {

      wb = openxlsx::createWorkbook()
      openxlsx::addWorksheet( wb, sheetName = "Sheet1" )
      openxlsx::writeDataTable( wb, "Sheet1",
                      x = get( input$tbl_selected, envir = .GlobalEnv),
                      tableName = input$tbl_selected )
      openxlsx::saveWorkbook( wb,
                    file = paste0( values$chooseFolder, "/", input$wb_name, '.xlsx'),
                    overwrite = TRUE )

      shiny::showModal(
        shiny::modalDialog( title = "Success!",
                     shiny::h4("Your data is ready. You can close this app now.") )
      )


  })

    # Listen for the 'done' event.
    shiny::observeEvent(input$done, {
      shiny::stopApp()
    })
}

# We'll use a dialog viwer
viewer <- shiny::dialogViewer("Save")

shiny::runGadget(ui, server, viewer = viewer)

}

# Call the addin
# saveAsExcel()
