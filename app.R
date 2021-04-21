# Library for easily creating web applications https://shiny.rstudio.com/
library(shiny)

# Library for displaying data in a list format. https://rstudio.github.io/DT/
library(DT)

# Collection of libraries for working with data https://www.tidyverse.org/
# We are primarily interested in the dply package https://dplyr.tidyverse.org/
library(tidyverse) 

# the data for the app is in a data frame called adjunct_faculty_sql. It is contained
# in the RData file adjunct_faculty
load(here::here('data', 'adjunct_faculty.RData'))

# the full data set has lots of repeated rows because of email and phone numbers
# here we get rid of all that and just display the courses
adjunct_course <- adjunct_faculty_sql %>% 
  select(spriden_first_name, spriden_last_name, stvterm_desc, 
         ssbsect_subj_code, ssbsect_crse_numb, days,
         ssrmeet_begin_time) %>% 
  unique()


ui <- fluidPage(
  # Here we customize the UI https://shiny.rstudio.com/articles/html-tags.html
  titlePanel("Here is a title"),
  wellPanel(
    h4("Here is an important thing we want to say."),
    p("Here is some text that we can use to explain what this app does.")
    ),
  selectInput(
    'name',
    label = 'Pick name',
    choices = adjunct_faculty_sql$spriden_first_name %>% unique(),
    multiple = TRUE
  ),
  selectInput(
    'term',
    label = 'Pick term',
    choices = adjunct_faculty_sql$stvterm_acyr_code %>% unique(),
    multiple = TRUE
  ),
  DT::dataTableOutput('table')
  
)

server <- function(input, output, session) {
  
  output$table <- DT::renderDataTable(
    
    DT::datatable(
      
      adjunct_faculty_sql %>% 
        filter(spriden_first_name == input$name) %>% 
        filter(stvterm_acyr_code == input$term) %>% 
        select(spriden_first_name, spriden_last_name, stvterm_acyr_code,
               ssbsect_subj_code, ssbsect_crse_numb) %>% 
        unique()
    )
    
  )
  
}

shinyApp(ui, server)

# To Do
# Feel free to ignore these. I just put these in as possible directions to take the app.
# [ ] Column names are messy.
# [ ] Add functionality so the end user can get a phone number and an email
# [ ] Add download functionality ??
# [ ] Style the app with custom CSS, maybe add DSU branding ??