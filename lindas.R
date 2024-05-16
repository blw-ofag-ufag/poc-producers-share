

# attach libraries to search path
library(httr)
library(jsonlite)
library(XML)

# read external functions
source("sparql.R")

# define the SPARQL query
data = sparql("query-producer-prices.rq")

head(data)

# create a new variabel of `Date` type
data$date <- as.Date(paste(data$year, data$month, "1", sep = "-"))

# sort data by `date`
data <- data[order(data$date),]


plot(measure  ~ date, data, ylab = "Price [CHF]", xlab = "Year", type = "o", pch = 16, cex = 0.8, lwd = 2); grid(col = 1)
