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
