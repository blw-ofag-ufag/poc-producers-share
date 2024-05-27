# A function to return a data frame from a sparql query
sparql <- function(path = NULL) {
  
  # define the SPARQL query
  query <- path |> readLines() |> paste(collapse = "\n")
  
  # make the query
  response <- httr::POST("https://lindas.admin.ch/query",
                         add_headers("Accept" = "text/csv"),
                         content_type("application/x-www-form-urlencoded; charset=UTF-8"),
                         body = list(query = query),
                         encode = "form")
  
  # return warning if query failed
  if(response$status_code >= 300) {
    warning("Query failed")
    return(NULL)
  }
  
  # read and parse the respnose (it's XML)
  result <- response |> httr::content(encoding = "UTF-8")
  
  # convert results to data frame
  data <- as.data.frame(result)
  
  # return data frame
  return(data)
}