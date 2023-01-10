# Rain in Vancouver 
Shiny app made to estimate the amonth of rain in Vancouver, BC. The data covers the period from January 1972 to November 2021 and was collected from https://weatherstats.ca/, based on Environment and Climate Change Canada data. 
 
The app was made as a part of a homework assignment for STAT-545B class at UBC, Winter term 2021 (assignment description avaliable at the [class website](https://stat545.stat.ubc.ca/assignments/assignment-b4/)). The option chosen is **Option C (Shiny App)**. 

## Weblink 
https://mlaricheva.shinyapps.io/vancouver_rain_v2/

## App description

The app provides an overview of how much and how often it was raining in Vancouver, BC. It allows to see the characteristics of every month for the last 50 years.

### Amount
The histogram demonstrates daily amounts of rain precipitation. By clicking a checkbox user can also add mean values to the plot and compare mean precipitation calculated for the 50-year period and for the chosen month of a selected year. There is also a converter from depth measure (precipitation in mm) to units of volume (such as m3 or gallons).  
  
### Frequency
Waffle plot shows how many days had at least some amount of rain. There are four weather categories, depending on the daily precipitation: 
- no rain (0 mm);
- some rain (less than 10 mm);
- moderate rain (less than 20 mm); 
- heavy rain (more than 20 mm).  

The legend corresponds to the one used in the [Climate Atlas](https://climateatlas.ca/map/canada/precip10_2060_85).  

This tab also calculates the longest strike of rain and no-rain as the longest number of consequitive days with the same weather (the classification used is binary).

### Features 

1. Total precipitation is calculated for the selected month.
![image](https://user-images.githubusercontent.com/47871121/147277468-72614800-0b7c-46d5-a56b-dc240c025566.png)
2. The explanation of precipitation is given including the transformation to different volume measures (m3, oil barrels, gallons) and tons.
![image](https://user-images.githubusercontent.com/47871121/147277527-292ef187-43a1-42c3-9a7b-6c7bcc33c37d.png)
3. The dynamic waffle chart shows number of days with or without rain in the selected month
![image](https://user-images.githubusercontent.com/47871121/147277605-639fee20-63bb-4da0-b89e-c4270f6fda5a.png)
4. The longest periods with or without rain are dynamically calculated.
![image](https://user-images.githubusercontent.com/47871121/147277632-5d993039-3c6e-488d-8bf8-175eeec48d6b.png)
