
gm_auth_configure(path = "permissions/client_secret.json")

#---- Google scholar alerts

gs_message_list <- gm_messages("from:scholaralerts-noreply@google.com") #identify correct emails

unlist_gs_message <- gs_message_list %>% unlist(., FALSE) %>% unlist(., FALSE) 

num_gs_messages <- length(unlist_gs_message) - 1 #calculate the number of messages obtained

message_gs_ids <- numeric(num_gs_messages) #create vector for message ids

#loop through the list of messages to get the ids
for(x in 1:num_gs_messages){
  
  message_num <- paste0("unlist_gs_message$messages", x, "$id")
  
  id <- eval(parse(text = message_num))
  
  message_gs_ids[x] <- id
}

get_scholar_links <- function(x){

  print(x)  
      
  x <- gm_message(x, format = "full")
  
  x_body <- gm_body(x, format = FULL, type = "text/html") %>% unlist()
  
  x_html <- read_html(x_body)
  
  titles <- x_html %>% xml_find_all('//a[@class="gse_alrt_title"]') %>% html_text() %>% 
    enframe(name = NULL) %>% rename(title = "value")
  
  author <- x_html %>% xml_find_all('//div[@style="color:#006621"]') %>% html_text(trim = TRUE) %>% 
    enframe(name = NULL) %>%   rename(author = "value")
  
  link <- x_html %>% xml_find_all('//a[@class="gse_alrt_title"]') %>% html_attr("href") %>% 
    enframe(name = NULL) %>% rename(url = "value")
  
  #clean_link <- mutate(link, url = str_replace(url, "http://scholar\\.google\\.com/scholar_url\\?url=", "") %>% 
                         #str_extract("[:graph:]+(?=&hl=)"))

  merge_df <- cbind(titles, author, link) #%>% filter(str_detect(url, has_doi) == TRUE)
  
  return(merge_df)
}

all_google_links <- map_dfr(message_gs_ids, get_scholar_links) 

has_doi <- c("/10\\.|sciencedirect|nature.com|arXiv|psycnet.apa|jamanetwork.com|psyarxiv.com|journals.plos.org|europepmc  .org|pnas.org|mdpi.com|jacr.org|neurology.org|edarxiv.org|hindawi.com")

clean_google_links <- mutate(all_google_links, 
                             url = str_replace(url, "http://scholar\\.google\\.com/scholar_url\\?url=", "") %>% 
                               str_extract("[:graph:]+(?=&hl=)")) %>% distinct() %>% 
  filter(str_detect(url, has_doi) == TRUE)

#---- Highwire alerts 

hw_message_list <- gm_messages("from:alerts.highwire")

unlist_hw_message <- hw_message_list %>% unlist(., FALSE) %>% unlist(., FALSE) 

num_hw_messages <- length(unlist_hw_message) - 1 #calculate the number of messages obtained

message_hw_ids <- numeric(num_hw_messages) #create vector for message ids

#loop through the list of messages to get the ids
if (length(message_hw_ids) >= 2) {
  
  print("for")
  
  for(x in 1:num_hw_messages){
    
    message_hw_num <- paste0("unlist_hw_message$messages", x, "$id")
    
    id <- eval(parse(text = message_hw_num))
    
    message_hw_ids[x] <- id
  }
  
} else {
  
  print("1")
  
  message_hw_ids <- unlist_hw_message$messages$id
  
}

get_hw_alerts <- function(x){
  
  print(x)

  x <- gm_message(message_hw_ids[1], format = "full")
  
  x_body <- gm_body(x, format = FULL, type = "text/html") %>% unlist()
  
  x_html <- read_html(x_body)
  
  titles <- x_html %>% xml_find_all('//div[@class="citation_title"]') %>% html_text() %>% 
    enframe(name = NULL) %>% rename(title = "value")
  
  author <- x_html %>% xml_find_all('//div[@id="authorlist"]') %>% html_text(trim = TRUE) %>% 
    enframe(name = NULL) %>%   rename(author = "value")
  
  link <- x_html %>% xml_find_all('//div[@id]/div/a') %>% html_attr("href") %>% 
    enframe(name = NULL) %>% rename(url = "value") %>% filter(str_detect(url, "abstract"))

  merge_df <- cbind(titles, author, link)
  
  return(merge_df)
}

all_hw_links <- map_dfr(message_hw_ids, get_hw_alerts)

#----

relevant <- c("Gender|Academic|Instructor|Discrimination|Inclusion|Equity|Authorship|Graduate|Stem field|Harassment|Women|Female|Decolonizing|Decolonize|Hate|Provider Bias|Implicit Bias")

exclude <- c("Breast|Infection|Diet|Postmenopaus|Childbirth|natal|Abortion|Hiv|Contracept|Supplement|Vaccin|Birth Outcome")

all_links <- rbind(clean_google_links, all_hw_links) %>% 
  mutate(title = str_to_title(title)) %>% 
  filter(str_detect(title, relevant) == TRUE) %>% 
  filter(str_detect(title, exclude) == FALSE)

today <- Sys.Date()

write_csv(all_links, paste0("data/raw", today, ".csv"))

print("csv saved")

#map(gm_delete_message, message_gs_ids)