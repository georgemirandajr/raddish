library(openxlsx)

library(shiny)
library(miniUI)
require(rstudioapi)

saveAsExcel  = function() {

  ui <- miniPage(
    gadgetTitleBar("Save As Excel Workbook"),
    miniContentPanel(

      # Explain what will happen
      uiOutput("folder_path"),

      helpText("Select the data to save:"),
      uiOutput("data_input"),

      textInput("wb_name", "Workbook Name", placeholder = "my_spreadsheet"),

      actionButton("saveExcel", "Save")
    )
  )

  server <- function(input, output, session) {

    values = reactiveValues()

    output$folder_path <- renderUI({
      values$chooseFolder <- chooseFolder <- selectDirectory(caption = "Save to this folder", label = "Select Folder")
    })

    output$data_input <- renderUI({

      my_objs = ls( envir = .GlobalEnv )
      my_objs_df = unlist( my_objs %>% purrr::map( ~ is.data.frame( eval( parse( text = .x ) ) ) ) )
      my_objs = my_objs[ my_objs_df ]

      selectInput("tbl_selected", "",
                  choices = my_objs )

    })

    observeEvent( input$saveExcel, {

      wb = openxlsx::createWorkbook()
      addWorksheet( wb, sheetName = "Sheet1" )
      writeDataTable( wb, "Sheet1",
                      x = get( input$tbl_selected, envir = .GlobalEnv),
                      tableName = input$tbl_selected )
      saveWorkbook( wb,
                    file = paste0( values$chooseFolder, "/", input$wb_name, '.xlsx'),
                    overwrite = TRUE )

      showModal(
        modalDialog( title = "Success!",
                     h4("Your data is ready. You can close this app now.") )
      )


  })

    # Listen for the 'done' event.
    observeEvent(input$done, {
      stopApp()
    })
}

# We'll use a dialog viwer
viewer <- shiny::dialogViewer("Save")

runGadget(ui, server, viewer = viewer)

}

# Call the addin
# saveAsExcel()
