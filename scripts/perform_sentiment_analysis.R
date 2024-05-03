# Load necessary libraries
library(syuzhet)

# Perform sentiment analysis for each observation in the corpus
sentiment_scores <- lapply(corpus, function(title) {
  sentiment_score <- get_sentiment(title)
  return(mean(sentiment_score))
})


# Convert sentiment_scores to a dataframe with an ID column
sentiment_score_df <- data.frame(ID = 1:length(sentiment_scores), Sentiment_Score = unlist(sentiment_scores))

# Extract dates from the 'webPublicationDate' field in all_results
all_dates <- unlist(lapply(all_results, function(result) {
  if (!is.null(result[[1]]$webPublicationDate)) {
    substr(result[[1]]$webPublicationDate, 1, 10)
  } else {
    NA  # Assign NA if the 'webPublicationDate' field is missing
  }
}))