require(shiny)
require(miniUI)

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

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("Create a Custom Project Folder"),
    miniUI::miniContentPanel(
      ## Name the new project
      shiny::textInput("folder_name_input", "New Project Name"),

      # Choose where to create the new project
      shiny::helpText("Choose a folder create your project in"),
      shiny::actionButton("choose_dir", "Choose folder"),

      # Change to this directory?
      shiny::checkboxInput("switch_dir", "Switch to this folder"),

      # Show the selected path to the new project
      shiny::uiOutput("created_your_folder")
    )
  )

  server <- function(input, output, session) {

    # Provide a default directory
    dir_path = shiny::reactiveValues( path= getwd() )

    # Update the selected path
    shiny::observeEvent( input$choose_dir, {
      dir_path$path = choose.dir()
      dir_path$path = gsub("\\\\", "/", dir_path$path)
    })

    ## Your reactive logic goes here.
    shiny::observeEvent( input$folder_name_input, {

      output$created_your_folder <- shiny::renderUI({
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
    shiny::observeEvent(input$done, {

      # Here is where your Shiny application might now go and affect the
      # contents of a document open in RStudio.
      raddish::createProject( dir_path[['path']], input$folder_name_input )

      if ( input$switch_dir ) {
        setwd( paste0( dir_path[['path']], "/", input$folder_name_input ) )
      }

      # At the end, your application should call 'stopApp()' here, to ensure that
      # the gadget is closed after 'done' is clicked.
      shiny::stopApp()
    })
  }

  # We'll use a dialog viwer
  viewer <- shiny::dialogViewer("New Analysis Project")

  shiny::runGadget(ui, server, viewer = viewer)

}

# Call the addin
# new_analysis()
