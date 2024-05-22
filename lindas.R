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

# compute smoothed versions of all shares
data |>
  subset(select = c("consumerPrice","producerPrice","producerShare")) |>
  ts(start = 2001, frequency = 12) |>
  decompose() |>
  getElement("trend") |>
  as.data.frame() -> trend
names(trend) <- paste0(c("consumerPrice","producerPrice","producerShare"), "Smoothed")
data <- cbind(data, trend)

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

# Write data as machine-readable table
write.csv(data, "data/producers-share.csv", row.names = FALSE)
