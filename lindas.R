# Attach libraries to search path
library(httr)
library(jsonlite)
library(XML)

# Define the SPARQL query
query <- "
SELECT * WHERE {
    ?s ?p ?o.
}
LIMIT 5
"

# Make the query
response <- POST("https://lindas.admin.ch/query",
                 body = list(query = query),
                 encode = "form")


# Read the respnose (it's XML)
result = content(response, "text")

xmlToList(result)
