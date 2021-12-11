# Rain in Vancouver 
Shiny app made to estimate the amonth of rain in Vancouver, BC. The data covers the period from January 1972 to November 2021 and was collected from https://weatherstats.ca/, based on Environment and Climate Change Canada data. 
 
The app was made as a part of a homework assignment for STAT-545B class at UBC, Winter term 2021 (assignment description avaliable at the [class website](https://stat545.stat.ubc.ca/assignments/assignment-b4/)). The option chosen is **Option C (Shiny App)**. 

## Weblink 
https://mlaricheva.shinyapps.io/vancouver_rain_v2/

## App description

The app provides an overview of how much and how often it wa raining in Vancouver, BC. It is based on the Environment and Climate Change Canada and allows to see the characteristics of every month for the last 50 years.

### Amount
The histogram demonstrates daily amounts of precipitation. By clicking a checkbox user can also add mean values for that month on the plot and compare mean precipitation calculated for the 50-year period and for the month of a selected year. There is also a possibility to switch from depth measure (precipitation in mm) to units of volume (such as m3 or gallons).  
  
### Frequency
Waffle plot shows how many days had at least some amount of rain. There are four weather categories, depending on the daily precipitation: 
- no rain (0 mm);
- some rain (less than 10 mm);
- moderate rain (less than 20 mm); 
- heavy rain (more than 20 mm).  

The legend corresponds to the one used in the [Climate Atlas](https://climateatlas.ca/map/canada/precip10_2060_85).  

This tab also calculates the longest strike of rain and no-rain as the longest number of consequitive days with the same weather (meaning rain or no-rain).


