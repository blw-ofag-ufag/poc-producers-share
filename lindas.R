
# attach libraries to search path
library(httr)
library(jsonlite)
library(XML)

# read external functions
source("sparql.R")

# define the SPARQL query
data = sparql("query.rq")

# convert `producerPrice` unit
data$producerPrice = data$producerPrice * 0.01

# create a new variabel of `Date` type
data$date <- as.Date(paste(data$year, data$month, "1", sep = "-"))

# sort data by `date`
data <- data[order(data$date),]

# visualize the results
plot(consumerPrice  ~ date, data, ylab = "Price [CHF]", xlab = "Year", type = "l", lwd = 2, ylim = c(0,2))
grid(col = 1)
lines(producerPrice ~ date, data, col = "red", lwd = 2)
plot(producerPrice/consumerPrice ~ date, data, lwd = 2, lty = 1, type = "l", ylim = c(0,1))
