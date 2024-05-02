library(httr)  
library(jsonlite)  
library(sys)     

# Function to fetch article content from The Guardian API based on article ID

fetch_article_content <- function(article_id) {
  api_url <- paste0("https://content.guardianapis.com/", article_id)
  query_params <- list(
    "api-key" = api_key,
    "show-fields" = "body"
  )
  response <- GET(url = api_url, query = query_params)
  if (http_status(response)$category == "Success") {
    article_data <- content(response, "parsed")
    return(article_data$response$content$fields$body)
  } else {
    return(NULL)
  }
}

# List to store fetched article contents

fetched_article_contents <- list()

# Iterate over each article ID in the results list and fetch the article content from the API

for (article_id in sapply(results, '[[', 'id')) {
  article_content <- fetch_article_content(article_id)
  if (!is.null(article_content)) {
    fetched_article_contents[[article_id]] <- article_content
  } else {
    cat("Failed to fetch article content with ID:", article_id, "\n")
  }
  # Add a delay between requests to prevent being banned by the service
  
  Sys.sleep(1) 
}
