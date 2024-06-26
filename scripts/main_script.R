#### Setup ####

library(here)
library(tidyverse)
library(httr)
library(rvest)
library(httr2)

my_email <- "add_your_email_here" #To be polite

# Choose the Version whiche suites you the best :)!


####  Setup API Key - Version 1 ####

# First check your working directory

getwd()

# 1. Create there a File (in Windows with the Windows-Editor)

# 2. Write on the first line without any space Key=Your_Key 
  # Note: Your_Key is the Key you got from the Guardians-API

# Important: Call the file .Renviron it is already in the gitignore-file
# Note: When you save the file check that you change the Data-Type

# 3. Restart your R-Session (Session/Restart R)

# 4. Use this Code to read in your Key - It should appear in the Global Environment

api_key <- Sys.getenv(x= "Key")

####  Setup API Key - Version 2 ####

# Proposal of API key system and wrapper function to fetch data from the Guardian API.

# Save your API key in a api_credentials.csv file in the folder api_key. The column name the key is stored under must be named api_key. 

# Load the API key and store in a variable

api_key <- read_csv(here("api_key/api_credentials.csv")) %>% 
  pull(api_key)

####  Setup API Key - Version 3 ####

api_key <- rstudioapi::askForPassword()

#### Get the links which are used ####

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
  
  response <- httr::GET(url = guardian_api_base_url, query = params, 
                        add_headers(From = my_email,
                                    `User-Agent` = R.Version()$version.string))

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

search_term <- "assange"
from_date <- "2014-01-01"
to_date <- "2023-12-31"

all_results <- list()
page <- 1

while (TRUE) {
  results <- get_guardian_data(api_key, search_term, from_date, to_date, page)
  if (is.null(results) || length(results) == 0) {
    break
  }
  all_results <- c(all_results, results)
  page <- page + 1
}

# Extract links from all_results and store in a variable
links <- all_results %>% 
  map_chr("apiUrl")

# Print the fetched links
print(links)


#### Try to get the html text of the articles ####

results <- list()

for (i in seq_along(links)) {
  
  # To be a little polite
  Sys.sleep(1) 
  
  # access the links with the articles  
  r <- httr::GET(url = links[i], query = list("show-blocks" = "all", "api-key" = api_key),
                 add_headers(From = my_email,
                             `User-Agent` = R.Version()$version.string)
  )
  
  if (r$status_code == 200) {
    
    # Parse the response
    html_content <- httr::content(r, as = "text")
    html_parsed <- read_html(html_content)
    paragraphs <- html_nodes(html_parsed, "p")
    
    # Extract text from paragraphs
    text <- html_text(paragraphs)
    
    # Append to results list
    results[[i]] <- text
    
  } else {
    # If the API call was not successful, print an error message
    message("Error: API call failed with status code ", r$status_code)
  }
}

# Combine results into a single character vector

all_text <- list()

all_text <- unlist(results)

# Cleaning the Responses

pattern <- ('^\\{"response')

clean_text = all_text[which(str_detect(all_text, pattern) == FALSE)]

#### Create an Work with the Corpus ####

# Create a corpus
corpus <- quanteda::corpus(clean_text)

# View the corpus
View(corpus)

