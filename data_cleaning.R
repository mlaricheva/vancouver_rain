library(dplyr)

data <- read.csv("data/weatherstats.csv")

### selecting relevant columns
rain.data <- data %>%
  select(starts_with("avg_cloud_cover") | date | rain)

### change date format to break into year, month and day
rain.data$date <- as.Date(rain.data$date)

rain.data <- rain.data %>%
  mutate(year = as.numeric(format(date, format = "%Y")),
         month = as.numeric(format(date, format = "%m")),
         day = as.numeric(format(date, format = "%d")))

### select data for the last 50 years only
rain.data <- rain.data %>%
  filter(year > 1971)

### save data
write.csv(rain.data,"data/rain_data.csv")
