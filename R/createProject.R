library(shiny)
library(miniUI)

new_analysis <- function() {
  createProject <- function(path, projectName, ...) {

    # Create a folder for the project
    dir.create( paste0( path, "/", projectName) )

    # Create the sub-folders
    subFolderNames = c('data', 'output', 'code', 'utils', 'www')
    subFolderNames = path.expand( paste0( path, "/", projectName, "/", subFolderNames) )
    sapply( subFolderNames, dir.create )

    # Copy the report template
    f = system.file("extdata", "Report_Template.Rmd", package = "raddish" )

    if ( nchar(f) > 0 ) {
      file.copy( from = f, to = paste0( path, "/", projectName) )
    }

    # Copy the global.R file
    g = system.file("extdata", "global.R", package = "raddish" )

    if ( nchar(g) > 0 ) {
      file.copy( from = g, to = paste0( path, "/", projectName, "/code"))
    }

  }

  ui <- miniPage(
    gadgetTitleBar("Create a Custom Project Folder"),
    miniContentPanel(
      ## Name the new project
      textInput("folder_name_input", "New Project Name"),

      # Choose where to create the new project
      helpText("Choose a folder create your project in"),
      actionButton("choose_dir", "Choose folder"),

      # Change to this directory?
      checkboxInput("switch_dir", "Switch to this folder"),

      # Show the selected path to the new project
      uiOutput("created_your_folder")
    )
  )

  server <- function(input, output, session) {

    # Provide a default directory
    dir_path = reactiveValues( path= getwd() )

    # Update the selected path
    observeEvent( input$choose_dir, {
      dir_path$path = choose.dir()
      dir_path$path = gsub("\\\\", "/", dir_path$path)
    })

    ## Your reactive logic goes here.
    observeEvent( input$folder_name_input, {

      output$created_your_folder <- renderUI({
        p(
          paste0(
            "Creating ", dir_path[['path']], "/", input$folder_name_input
          )
        )
      })

    } )

    # Listen for the 'done' event. This event will be fired when a user
    # is finished interacting with your application, and clicks the 'done'
    # button.
    observeEvent(input$done, {

      # Here is where your Shiny application might now go and affect the
      # contents of a document open in RStudio.
      createProject( dir_path[['path']], input$folder_name_input )

      if ( input$switch_dir ) {
        setwd( paste0( dir_path[['path']], "/", input$folder_name_input ) )
      }

      # At the end, your application should call 'stopApp()' here, to ensure that
      # the gadget is closed after 'done' is clicked.
      stopApp()
    })
  }

  # We'll use a dialog viwer
  viewer <- dialogViewer("New Analysis Project")

  runGadget(ui, server, viewer = viewer)

}

# Call the addin
# new_analysis()
