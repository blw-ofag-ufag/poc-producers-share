# attach libraries to search path
library(httr)
library(jsonlite)
library(XML)

# read external functions
source("sparql.R")

# define the SPARQL query
data = sparql("producer-prices.txt")

# visualize the results
plot(measure  ~ year, data, ylab = "Price [CHF]", xlab = "Year", type = "o")
