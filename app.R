library(shiny)
library(ggplot2)
library(dplyr)
library(glue)
library(waffle)

### defining constant variables
unit_types <- list("Cubic Meters", "Oil Barrels", "US Gallons", "Tons")
VAN_AREA <- 114000
weather_levels <- c("no rain", "some rain", "moderate rain", "heavy rain")

ui <- fluidPage(
    
    titlePanel("Raincouver in numbers"),
    sidebarLayout(
        
        sidebarPanel(
            
            ### app description
            p(HTML('This app provides some insides whether it really <i>always</i>
            rains in Vancouver. The data for the last 50 years 
            (the most recent month avaliable is <b>November, 2021</b>) was collected from 
            <a href="https://weatherstats.ca"> weatherstats.ca </a> 
            based on Environment and Climate Change Canada data')),
            br(),
            
            ### app features
            h4("Some things you can do with this app:"),
            tags$ul(
                tags$li('See daily and total precipitation'), 
                tags$li("Convert precipitation in mm to other metrics"),
                tags$li('Check the number of days when it was raining'),
                tags$li("Find the longest period of rain within one month")
            ),
            
            ### input element for month
            selectInput("month", label = h3("Select Month and Year to start"), 
                        choices = setNames(as.list(1:12), month.name), 
                        selected = 1),
            
            ### input element for year
            sliderInput("year", label = NULL, min = 1972, 
                        max = 2021, value = 2020, sep ='', step = 1)
        ),
        
        mainPanel(
            tabsetPanel(
                ### TAB 1
                tabPanel("Amount",
                     br(),
                     h2("How much was it raining?"),
                     
                     ### checkbox for means
                     checkboxInput("checkbox", label = "Add mean values", value = TRUE),
                     
                     ### histogram output
                     plotOutput("histogram"),
                     br(),
                     
                     ### summary precipitation text
                     uiOutput("month_sum"),
                     br(),
                     
                     ### table layout
                     fluidRow(
                         column(width = 6,
                                
                            ### description
                            p(HTML('<p style="font-size:24px; text-align: center;">What is precipitation?</p>')),
                            p('Precipitation is a standard rainfall measure, that is is expressed in terms of the vertical depth 
                                to which water from the rain would stand on a level surface area if all the water from it were collected on this surface.
                                Usually, a circular funnel with a diameter of 203 mm (or 8-inch rain gauge) is used for the water collection.
                                Precipitation values provided here are measured across several weather stations and then averaged. 
                                When the area is know, we can also covert precipiation to water volume metrics with some degree of accuracy'),
                            
                            ### precipitation volume text
                            uiOutput("rainfall"),
                            
                            ### measure unit selection
                            div(style="display: inline-block;vertical-align:top;", 
                                h5("Change the measure to"), 
                                selected='mean'),
                            div(style="display: inline-block;vertical-align:top; width: 25%;", 
                                selectInput("measure", label = NULL, 
                                            choices = unit_types, 
                                            selected = 1))
                             ),
                        
                        column(width = 6,
                            br(),
                            
                            ### image
                            HTML('<center><p> Map of Vancouver </p>
                            <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQUcxjc_fUMLhVLm7rpYBVYb7d6z-dVVhnGwQ&usqp=CAU">
                            <p style="font-size:10px">source: <a href="https://vancouver.ca"> City of Vancouver </a> </center>')
                            )
                    )
                         
                ),
                
                ### TAB 2
                tabPanel("Frequency", 
                         br(),
                         h2("How often was it raining?"),
                         
                         ### waffle plot
                         br(),
                         plotOutput("waffle"),
                         
                         br(),
                         uiOutput("streaks"),
                         br(),
                         HTML('<p style="font-size:12px">Legend 
                              <a href="https://climateatlas.ca/map/canada/precip10_2060_85#"> source </a></p>')
                )
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
    
    ### extracting month name from month number
    month_str <- reactive({
        month_str <- as.character(month.name[as.numeric(input$month)])
    })
    
    ### sum precipitation
    output$month_sum <- renderUI({
        sum_rain <- sum(filtered()$rain)
        month_sum <- HTML(glue('Total precipitation in {month_str()}, {input$year} was 
                               <span style="color:#34393f; font-weight:bold; font-size:20px">{sum_rain} mm</span>'))
    })
    
    ### rainfall volume summary 
    output$rainfall <- renderUI({
        rainfall_m <- VAN_AREA*sum(filtered()$rain)
        
        ### converting between units
        metric <- switch(input$measure, 
               "Cubic Meters" = paste(format(rainfall_m, big.mark=","), "m3"),
               "Oil Barrels" = paste(format(rainfall_m*6.29, big.mark=","), "oil barrels"),
               "US Gallons" = paste(format(rainfall_m*264, big.mark=","), "gallons"),
               "Tons" = paste(format(rainfall_m*0.3531466672, big.mark=","), "tons"))
        
        ### joining together text summary
        rainfall <- p(HTML(glue('Given the Vancouver area of 114 square kilometres 
        (or 44 square miles), we get the rainfall volume of 
        <span style="color:#34393f; font-weight:bold; font-size:20px">{metric} </span>')))
    })
    
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
        labs(fill='mm', title = glue("Precipitation in {month_str()}, {input$year}")) +
        
        ### global mean line
        geom_hline(aes(yintercept = mean_rain()$mean), color = "darkred", linetype = 2) + 
            annotate("text", x = min(as.Date(filtered()$date)) + 10, y = mean_rain()$mean, 
                     label = glue("mean precipitation for {month_str()}"),
                     vjust = -0.5, color="darkred", size = 6) +
        
        ### local mean line
        geom_hline(aes(yintercept = mean_rain()$cur_mean), color = "slategrey", linetype = 2) + 
        annotate("text", x = max(as.Date(filtered()$date)) - 10, y = mean_rain()$cur_mean, 
                  label = glue("mean precipitation in {month_str()}, {input$year}"), 
                  vjust = -0.5, color="34393f", size = 6)
    )
    
    ### weather tibble for plot and legend
    weather <- reactive({
        filtered() %>%
            group_by(day_weather) %>%
            count() %>%
            arrange(factor(day_weather))
    })
    
    ### named vector for the waffle plot
    days <- reactive({
        setNames(as.integer(weather()$n),
                 paste(weather()$day_weather, " (", as.integer(weather()$n), ")", sep = ""))
    })
    
    ### waffle chart
    output$waffle <- renderPlot(
        waffle::waffle(days(), flip = TRUE, keep = TRUE, reverse = TRUE,
                       colors = c("#bee9ff", "#90aebf", "#62747f", "#34393f")[1:length(days())], 
                       title = glue("Number of rainy days in {month_str()}, {input$year}")) +
        theme(legend.key.size = unit(2.5, "cm"),
              legend.position = "right",
              plot.title = element_text(hjust = 0.5, size = 22),
              legend.text=element_text(size = 16))
    )
    
    ### calculating streaks (of rain and no-rain)
    output$streaks <- renderUI({
        norain_streak <- rle(filtered()$day_weather == "no rain")
        norain_max <- max(norain_streak$lengths[norain_streak$values == TRUE])
        rain_max <- max(norain_streak$lengths[norain_streak$values == FALSE])
        
        if(rain_max==-Inf){rain_max<-0} ## if there were no rain days :)
        if(norain_max==-Inf){norain_max<-0} ## if all days were rainy :(
        
        streaks <- HTML(glue('The longest period without rain was <span style="color:#90aebf; font-weight:bold; font-size:20px">{norain_max}</span> days <br> 
                             The longest period of rain only was <span style="color:#34393f; font-weight:bold; font-size:20px">{rain_max}</span> days'))
    })
    
    
}

shinyApp(ui = ui, server = server)
