library(tidyverse)
library(gmailr)
library(jsonlite)

gm_auth_configure(path = "permissions/client_secret.json")

gm_messages()


