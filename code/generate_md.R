library(tidyverse)
library(gmailr)
library(jsonlite)
library(rvest)

today <- Sys.Date()

source("code/get_alerts.R")

rmarkdown::render(input = "code/digest_template.Rmd", output_file = paste0("digest_", today), output_dir = "output")
