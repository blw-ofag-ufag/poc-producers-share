
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


TS = ts(data[,c("consumerPrice","producerPrice")], start = 2001, frequency = 12)
D = decompose(TS)
r = (D$trend[,2]/D$trend[,1])*100

# SMOOTHED PRODUCER'S SHARE
par(mar = c(4,4,1,1))
plot(r, ylim = c(0,100), las = 1, ylab = "Produzentenanteil [%]", xlab = "Zeit", yaxs = "i",
     xlim = c(floor(min(time(r))),ceiling(max(time(r)))))
abline(v = seq(2000,2050,5), h = seq(0,100,20), col = "grey")
abline(v = seq(2000,2050,1), h = seq(0,100,4), col = "grey", lwd = 0.5)
lines(100*TS[,2]/TS[,1], lwd = 0.5)
lines(r, lwd = 2)
