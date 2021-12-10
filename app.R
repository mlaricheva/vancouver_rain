library(shiny)
library(ggplot2)
library(dplyr)
library(glue)
library(shinyjs)
library(waffle)

unit_types <- list("Cubic Meters", "Oil Barrels", "US Gallons", "Tons")
VAN_AREA <- 114000
weather_levels <- c("no rain", "some rain", "moderate rain", "heavy rain")

ui <- fluidPage(
    useShinyjs(),
    titlePanel("Raincouver in numbers"),
    
    sidebarLayout(
        
        sidebarPanel(
            
            ## description
            p(HTML('This app provides some insides whether it really <i>always</i>
            rains in Vancouver. The data for the last 50 years was collected from 
            <a href="https://weatherstats.ca"> weatherstats.ca </a> 
            based on Environment and Climate Change Canada data')),
            
            h4("Some things you can do:"),
            
            tags$ul(
                tags$li("First list item"), 
                tags$li("Second list item"), 
                tags$li("Third list item")
            ),
            
            ### input element for month
            selectInput("month", label = h3("Select Month"), 
                        choices = setNames(as.list(1:12), month.name), 
                        selected = 1),
            
            ### input element for year
            sliderInput("year", label = h3("Select Year"), min = 1972, 
                        max = 2021, value = 2020, sep ='', step = 1)
        ),
        
        mainPanel(
            tabsetPanel(
                tabPanel("How much?", 
                         br(),
                         h2("How much was it raining?"),
                         p("This histogram provides and overview of precipitation in Vancouver
                           More text here More text here More text here More text here More text here 
                           More text here More text here More text here More text here More text here"),
                         
                         plotOutput("histogram"),
                         ### input whether to show mean month value
                         checkboxInput("checkbox", label = "Add mean values for that month", value = TRUE),
                         
                         h4(textOutput("month_sum")),
                         
                         br(),
                         em("What does it mean?"
                            #style = "font-size:20px;"
                            ),
                         p("Precipitation is calulated in the following way: 1,2,3."),
                         br(),
                         
                         h4(textOutput("rainfall")),
                         
                         div(style="display: inline-block;vertical-align:top;", h5("Change the measure to"), selected='mean'),
                         div(style="display: inline-block;vertical-align:top; width: 15%;", selectInput("measure", label = NULL, 
                                                                                                           choices = unit_types, 
                                                                                                           selected = 1))
    
                         
                ),
                tabPanel("How often?", 
                         br(),
                         h2("How often was it raining?"),
                         #cellWidths = c("70%", "30%"), 
                         p("This waffle plot provides and overview of rainy days in Vancouver
                           More text here More text here More text here More text here More text here 
                           More text here More text here More text here More text here More text here"),
                         plotOutput("pie"))
                         #tableOutput("weather_table"))
                )
            )
        )
)


server <- function(input, output) {
    
    data <- read.csv("data/rain_data.csv")
    
    ### subset of data to plot
    filtered <- reactive({
        data %>%
            filter(year == input$year, month == input$month) %>%
            mutate(day_weather = cut(rain, breaks = c(-1, 0, 10, 20, Inf), labels = weather_levels))
    })
    
    ### calculating mean values to add to the plot
    mean_rain <- reactive({
        if (input$checkbox) {
            mean_rain <- data %>% 
                group_by(month) %>%
                summarise(mean = mean(rain, na.rm = TRUE)) %>%
                filter(month == input$month) %>%
                mutate(cur_mean = mean(filtered()$rain, na.rm = TRUE))
        }
        else{
            ### if means are not needed, add line at -1 (would not be seen)
            mean_rain <- data.frame(month = input$month, mean = -1, cur_mean = -1)
        }
    })
    
    month_str <- reactive({
        month_str <- as.character(month.name[as.numeric(input$month)])
    })
    
    month_year_str <- reactive({
        month_year_str <- paste(
            month_str(),
            ", ", 
            as.character(input$year), sep = "")
    })
    
    ### sum precipitation
    output$month_sum <- renderText(
        month_sum <- paste("Total precipitation in that month was", sum(filtered()$rain), "mm")
    )
    
    ### sum rainfall
    rainfall_m <- reactive({
        VAN_AREA*sum(filtered()$rain)
    })
    
    output$rainfall <- renderText(
        paste(
            "The amount of rainfall in Vancouver was",
        switch(input$measure, 
               "Cubic Meters" = paste(rainfall_m(), "m3"),
               "Oil Barrels" = paste(rainfall_m()*6.29, "oil barrels"),
               "US Gallons" = paste(rainfall_m()*264, "gallons"),
               "Tons" = paste(round(rainfall_m()*0.3531466672), "tons"))
        )
    )
    
    ### histogram
    output$histogram <- renderPlot(
        ggplot(data = filtered()) + 
        geom_col(aes(x = as.Date(date), y = rain, fill = rain)) +
        scale_fill_gradient(low ="lightblue1", high = "lightsteelblue4") +
        ylim(c(0, NA)) + 
        scale_x_date(date_labels = "%d-%b", 
                     date_minor_breaks="1 day", 
                     date_breaks = "1 week",
                     expand = c(0,0)) +
        theme_minimal() + 
        theme(axis.title.x = element_blank(),
              axis.title.y = element_blank(),
              plot.title = element_text(hjust = 0.5, size=22)) +
        labs(fill='mm',
             title = paste("Precipitation in ", 
                           month_year_str(),
                           sep="")
             ) +
        
        ### global mean line
        geom_hline(aes(yintercept = mean_rain()$mean), color = "darkred", linetype = 2) + 
        geom_text(aes(x = min(as.Date(date)) + 10, y = mean_rain()$mean), 
                  label = paste("mean precipitation for", month_str()), 
                  vjust = -0.5, color="darkred", size = 6) + 
        
        ### local mean line
        geom_hline(aes(yintercept = mean_rain()$cur_mean), color = "slategrey", linetype = 2) + 
        geom_text(aes(x = max(as.Date(date)) - 10, y = mean_rain()$cur_mean), 
                  label = paste("mean precipitation in ", month_year_str(), sep=""), 
                  vjust = -0.5, color="slategrey", size = 6)
    )
    
    weather <- reactive({
        filtered() %>%
            group_by(day_weather) %>%
            count() %>%
            arrange(factor(day_weather))
    })
    
    output$weather_table <- renderTable(
        weather()
    )
    
    days <- reactive({
        setNames(as.integer(weather()$n),
                 paste(weather()$day_weather, " (", as.integer(weather()$n), ")", sep = ""))
    })
    
    ### pie chart
    output$pie <- renderPlot(
        waffle::waffle(days(), flip = TRUE, keep = TRUE, xlab = "days", reverse = TRUE,
                       colors = c("#bee9ff", "#90aebf", "#62747f", "#34393f")[1:length(days())], 
                       title = paste("Number of rainy days in", month_year_str())) +
        theme(legend.key.size = unit(2.5, "cm"),
              legend.position = "right",
              plot.title = element_text(hjust = 0.5, size = 22),
              legend.text=element_text(size = 16))
              #legend.box.margin=margin(100,0,0,100))
    )
}

shinyApp(ui = ui, server = server)
