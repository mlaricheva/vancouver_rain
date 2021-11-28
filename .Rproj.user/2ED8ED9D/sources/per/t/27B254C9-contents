library(shiny)
library(ggplot2)
library(dplyr)

ui <- fluidPage(

    titlePanel("Raincouver in numbers"),
    
    h3("Description"),
    p(HTML('This app provides some insides whether it really <i>always</i> 
           rains in Vancouver. The data for the last 50 years was collected from
           <a href="https://weatherstats.ca"> weatherstats.ca </a> 
           based on Environment and Climate Change Canada data')),
    sidebarLayout(
        sidebarPanel(
            
            ### input element for month
            selectInput("month", label = h4("Select Month"), 
                        choices = setNames(as.list(1:12), month.name), 
                        selected = 1),
            
            ### input element for year
            sliderInput("year", label = h4("Select Year"), min = 1972, 
                        max = 2021, value = 2020, sep ='', step = 1),
            
            ### input whether to show mean month value
            checkboxInput("checkbox", label = "Add mean values for that month", value = TRUE),
        ),
        mainPanel(
            plotOutput("histogram")
        )
    )
)


server <- function(input, output) {
    
    data <- read.csv("data/rain_data.csv")
    
    ### subset of data to plot
    filtered <- reactive({
        data %>%
            filter(year == input$year, month == input$month)
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
    
    ### month name to put in the plot description
    month_name <- reactive({
        month_name <- month.name[as.numeric(input$month)]
    })
    
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
                           as.character(month_name()), ### add month name
                           ", ", 
                           as.character(input$year), ### add year
                           sep="")
             ) +
        
        ### global mean line
        geom_hline(aes(yintercept = mean_rain()$mean), color = "darkred", linetype = 2) + 
        geom_text(aes(x = min(as.Date(date)) + 10, y = mean_rain()$mean), 
                  label = paste("mean precipitation for", as.character(month_name())), 
                  vjust = -0.5, color="darkred") + 
        
        ### local mean line
        geom_hline(aes(yintercept = mean_rain()$cur_mean), color = "slategrey", linetype = 2) + 
        geom_text(aes(x = max(as.Date(date)) - 10, y = mean_rain()$cur_mean), 
                  label = paste("mean precipitation in ", as.character(month_name()), ", ", 
                                as.character(input$year), sep=""), 
                  vjust = -0.5, color="slategrey")
    )
}

shinyApp(ui = ui, server = server)
