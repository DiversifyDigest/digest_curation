library(tidyverse)
library(rtweet)
library(httpuv)

twitter_links <- read_csv("data/recent_twitter_links.csv")

link_num <- nrow(twitter_links)

text_num <- sample(link_num, 1)

tweet_text <- twitter_links[text_num,4][[1]]

#connect twitter API----

options(httr_oauth_cache=T)
digest_token <- create_token(
  app = "digest_links",
  consumer_key = Sys.getenv("api_key"),
  consumer_secret = Sys.getenv("api_secret"),
  access_token = Sys.getenv("access_tok"),
  access_secret = Sys.getenv("access_secret")
)

post_tweet(
  status = tweet_text,
  token = digest_token
)

new_twitter_links <- twitter_links %>% slice(-text_num)

write_csv(new_twitter_links, "data/recent_twitter_links.csv") #save recent links to a file