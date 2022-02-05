library(readr)
library(dplyr)
library(plyr)
library(RMySQL)

server <- function(input, output, session) {
  all_cons <- dbListConnections(MySQL())
  
  print(all_cons)
  
  for(con in all_cons)
    +  dbDisconnect(con)
  
  print(paste(length(all_cons), " connections killed."))
  
  output$urlText <- renderText({
    paste(sep = "",
          "protocol: ", session$clientData$url_protocol, "\n",
          "hostname: ", session$clientData$url_hostname, "\n",
          "pathname: ", session$clientData$url_pathname, "\n",
          "port: ",     session$clientData$url_port,     "\n",
          "search: ",   session$clientData$url_search,   "\n"
    )
  })
  
  # Parse the GET query string
  output$queryText <- renderText({
    query <- parseQueryString(session$clientData$url_search)
    
    # Return a string with key-value pairs
    paste(names(query), query, sep = "=", collapse=", ")
  })
  
  output$Title <- renderText({
    query <- parseQueryString(session$clientData$url_search)
    
    # Return a string with key-value pairs
    if(is.null(query$ticker)) ticker <- 'NASDAQ'
    else ticker <- query$ticker
    ticker
  })
  
  jusoDB <- dbConnect(
    MySQL(),
    user = 'oh',
    password = '714257',
    host = '127.0.0.1',
    dbname = 'StockDB'
  )
  dbSendQuery(jusoDB, 'set character set "utf8"')

  output$mytable = DT::renderDataTable({
    query <- parseQueryString(session$clientData$url_search)
    print(query$ticker)
    if(is.null(query$ticker)) ticker = 'NASDAQ'
    else ticker = query$ticker
    sql = paste0("SELECT * FROM ",ticker," Order by TDAY DESC;")
    print(sql)
    ND <- dbGetQuery(
      jusoDB,sql
      
    )
    ND
  })
}