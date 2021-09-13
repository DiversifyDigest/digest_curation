install.packages("rtweet")

#library(tidyverse)
library(rtweet)
#library(httpuv)

today <- Sys.Date()

#connect twitter API----

options(httr_oauth_cache=T)
digest_token <- create_token(
  app = "digest_links",
  consumer_key = Sys.getenv("api_key"),
  consumer_secret = Sys.getenv("api_secret"),
  access_token = Sys.getenv("access_tok"),
  access_secret = Sys.getenv("access_secret")
)

#source("permissions/twitter_secret_api.R")

#generate and tweet text----

digest_link <- paste0("http://www.diversifydigest.com/digest/digest_", today, "/")


tweet_text_options <- c("A new Diversify Digest is live. #Inclusion #Academia ",
                  "We've got a new Diversify Digest coming your way... #Accessibility #Diversity ",
                  "What's new in #DEI??? See our new Diversify Digest to find out. #AntiRacism #PhDLife ")

select_tweet_text <- sample(tweet_text_options, 1)

#send tweet text----

post_tweet(
  status = paste("Happy ", weekdays(today), "! ", select_tweet_text, digest_link),
  token = digest_token
)
