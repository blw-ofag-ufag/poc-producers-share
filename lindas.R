# attach libraries to search path
library(httr)
library(jsonlite)
library(XML)

# read external functions
source("sparql.R")

# define the SPARQL query
data = sparql("sparql-scrips/query.rq")

# convert `producerPrice` unit
data$producerPrice = data$producerPrice * 0.01

# create a new variabel of `Date` type
data$date <- as.Date(paste(data$year, data$month, "1", sep = "-"))

# sort data by `date`
data <- data[order(data$date),]

# compute the producer's share
data$producerShare <- 100 * data$producerPrice / data$consumerPrice

# compute smoothed versions of all shares (using Seasonal Decomposition of Time Series by Loess)
for (i in c("consumerPrice","producerPrice","producerShare")) {
  data[,paste0(i,"Smoothed")] <- data[,i] |>
    ts(start = 2001, frequency = 12) |>
    stl(s.window = 7) |>
    getElement("time.series") |>
    as.data.frame() |>
    subset(select = "trend")
}

# Produce graphic showing the producer's share
svg("graphics/producer-share.svg", width = 10, height = 6)
par(mar = c(4,4,1,1))
plot(producerShareSmoothed ~ I(year+month/12),
     data, type = "l",
     las = 1, ylab = "Produzentenanteil [%]", xlab = "Zeit", yaxs = "i", xaxs = "i",
     ylim = c(0,100), xlim = c(floor(min(data$year+data$month/12)),ceiling(max(data$year+data$month/12))))
abline(v = seq(2000,2050,5), h = seq(0,100,20), col = "grey")
abline(v = seq(2000,2050,1), h = seq(0,100,4), col = "grey", lwd = 0.5)
lines(producerShare ~ I(year+month/12), data, lwd = 0.5)
lines(producerShareSmoothed ~ I(year+month/12), data, lwd = 2)
dev.off()

# Write producer and consumer prices as machine-readable data
write.csv(data[,c("date","producerPrice","consumerPrice","producerPriceSmoothed","consumerPriceSmoothed")], "data/prices.csv", row.names = FALSE)

# Write data as machine-readable table
write.csv(data[,c("date","producerShare","producerShareSmoothed")], "data/producers-share.csv", row.names = FALSE)
