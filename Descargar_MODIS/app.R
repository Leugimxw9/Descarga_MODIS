#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(MODIS)
# Define UI for application that draws a histogram


ui <- fluidPage((theme=shinytheme("spacelab")),
    headerPanel("Descarga de datos"),
    tabsetPanel(
        tabPanel(title="Precipitación",
                 
                 )
    )
)


# Define server logic required to draw a histogram
server <- function(input, output) {
    #showModal(modalDialog(title="MAP LOADING - PLEASE WAIT...","Please wait for map to draw before proceeding.",size="l",footer=NULL))
    

    
}

# Run the application 
shinyApp(ui = ui, server = server)
