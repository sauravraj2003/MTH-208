library(shiny)
library(dplyr)
library(ggplot2)
library(tidyr)
library(tidyverse)
library(hrbrthemes)
library(viridis)
library(plotly)
library(heatmaply)

load("Combined_data.RData")
load("country_names_total.Rdata")
country_data <- as.data.frame(Combined_data)
country_names=unique(country_data$Country)

ui <- navbarPage(
  title = "World Demographics",
  tabPanel("Data Viewer",
           # Sidebar layout with input and output definitions
           sidebarLayout(
             sidebarPanel(
               # c("population","fertility","Urban Population","Yearly Population Change ","Migration","Median Age","Population Density", "Urban Population Percentage","Percentage of World Population")
               selectInput(
                 inputId = "plot_type",
                 label = "View plots:",
                 choices = list(
                   "Select" = 1,
                   "Compare across Countries" = 2,
                   "Compare across features" = 3
                 )
               ),
               
               conditionalPanel(
                 condition = "input.plot_type == 2",
                 
                 selectInput(
                   inputId = "parameter",
                   label = "Select parameter:",
                   choices = c(
                     "population",
                     "fertility",
                     "Urban Population",
                     "Yearly Population Change ",
                     "Migration",
                     "Median Age",
                     "Population Density",
                     "Urban Population Percentage",
                     "Percentage of World Population",
                     "Mortality Rate"
                   )
                 ),
                 
                 selectizeInput(
                   "country_names",
                   "Select countries:",
                   c(unique(country_names)),
                   selected="India",
                   multiple = TRUE
                 )
               ),
               
               conditionalPanel(
                 condition = "input.plot_type == 3",
                 
                 selectInput(
                   inputId = "country_name",
                   label = "Select Country:",
                   choices = unique(country_data$Country)
                 ),
                 
                 selectizeInput(
                   "feature_names",
                   "Select parameters:",
                   c(
                     "population",
                     "fertility",
                     "Urban Population",
                     "Yearly Population Change ",
                     "Migration",
                     "Median Age",
                     "Population Density",
                     "Urban Population Percentage",
                     "Percentage of World Population",
                     "Mortality Rate"
                   ),
                   selected=c("population"),
                   multiple = TRUE
                 )
               ),
             ),
             
             
             mainPanel(
               conditionalPanel(
                 condition = "input.plot_type == 2",
                 plotOutput("parameterYearLine")
               ),
               conditionalPanel(
                 condition = "input.plot_type == 3",
                 plotOutput("compareFeatures")
               ),
             )
           )
  ),
  tabPanel("Summary",
           selectInput(
             inputId = "dataset",
             label = "Year:",
             choices = c(
               "2023",
               "2022",
               "2020",
               "2015",
               "2005",
               "2000",
               "1995",
               "1990",
               "1985",
               "1980",
               "1975",
               "1970",
               "1965",
               "1960",
               "1955"
             )
           ),
           numericInput(
             inputId = "obs",
             label = "Number of observations to view:",
             value = 10
           ),
           mainPanel(
             verbatimTextOutput("suma"),
             tableOutput("view"),
           )
  ),
  tabPanel("Heatmap",
           selectInput(
             inputId="heatmap_country",
             label = "choose Countries:",
             choices = unique(country_data$Country),
             selected = c("India","Russia","Albania","Romania"),
             multiple = TRUE,
             
           ),
           selectInput(
             inputId = "heatmap_factor",
             label = "Choose Demographic Factor",
             choices=c(
               "population",
               "fertility",
               "Urban Population",
               "Yearly Population Change ",
               "Migration",
               "Median Age",
               "Population Density",
               "Urban Population Percentage",
               "Percentage of World Population",
               "Mortality Rate"
             ),
             selected=c("Migration","fertility","Median Age"),
             multiple = TRUE
             
           ),
           selectInput(
             inputId = "heatmap_year",
             label = "Year:",
             choices = c(
               "2023",
               "2022",
               "2020",
               "2015",
               "2005",
               "2000",
               "1995",
               "1990",
               "1985",
               "1980",
               "1975",
               "1970",
               "1965",
               "1960",
               "1955"
             )
           ),
           mainPanel(
             plotlyOutput("heatm")
           )
  )
)

# Define server logic to summarize and view selected dataset ----
server <- function(input, output) {
  
  output$suma <- renderPrint({
    summary(country_data %>% filter(Year == input$dataset))
  })
  
  output$view <- renderTable({
    head(country_data %>% filter(Year == input$dataset), n = input$obs)
  })
  
  common_theme = theme(
    text = element_text(size = 30),
    
    plot.title = element_text(face = "bold"),
    axis.text = element_text(colour = "black", size = 25),
    legend.text = element_text(size = 25),
    
    panel.background = element_rect(fill = "white"),
    panel.grid = element_line(colour = "grey")
  )
  
  parameterYearLineData <- reactive({
    print(input$country_names)
    gfg_data <- country_data %>%
      select(Country, Year, input$parameter) %>%
      filter(Country %in% input$country_names)
    print(typeof(input$parameter))
    colnames(gfg_data)[colnames(gfg_data) == input$parameter] <- "param"
    gfg_data$Year <- as.numeric(gfg_data$Year)
    gfg_data
  })
  
  output$parameterYearLine <- renderPlot({
    gfg_data <- parameterYearLineData()
    print(gfg_data)
    gfg_plot <- ggplot(gfg_data) +
      geom_line(aes(
        x = Year,
        y = param,
        color = Country,
      )) +
      labs(title = "Comparison of Different countries with Time", y = input$parameter, x = "Years")
    
    gfg_plot
  })
  
  compareFeaturesData <- reactive({
    gfg_data <- country_data %>%
      filter(Country == input$country_name)
    gfg_data$Year <- as.numeric(gfg_data$Year)
    
    gfg_data <- pivot_longer(gfg_data, cols = all_of(input$feature_names), names_to = "params", values_to = "n")
    print(gfg_data)
    gfg_data
  })
  
  output$compareFeatures <- renderPlot({
    gfg_data <- compareFeaturesData()
    print(gfg_data)
    gfg_plot <- ggplot(gfg_data) +
      geom_line(aes(
        x = Year,
        y = n,
        color = params,
      )) +
      labs(title = "Visualization of Different factors of a Country With Time", y = input$parameter, x = "Years")
    
    gfg_plot
  })
  
  output$render <- renderPlot({  
    vecp = input$c2
    count = input$c1
    colsn <-  c("Year","population","fertility","Urban Population","Yearly Population Change ","Migration", 
                "Median Age","Population Density", "Urban Population Percentage","Percentage of World Population","Mortality Rate")
    
    for(i in 1:length(vecp))
    {
      ind1 = which(country == count[1])
      ind2 = which(colsn == vecp[i])
      
      plot(x =c(seq(1955,2020,by=5), 2022,2023) , y = rev(Combined_data[16*(ind1-1)+1: 16*ind1, ind2+1]),col=1,lwd=2,type="l")
      if(length(count)>1)
      {
        for(j in 2:length(count))
        {
          ind1 = which(country == count[j])
          lines(x = c(seq(1955,2020,by=5), 2022,2023), y = rev(Combined_data[16*(ind1-1)+1: 16*ind1, ind2+1]),col=j,lwd=2)
        }
      }
    }
  })
  output$heatm <- renderPlotly({
    selected_countries <- input$heatmap_country
    selected_factors <- input$heatmap_factor
    selected_year <- input$heatmap_year
    
    
    country_data_filtered <- country_data %>%
      filter(Country %in% selected_countries, Year %in% selected_year) %>%
      select(c("Country", selected_factors)) %>%
      arrange(Country)
    
    # Convert factors to numeric if needed
    country_data_filtered[,2] <- as.numeric(country_data_filtered[,2])
    row.names(country_data_filtered) <- unique(country_data_filtered$Country)
    country_data_filtered <- country_data_filtered %>%
      select(selected_factors)
    
    heatmaply(country_data_filtered, 
              xlab = "Features", ylab = "Countries",
              main = "Heatmap",
              scale = "column",
              margins = c(60, 100, 40, 20),
              grid_color = "white",
              grid_width = 0.00001,
              branches_lwd = 0.1,
              fontsize_row = 5, fontsize_col = 5,
              heatmap_layers = theme(axis.line = element_blank()))
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server=server)
