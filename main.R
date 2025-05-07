# attach libraries to search path
library(httr)

# define sparql query
sparql <- readLines("resources/query.rq") |>
  paste(collapse = "\n")

# make the http request
query <- POST("https://ld.admin.ch/query",
              add_headers("Accept" = "text/csv"),
              content_type("application/x-www-form-urlencoded; charset=UTF-8"),
              body = paste("query=", sparql, sep = ""))

# parse the result
data <- content(query, encoding = "UTF-8")

# convert to data frame
data <- as.data.frame(data)

# convert to data frame date type
data$date <- as.Date(data$date)

# compute the producer's share
data$producerShare <- 100 * data$producerPrice / data$consumerPrice

# compute smoothed versions of all shares (using Seasonal Decomposition of Time Series by Loess)
for (i in c("consumerPrice","producerPrice","producerShare")) {
  data[,paste0(i,"Smoothed")] <- data[,i] |>
    ts(start = 2001, frequency = 12) |>
    stl(s.window = 11) |> # s.window is the window size used to estimate the seasonal component. If it's not "periodic", the seasonal component is allowed to change over time
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
