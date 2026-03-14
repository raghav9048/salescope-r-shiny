library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
library(readr)
library(bsicons)
library(plotly)

# Used LLM to create plot and also for output syntax.
#loading data
library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
library(readr)
library(bsicons)
library(plotly)

# Loading data
search_paths <- c("data", "../data", "./")
all_files <- list.files(path = search_paths, pattern = "\\.csv$", full.names = TRUE)

if (length(all_files) > 0) {
  csv_path <- all_files[1]
} else {
  stop("Critical Error: No CSV found. Please ensure your data folder is uploaded.")
}

sales_df <- read_csv(csv_path) %>%
  mutate(Launch_Date = as.Date(Launch_Date))

# UI
ui <- page_sidebar(
  title = "Salescope — Customer Retention Insights",
  theme = bs_theme(version = 5, bootswatch = "lumen"),
  
  sidebar = sidebar(
    title = "Analysis Filters",
    
    # Feature 1: Input (Dropdown)
    selectInput("region_filter", "Select Region:", 
                choices = c("All", unique(sales_df$Region)), selected = "All"),
    
    # Feature 1: Input (Slider)
    sliderInput("clv_range", "Customer Lifetime Value (LTV):",
                min = 0, max = 10000, value = c(0, 10000), step = 500, pre = "$"),
    
    # Feature 1: Input (Date Range)
    dateRangeInput("date_range", "Filter by Launch Date:",
                   start = min(sales_df$Launch_Date, na.rm = TRUE),
                   end   = max(sales_df$Launch_Date, na.rm = TRUE),
                   min   = min(sales_df$Launch_Date, na.rm = TRUE),
                   max   = max(sales_df$Launch_Date, na.rm = TRUE)),
    hr(),
    markdown("Adjust filters to update results in real-time.")
  ),
  
  # Output (Value Boxes)
  layout_columns(
    value_box(
      title = "Avg Lifetime Value",
      value = textOutput("avg_ltv"),
      showcase = bs_icon("currency-dollar"),
      theme = "primary"
    ),
    value_box(
      title = "Customer Count",
      value = textOutput("cust_count"),
      showcase = bs_icon("people"),
      theme = "dark"
    )
  ),
  
  # Outputs (Interactive Plot & Table)
  layout_columns(
    card(
      card_header("LTV vs. Churn Probability (Hover for details)"),
      plotlyOutput("scatter_plot", height = "450px"),
      full_screen = TRUE
    ),
    card(
      card_header("Region Performance Summary"),
      tableOutput("summary_table"),
      full_screen = TRUE
    ),
    col_widths = c(7, 5)
  )
)

# Server Logic
server <- function(input, output, session) {
  
  # Feature 2: Reactive Calculation
  filtered_data <- reactive({
    df <- sales_df
    
    if (input$region_filter != "All") {
      df <- df %>% filter(Region == input$region_filter)
    }
    
    df <- df %>% filter(
      Lifetime_Value >= input$clv_range[1],
      Lifetime_Value <= input$clv_range[2],
      Launch_Date >= as.Date(input$date_range[1]),
      Launch_Date <= as.Date(input$date_range[2])
    )
    
    return(df)
  })
  
  # KPI 1: Average LTV
  output$avg_ltv <- renderText({
    data <- filtered_data()
    if (nrow(data) == 0) return("$0.00")
    val <- mean(data$Lifetime_Value, na.rm = TRUE)
    paste0("$", format(round(val, 2), big.mark = ","))
  })
  
  # KPI 2: Total Count
  output$cust_count <- renderText({
    nrow(filtered_data())
  })
  
  # Output 2: Interactive plotly scatter plot
  #
  output$scatter_plot <- renderPlotly({
    df_plot <- filtered_data()
    if (nrow(df_plot) == 0) return(NULL)
    
    p <- ggplot(df_plot, aes(x = Lifetime_Value, 
                             y = Churn_Probability, 
                             color = Region,
                             text = paste("Customer ID:", Customer_ID, 
                                          "<br>LTV: $", format(round(Lifetime_Value, 2), big.mark=","),
                                          "<br>Churn Risk:", round(Churn_Probability, 3)))) +
      geom_point(alpha = 0.5, size = 2) +
      theme_minimal() +
      labs(x = "Lifetime Value ($)", y = "Churn Probability") +
      scale_color_brewer(palette = "Set1")
    
    ggplotly(p, tooltip = "text") %>% 
      layout(legend = list(orientation = "h", y = -0.2))
  })
  
  # Output 3: Summary table
  output$summary_table <- renderTable({
    df_table <- filtered_data()
    if (nrow(df_table) == 0) return(NULL)
    
    df_table %>%
      group_by(Region) %>%
      summarise(
        Count = n(),
        `Avg LTV` = mean(Lifetime_Value, na.rm = TRUE),
        `Avg Churn` = mean(Churn_Probability, na.rm = TRUE)
      ) %>%
      mutate(
        `Avg LTV` = paste0("$", format(round(`Avg LTV`, 2), big.mark = ",")),
        `Avg Churn` = paste0(round(`Avg Churn` * 100, 1), "%")
      )
  }, striped = TRUE, hover = TRUE, bordered = TRUE)
}

# Launching app
shinyApp(ui, server)