# Load required libraries
library(quanteda)

# Convert the list of titles to a corpus
corpus <- corpus(sapply(all_results, function(x) x$webTitle))

# Perform pre-processing steps (e.g., removing punctuation, lowercasing, removing stop words)
corpus <- corpus %>%
  tokens() %>%
  tokens_tolower() %>%
  tokens_remove(pattern = "[[:punct:]]") %>%
  tokens_select(pattern = "[^\\d]+", selection = "remove") %>%
  tokens_remove(stopwords("en")) %>%
  tokens_remove(pattern = c(",", ":", "'", "``", "''", "’", "‘", "“", "”"))

