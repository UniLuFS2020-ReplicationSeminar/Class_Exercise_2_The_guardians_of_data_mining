# Load required libraries

library(httr)
library(jsonlite)

# Function to fetch article content by API URL

fetch_article_content <- function(api_url, api_key) {
 
   # Construct URL for fetching article content
  
  url <- paste0(api_url, "?api-key=", api_key, "&show-fields=bodyText")
  
  # Make GET request to fetch article content
  
  response <- GET(url)
  
  # Check if request was successful
  
  if (http_type(response) == "application/json") {
   
     # Parse JSON response
    
    article_content <- content(response, as = "text", encoding = "UTF-8")
    article_content <- fromJSON(article_content, flatten = TRUE)
    
    # Extract the text content of the article
    
    article_text <- article_content$response$content$fields$bodyText
    
    # Return the text content
    
    return(article_text)
  } else {
    
    # Return NULL if request failed
    
    return(NULL)
  }
}

# Loop through each article in all_results and fetch its content

article_texts <- vector("list", length(all_results))
for (i in seq_along(all_results)) {
  
  # Fetch article content
  
  api_url <- all_results[[i]]$apiUrl
  article_text <- fetch_article_content(api_url, api_key)
  
  # Store the text content in the list
  
  article_texts[[i]] <- article_text
}


