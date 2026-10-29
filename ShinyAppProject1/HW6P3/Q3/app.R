library(shiny)
library(ggplot2)
library(macleish)
#=======================================UI======================================

ui <- bootstrapPage(
  titlePanel("MacLeish Weather Explorer"),
  
  p("Explore temperature measurements from the two weather stations."),
  
  sidebarLayout(
    sidebarPanel(
      
      # Select weather station
      selectInput(
        inputId = "station",
        label = "Weather station:",
        choices = c(
          "Whately" = "whately_2015",
          "Orchard" = "orchard_2015"
        ),
        selected = "whately_2015"
      ),
      
      # Select date range
      dateRangeInput(
        inputId = "dates",
        label = "Date range:",
        start = as.Date("2015-01-01"),
        end = as.Date("2015-12-31"),
        min = as.Date("2015-01-01"),
        max = as.Date("2015-12-31")
      )
    ),
    
    mainPanel(
      plotOutput("weather_plot", height = "400px")
    )
  )
)

#====================================Server=====================================

server <- function(input, output, session) {
  
  output$weather_plot <- renderPlot({
    

    if (input$station == "whately_2015") {
      data <- whately_2015
      station_name <- "Whately"
    } else {
      data <- orchard_2015
      station_name <- "Orchard"
    }
    
    
    weather_dates <- as.Date(data$when)
    
    keep <- weather_dates >= input$dates[1] &
      weather_dates <= input$dates[2]
    
    data <- data[keep, , drop = FALSE]
    
  
    validate(
      need(
        nrow(data) > 0,
        "No data available for these dates."
      )
    )
    
 
    ggplot(data, aes(x = when, y = temperature)) +
      geom_line() +
      labs(
        x = "Date",
        y = "Temperature (°C)",
        title = paste("Temperature at", station_name)
      ) +
      theme_minimal()
    
  })
  
}
shinyApp(ui = ui, server = server)