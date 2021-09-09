library(tidyverse)
library(gmailr)
library(jsonlite)
library(rvest)
library(xml2)

args <- commandArgs()

#print(args) #ensure correct arg selection

today <- args[6]

source("code/get_alerts.R")

rmarkdown::render(input = "code/digest_template.Rmd", 
                  output_file = paste0("digest_", today), 
                  output_dir = "output")

text_msg <- gm_mime() %>%
  gm_to("akhagan@alliancescc.com") %>%
  gm_from("akhagan@alliancescc.com") %>%
  gm_text_body(paste0(today, " digest markdown is ready to view."))


gm_send_message(text_msg)
