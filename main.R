# attach libraries to search path
library(httr)

# read external functions
source("resources/sparql.R")

# define the SPARQL query
data = sparql("resources/query.rq")

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
    stl(s.window = "periodic") |>
    getElement("time.series") |>
    as.data.frame() |>
    subset(select = "trend")
}

# write producer and consumer prices as machine-readable data
write.csv(x = data[,c("date","producerPrice","consumerPrice","producerPriceSmoothed","consumerPriceSmoothed")],
          file = "results/prices.csv",
          row.names = FALSE)

# write producer's share as machine-readable data
write.csv(x = data[,c("date","producerShare","producerShareSmoothed")],
          file = "results/producers-share.csv",
          row.names = FALSE)
