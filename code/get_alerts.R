#authtication settings ----
gm_auth_configure(path = "permissions/client_secret.json")

#gm_auth(cache = "permissions/.secret")

gm_auth(email = TRUE, cache = "permissions/.secret")

#Google scholar alerts----

gs_message_list <- gm_messages(search = "from:scholaralerts-noreply@google.com", num_results = 500) #identify correct emails

unlist_gs_message <- gs_message_list %>% unlist(., FALSE) %>% unlist(., FALSE)

message_gs_ids <- unlist_gs_message %>% 
  as_tibble(.name_repair = "universal", rownames = "NA") %>% 
  gather("message", "id") %>% 
  mutate(id = unlist(id)) %>% 
  filter(str_detect(message, "message") == TRUE) %>% 
  distinct() %>% pull(id)

#function to pull list information from google scholar alerts----
get_scholar_links <- function(x){

  print(x)

  x <- gm_message(x, format = "full")

  x_body <- gm_body(x, format = FULL, type = "text/html") %>% unlist()

  x_html <- read_html(x_body)

  title <- x_html %>% xml_find_all('//a[@class="gse_alrt_title"]') %>% html_text() %>%
    enframe(name = NULL) %>% rename(title = "value")

  author <- x_html %>% xml_find_all('//div[@style="color:#006621"]') %>% html_text(trim = TRUE) %>%
    enframe(name = NULL) %>%   rename(author = "value")

  link <- x_html %>% xml_find_all('//a[@class="gse_alrt_title"]') %>% html_attr("href") %>%
    enframe(name = NULL) %>% rename(url = "value")

  #clean_link <- mutate(link, url = str_replace(url, "http://scholar\\.google\\.com/scholar_url\\?url=", "") %>%
                         #str_extract("[:graph:]+(?=&hl=)"))

  merge_df <- cbind(title, author, link) #%>% filter(str_detect(url, has_doi) == TRUE)

  return(merge_df)
}

#merge and format manuscript data----

all_google_links <- map_dfr(message_gs_ids, get_scholar_links)

has_doi <- c("/10\\.|sciencedirect|nature.com|arXiv|psycnet.apa|jamanetwork.com|psyarxiv.com|journals.plos.org|europepmc  .org|pnas.org|mdpi.com|jacr.org|neurology.org|edarxiv.org|hindawi.com")

if(nrow(all_google_links) != 0){
  clean_google_links <- mutate(all_google_links,
                             url = str_replace(url, "http://scholar\\.google\\.com/scholar_url\\?url=", "") %>%
                               str_extract("[:graph:]+(?=&hl=)")) %>% distinct() %>%
  filter(str_detect(url, has_doi) == TRUE)
}else{
  title <- "empty"
  author <- "empty"
  url <- "empty"
  
  clean_google_links  <- tibble(title, author, url)
  }

#----- Highwire alerts----

hw_message_list <- gm_messages("from:alerts.highwire.org label:Digest_RSS", num_results = 500)

unlist_hw_message <- hw_message_list %>% unlist(., FALSE) %>% unlist(., FALSE) %>% as_tibble(.)

num_hw_messages <- unlist_hw_message$resultSizeEstimate #get the number of messages obtained

#message_hw_ids <- numeric(num_hw_messages) #create vector for message ids

#loop through the list of messages to get the ids
message_hw_ids <- unlist_hw_message %>% 
    as_tibble(.name_repair = "universal", rownames = "NA") %>% 
    gather("message", "id") %>% mutate(id = unlist(id)) %>% 
    filter(str_detect(message, "message") == TRUE) %>% 
    distinct(id) %>% pull(id)

#function to get manuscript data from the highwire alerts
get_hw_alerts <- function(x){

  print(x)

  x <- gm_message(x, format = "full")

  x_body <- gm_body(x, format = FULL, type = "text/html") %>% unlist()

  x_html <- read_html(x_body)

  title <- x_html %>% xml_find_all('//div[@class="citation_title"]') %>% html_text() %>%
    enframe(name = NULL) %>% rename(title = "value")

  author <- x_html %>% xml_find_all('//div[@id="authorlist"]') %>% html_text(trim = TRUE) %>%
    enframe(name = NULL) %>%   rename(author = "value")

  url <- x_html %>% xml_find_all('//div[@id]/div/a') %>% html_attr("href") %>%
    enframe(name = NULL) %>% rename(url = "value") %>% filter(str_detect(url, "abstract"))

  merge_df <- cbind(title, author, url)

  return(merge_df)
}

all_hw_links <- map_dfr(message_hw_ids, get_hw_alerts)

if(nrow(all_hw_links) == 0){
  title <- "empty"
  author <- "empty"
  url <- "empty"
  
  all_hw_links  <- tibble(title, author, url)
}

#attempt to sort relevant ----

exclude <- c("Breast|Infection|Diet|Menopaus|Childbirth|natal|Abortion|Hiv|Contracept|Supplement|Vaccin|Birth Outcome|Pcos|Pregnan|Infertile|Menstrual|Symptom|Spine|Neck|Cardio|Cervial|Cancer|Fetal|Ultrasound|Sonograph|Congenital|Apnea|Cells|Stem Cell|Leukemia|Ovar|Neutron|Neuron|Postpartum")

all_links <- rbind(clean_google_links, all_hw_links) %>%
  mutate(title = str_to_title(title)) %>%
  #filter(str_detect(title, relevant) == TRUE) %>%
  filter(str_detect(title, exclude) == FALSE) #%>% head(n=100)

write_csv(all_links, paste0("data/raw", today, ".csv"))

print("csv saved")

map(message_gs_ids, gm_delete_message)

map(message_hw_ids, gm_delete_message)
