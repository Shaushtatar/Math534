library(shiny)
library(ggplot2)
library(tidyverse)
library(mdsr)
library(dplyr)
library(dbplyr)
library(DBI)
library(RSQLite)
library(RMariaDB)
library(stats)

con <- dbConnect_scidb("airlines")

years <- dbGetQuery(
  con,
  "SELECT DISTINCT year 
   FROM flights 
   ORDER BY year"
)$year

origins <- dbGetQuery(
  con,
  "SELECT DISTINCT origin 
   FROM flights 
   WHERE origin IS NOT NULL 
   ORDER BY origin"
)$origin

destinations <- dbGetQuery(
  con,
  "SELECT DISTINCT dest 
   FROM flights 
   WHERE dest IS NOT NULL 
   ORDER BY dest"
)$dest

carriers <- dbGetQuery(
  con,
  "SELECT DISTINCT carrier 
   FROM flights 
   WHERE carrier IS NOT NULL 
   ORDER BY carrier"
)$carrier

#flight_summary <- dbGetQuery(
#  con,
#  "SELECT
#     year,
#     month,
#     origin,
#     dest,
#     carrier,
#     COUNT(*) AS flight_count,
#     AVG(arr_delay) AS avg_arr_delay,
#     SUM(CASE WHEN arr_delay IS NOT NULL
#         THEN 1 ELSE 0 END) AS delay_count
#   FROM flights
#   GROUP BY year, month, origin, dest, carrier
#   ORDER BY year, month"
#)

#delay_limits <- dbGetQuery(
#  con,
#  "SELECT MIN(arr_delay) AS min_delay, MAX(arr_delay) AS max_delay
#   FROM flights WHERE arr_delay IS NOT NULL"
#)
#delay_min <- floor(as.numeric(delay_limits$min_delay[1]))
#delay_max <- ceiling(as.numeric(delay_limits$max_delay[1]))

#=======================================UI======================================

ui <- bootstrapPage(
  titlePanel("Interactive Flight Explorer"),
  
  p("Explore monthly flight counts and arrival delays."),
  
  sidebarLayout(
    sidebarPanel(
      # Widget 1: year selector
      selectInput(
        inputId = "year",
        label = "Year:",
        choices = c("ALL", setNames(as.character(years), as.character(years))),
        selected = if ("2015" %in% as.character(years)) "2015" else "ALL"
      ),
      
      # Widget 2: origin airport selector
      selectInput(
        inputId = "origin",
        label = "Origin airport:",
        choices = c("ALL", setNames(as.character(origins), as.character(origins))),
        selected = if ("ORD" %in% as.character(origins)) "ORD" else "ALL"
      ),
      
      # Widget 3: destination airport selector
      selectInput(
        inputId = "dest",
        label = "Destination airport:",
        choices = c("ALL", setNames(as.character(destinations), as.character(destinations))),
        selected = "ALL"
      ),
      
      # Widget 4: carrier selector
      selectInput(
        inputId = "carrier",
        label = "Carrier:",
        choices = c("ALL", setNames(as.character(carriers), as.character(carriers))),
        selected = "ALL"
      ),
      
      # Widget 5: month range slider
      sliderInput(
        inputId = "months",
        label = "Month range:",
        min = 1,
        max = 12,
        value = c(1, 12),
        step = 1
      )
    ),
    mainPanel(
      h4("Flights per month"),
      plotOutput("monthly_plot", height = "380px"),
      h4("Summary"),
      tableOutput("summary_table")
    )
  )
)

#====================================Server=====================================

server <- function(input, output, session) {
  
  
  get_monthly_summary <- function() {
    
    filters <- sprintf(
      "month BETWEEN %d AND %d",
      input$months[1],
      input$months[2]
    )
    
    if (input$year != "ALL") {
      filters <- c(
        filters,
        paste0("year = ", as.integer(input$year))
      )
    }
    
    if (input$origin != "ALL") {
      filters <- c(
        filters,
        paste0(
          "origin = ",
          as.character(dbQuoteString(con, input$origin))
        )
      )
    }
    
    if (input$dest != "ALL") {
      filters <- c(
        filters,
        paste0(
          "dest = ",
          as.character(dbQuoteString(con, input$dest))
        )
      )
    }
    
    if (input$carrier != "ALL") {
      filters <- c(
        filters,
        paste0(
          "carrier = ",
          as.character(dbQuoteString(con, input$carrier))
        )
      )
    }
    
    sql <- paste(
      "SELECT year, month,",
      "COUNT(*) AS flight_count,",
      "AVG(arr_delay) AS avg_arr_delay,",
      "SUM(CASE WHEN arr_delay IS NOT NULL THEN 1 ELSE 0 END) AS delay_count",
      "FROM flights",
      paste("WHERE", paste(filters, collapse = " AND ")),
      "GROUP BY year, month",
      "ORDER BY year, month"
    )
    
    dbGetQuery(con, sql)
  }
  
  
  output$monthly_plot <- renderPlot({
    
    data <- get_monthly_summary()
    
    validate(
      need(nrow(data) > 0, "No flights match these choices.")
    )
    
    data$month_date <- as.Date(
      sprintf("%04d-%02d-01", data$year, data$month)
    )
    
    ggplot(data, aes(x = month_date, y = flight_count)) +
      geom_line() +
      geom_point() +
      scale_x_date(
        date_labels = "%b %Y",
        date_breaks = "2 months"
      ) +
      labs(
        x = "Month",
        y = "Number of flights",
        title = "Monthly flights matching your selections"
      ) +
      theme_minimal()
  })
  
  
  
  output$summary_table <- renderTable({
    
    data <- get_monthly_summary()
    
    validate(
      need(nrow(data) > 0, "No flights match these choices.")
    )
    
    has_delays <- data$delay_count > 0 &
      !is.na(data$avg_arr_delay)
    
    average_delay <- if (any(has_delays)) {
      weighted.mean(
        data$avg_arr_delay[has_delays],
        data$delay_count[has_delays]
      )
    } else {
      NA_real_
    }
    
    data.frame(
      Measure = c(
        "Matching flights",
        "Average arrival delay",
        "Months represented"
      ),
      Value = c(
        format(
          sum(data$flight_count),
          big.mark = ",",
          scientific = FALSE
        ),
        if (is.na(average_delay)) {
          "N/A"
        } else {
          paste0(round(average_delay, 1), " minutes")
        },
        nrow(distinct(data, year, month))
      )
    )
    
  }, striped = TRUE, bordered = TRUE, spacing = "s")
}
shinyApp(ui = ui, server = server)