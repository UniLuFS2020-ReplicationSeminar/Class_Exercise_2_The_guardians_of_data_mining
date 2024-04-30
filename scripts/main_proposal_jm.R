library(here)
library(tidyverse)
library(httr)

# Save your API key in a api_credentials.csv file in the folder api_key. 

# Load the API key and store in a variable

api_key <- read_csv(here("api_key/api_credentials.csv")) %>% 
  pull(api_key)
