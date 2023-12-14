# Attach libraries to search path
library(httr)
library(jsonlite)
library(XML)

# Define the SPARQL query
query <- "
SELECT * WHERE {
    ?s ?p ?o.
}
LIMIT 2
"

# Make the query
response <- POST("https://lindas.admin.ch/query",
                 body = list(query = query),
                 encode = "form")


# Read the respnose (it's XML)
result = content(response, "text", encoding = "UTF-8")

# Funtion to retrieve the name from an URI
getName <- function(URI){
  URI <- paste0(URI, "?format=jsonld")
  URI |> httr::GET() |>
    content(type = "text", encoding = "UTF-8") |>
    jsonlite::fromJSON() -> x
  x[["@graph"]][["@graph"]][[1]][["http://schema.org/name"]] |> unname() |> unlist()
}

# Try to run the function
getName("https://lod.opentransportdata.swiss/didok/8505592")
