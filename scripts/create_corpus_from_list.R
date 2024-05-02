library(quanteda)
library(httr)

# Function to fetch content from a URL
fetch_content <- function(url) {
  response <- httr::GET(url)
  if (response$status_code == 200) {
    return(httr::content(response, as = "text"))
  } else {
    message("Error: Failed to fetch content from URL ", url)
    return(NULL)
  }
}

# Extract webUrls from all_results
links <- unlist(lapply(all_results, `[[`, "webUrl"))

# Fetch content for each link in the list
content_list <- lapply(links, fetch_content)

# Filter out NULL values
content_list <- content_list[!sapply(content_list, is.null)]

# Combine content into a single character vector
content_vector <- unlist(content_list)

# Create a corpus
corpus <- corpus(content_vector, docnames = links)

# Print the first few documents in the corpus
head(corpus)
