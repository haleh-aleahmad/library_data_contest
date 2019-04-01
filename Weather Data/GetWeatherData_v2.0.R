########################################################
#                       ABSTRACT                       #
########################################################
# AUTHOR:
# Haleh

# DATE CREATED:
# 2018.05.30
# DATE MODIFIED:
# 2019.03.26
# Modified with the new format and for city of Evanston

# PURPOSE:
# Retrieve weather data from "https://www.wunderground.com/" for specific airport and period of time

# USER SPECIFCS:
# set the directory
# Dates
# The link of historical observations
    
########################################################
#                     PACKAGES                         #
########################################################
library(lubridate)
library(jsonlite)

# install.packages('jsonlite')

########################################################
#                     USER SPECIFICS                   #
########################################################
startDate <- date("2015-01-01")
endDate <- date("2019-03-26")

########################################################
#                     INITIALIZE                       #
########################################################
weatherData <- NULL
weatherData_daily <- NULL

########################################################
#                   HOURLY WEATHER DATA                #
########################################################
myDates <- seq(startDate, endDate, by = "day")
i <- 1

for (i in seq_along(myDates)){
    # Progress message
    if (i %% 100 == 0){
      print(paste("Reading data for day", i, "out of", length(myDates)))
    }
 
    thisDate <- myDates[i]
    
    # Read URL
    myURL <- paste0("https://api.weather.com/v1/geocode/41.98/-87.91/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=",
                    year(thisDate), sprintf("%02d", month(thisDate)), sprintf("%02d", day(thisDate)),
                    "&endDate=",
                    year(thisDate), sprintf("%02d", month(thisDate)), sprintf("%02d", day(thisDate)),
                    "&units=e") 
    weatherData<- rbind(weatherData, fromJSON(myURL)[[2]])
}

weatherData$expire_time_gmt_timestamp <- as.POSIXct(weatherData$expire_time_gmt, origin = "1970-01-01", tz = 'GMT')
weatherData$valid_time_gmt_timestamp <- as.POSIXct(weatherData$valid_time_gmt, origin = "1970-01-01", tz = 'GMT')

weatherData$valid_time_CT <- with_tz(weatherData$valid_time_gmt_timestamp, tz = 'America/Chicago')

########################################################
#                       OUTPUT                         #
########################################################
fName <- paste0("Evanston Weather Data (", startDate, " - ", endDate, ").Rdata")
fPath <- file.path("./Data/", fName)
save(weatherData, file = fPath)

# csv files
fName <- paste0("Evanston Weather Data (", startDate, " - ", endDate, ").csv")
fPath <- file.path("../", fName)
write.csv(weatherData, fPath, row.names = FALSE)


########################################################
#                     DAILY AVERAGE                    #
########################################################

load('../Data/Evanston Weather Data (2015-01-01 - 2019-03-26).Rdata')
