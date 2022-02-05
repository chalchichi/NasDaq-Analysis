library(dplyr)
library(plyr)

ui <- basicPage(
  h2(textOutput("Title")),
  DT::dataTableOutput("mytable"),
    verbatimTextOutput("urlText"),
    verbatimTextOutput("queryText")
)