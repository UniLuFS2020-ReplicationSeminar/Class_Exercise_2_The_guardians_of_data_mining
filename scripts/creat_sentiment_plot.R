#### Calculate Sentiment-Scores: ####

library(quanteda)
library(httr)
library(tidytext)
library(dplyr)
library(jsonlite)
library(rvest)


getwd()

scraped_data<- read_json("content_list.json")

titles <- list()
dates <- list()


for (i in 1:length(scraped_data)) {
  
  html_parsed <- read_html(unlist(scraped_data[i]))
  
  text <- html_element(html_parsed, css = ".dcr-iy9ec7") %>%
    html_text()
  
  titles[i] <- unlist(text)
  dates[i] <- stringr::str_extract(unlist(scraped_data[i]), "\\d{4}-\\d{2}-\\d{2}")
  print(i)
  
}

dates
#First install "textdata" as a package install.package("textdata")

afinn <- get_sentiments("afinn")

afinn_sentiment <- dictionary(list(positive = str_trim(afinn$word[afinn$value>0]),
                                   negative = str_trim(afinn$word[afinn$value<0]
                                   )))

# Use the afinn dictonary to calculed the sentiment-score

corpus_sentiment <- quanteda::corpus(unlist(titles)) %>%
  tokens() %>%
  dfm()

dfm_sentiment <- dfm(corpus_sentiment, dictionary = afinn_sentiment)

dmf_sentiment_prop <- dfm_weight(dfm_sentiment, scheme = "prop")

sentiment_all <- convert(dmf_sentiment_prop, "data.frame") %>%
  gather(positive, negative, key = "Polarität", value = "Wörter") %>% 
  mutate(doc_id = as_factor(doc_id))

sentiment_prop_all <- dfm_weight(dfm_sentiment, scheme = "prop") %>% 
  convert("data.frame") %>%
  mutate(Datum = unlist(dates)) %>%
  gather(positive, negative, key = "Polarität", value = "Sentiment")

# no zeros

sentiment_prob_no_zero <- sentiment_prop_all %>%
  filter(Sentiment != 0) 

sentiment_prob_no_zero$Sentiment <- ifelse(sentiment_prob_no_zero$Polarität == "negative", 
                                           sentiment.prop_all$Sentiment *(- 1), 
                                           sentiment.prop_all$Sentiment)

sentiment_prob_no_zero$Datum <- as.Date(sentiment_prob_no_zero$Datum)

sentiment_prob_strong <- sentiment_prob_no_zero %>%
  filter(Sentiment != 0) %>%
  filter(Sentiment >= 0.1 | Sentiment <= -0.1)



ggplot(sentiment_prob_no_zero, aes(Datum, Sentiment)) + 
  geom_point(size = 1) + 
  geom_hline(yintercept = 0, linetype = "dashed", color = "lightgray") + 
  scale_colour_brewer(palette = "Set1") + 
  scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
  ggtitle("sentiment-scores titles over time") + 
  xlab("month") +
  geom_smooth()

# 

ggplot(sentiment_prob_strong, aes(Datum, Sentiment)) + 
  geom_point(size = 1) + 
  geom_hline(yintercept = 0, linetype = "dashed", color = "lightgray") + 
  scale_colour_brewer(palette = "Set1") + 
  scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
  ggtitle("sentiment-scores titles over time 'only stronger values")  +
  xlab("month") +
  geom_smooth()

