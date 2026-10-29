#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(palmerpenguins)
library(shiny)
library(ggplot2)
library(palmerpenguins)

penguin_attributes <- c(
  "Bill length (mm)" = "bill_length_mm",
  "Bill depth (mm)" = "bill_depth_mm",
  "Flipper length (mm)" = "flipper_length_mm",
  "Body mass (g)" = "body_mass_g"
)

#=======================================UI======================================

ui <- bootstrapPage(
  titlePanel("Penguin Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      
      # Select species
      selectInput(
        inputId = "species",
        label = "Species:",
        choices = c(
          "All",
          sort(unique(as.character(penguins$species)))
        ),
        selected = "All"
      ),
      
      # Select sex
      selectInput(
        inputId = "sex",
        label = "Sex:",
        choices = c("All", "Female" = "female", "Male" = "male"),
        selected = "All"
      ),
      
      # x-axis
      selectInput(
        inputId = "xvar",
        label = "X-axis:",
        choices = penguin_attributes,
        selected = "bill_length_mm"
      ),
      
      # y-axis 
      selectInput(
        inputId = "yvar",
        label = "Y-axis:",
        choices = penguin_attributes,
        selected = "bill_depth_mm"
      )
    ),
    
    mainPanel(
      plotOutput("scatterplot")
    )
  )
)

#====================================Server=====================================

server <- function(input, output, session) {
  
  output$scatterplot <- renderPlot({
    
    data <- penguins
    
    if (input$species != "All") {
      data <- data[data$species == input$species, ]
    }
    
    if (input$sex != "All") {
      data <- data[data$sex == input$sex, ]}
    
    data <- data[
      complete.cases(data[, c(input$xvar, input$yvar)]), ]
    
    x_label <- names(penguin_attributes)[
      match(input$xvar, penguin_attributes)]
    
    y_label <- names(penguin_attributes)[
      match(input$yvar, penguin_attributes)]
    
    ggplot(
      data,
      aes(
        x = .data[[input$xvar]],
        y = .data[[input$yvar]],
        color = species)) +
      geom_point() +
      labs(
        x = x_label,
        y = y_label,
        color = "Species",
        title = "Penguin Measurements"
      ) +
      theme_minimal()
  })
}

shinyApp(ui = ui, server = server)