# A function to return a data frame from a sparql query
sparql <- function(path = NULL) {
  
  # define the SPARQL query
  query <- path |> readLines() |> paste(collapse = "\n")
  
  # make the query
  response <- POST("https://lindas.admin.ch/query",
                   add_headers("Accept" = "text/csv"),
                   content_type("application/x-www-form-urlencoded; charset=UTF-8"),
                   body = list(query = query),
                   encode = "form")
  
  # read and parse the respnose (it's XML)
  result <- response |> content(encoding = "UTF-8")
  
  # convert results to data frame
  data <- as.data.frame(result)
  
  # return data frame
  return(data)
}