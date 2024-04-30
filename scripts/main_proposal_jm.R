library(here)
library(tidyverse)
library(httr)

# Save your API key in a api_credentials.csv file in the folder api_key. The column name the key is stored under must be named api_key. 

# Load the API key and store in a variable

api_key <- read_csv(here("api_key/api_credentials.csv")) %>% 
  pull(api_key)

# Define the URL for the API

guardian_api_base_url <- "https://content.guardianapis.com/search"

# Create wrapper function to get the data from the API

get_guardian_data <- function(api_key, search_term, from_date, to_date, page) {
  
  # Define the parameters for the API call
  
  params <- list(
    "api-key" = api_key,
    "q" = search_term,
    "from-date" = from_date,
    "to-date" = to_date,
    "page" = page
  )
  
  # Make the API call
  
  response <- httr::GET(url = guardian_api_base_url, query = params)
  
  # Check if the API call was successful
  
  if (response$status_code == 200) {
    
    # Parse the response
    
    data <- httr::content(response)
    
    # Extract the relevant information
    
    results <- data$response$results
    
    # Return the results
    
    return(results)
    
  } else {
    
    # If the API call was not successful, print an error message
    
    message("Error: API call failed with status code ", response$status_code)
    
    # Return NULL
    
    return(NULL)
  }
}

# Define the search term, from date, to date, and page number. Test the function.

search_term <- "climate"
from_date <- "2022-01-01"
to_date <- "2022-01-31"
page <- 1

results <- get_guardian_data(api_key, search_term, from_date, to_date, page)

# Extract links from the results an store in a variable

links <- results %>% 
  map_chr("webUrl")

# Print the fetched links

print(links)






