library(tidyverse)

today <- Sys.Date()

#Prep digest text for tweets----

recent_digest <- read_file(paste0("output/digest_", today, ".md")) %>% 
  str_split(., "\\[") %>% unlist() %>% str_replace_all(., "##.*", "") %>% 
  as_tibble() %>% separate(value, into = c("title", "urlplus"), sep = "\\]") %>% 
  separate(urlplus, into = c("url", "extra"), sep = "\\)") %>% 
  mutate(url = map2(.x = url, .y = "\\(https://scholar.google.com/scholar_url\\?url=", .f = str_remove_all),
         url = unlist(url),
         title = map(title, function(x){str_replace_all(x, "\\\n", " ")}),
         title = unlist(title),
         for_twitter = paste(title, " ", url))%>% 
  slice(-1, -2)

articles <- recent_digest[sample(nrow(recent_digest), 10), ]

#tweet_list <- articles %>% select(for_twitter)

write_csv(articles, "data/recent_twitter_links.csv") #save recent links to a file