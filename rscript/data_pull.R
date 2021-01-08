# Libraries ####

library(tidyverse)
library(DBI)
library(here)
library(janitor)

# CONNECTION OBJECT ####
source(here::here('rscript', 'dsu_odbc_connection_object.R'))

adjunct_faculty_sql <- dbGetQuery(con, read_file(here::here('sql', 'adjunct_faculty.sql'))) %>% 
  mutate_if(is.factor, as.character) %>% 
  clean_names() %>% 
  as_tibble()

# csv file to explore the data
write_csv(adjunct_faculty_sql, here::here('data', 'adjunct_faculty_list.csv'))
# RData loads into the app easier
save(adjunct_faculty_sql, file = here::here('data', 'adjunct_faculty.RData'))
