library(plyr)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(readr)
library(ggiraph)
library(DBI)
library(RMySQL)


jusoDB <- dbConnect(
  MySQL(),
  user = "oh",
  password = "714257",
  host = 'ohora.iptime.org',
  dbname = 'StockDB'
)

dbSendQuery(jusoDB, 'set character set "utf8"')

ticker <- dbGetQuery(
  jusoDB,
  "SELECT * FROM TICKERS_MAS tm WHERE tm.IS_MAIN_STOCK =1 ;"
)

TickerList = ticker$Name


#Normalization
nor_sd <- function(x){
  result = (x - mean(x)) / sd(x)
  return(result)
}

qry<- sprintf("SELECT * FROM MAIN_STOCK_20Y_INF A 
Left outer join TICKERS_MAS B 
on A.TICKER = B.Name 
WHERE TICKER = '%s';","AAPL")
ND  <- dbGetQuery(
  jusoDB,qry
)

for(i in 31:(nrow(ND)-30))
{
  print(i)
  print(i+60)
  dt = ND[(i-30):(i+30),]$Close %>% nor_sd()
  print(dt)
  bf = dt[1:30]
  af = dt[31:60]
  bf_dt = data.frame(bf,seq)
  af_dt = data.frame(af,seq)
  bffit = lm(bf~seq,data=bf_dt)
  affit = lm(af~seq,data=af_dt)
  ND[i,"before"] = bffit$coefficients[2]
  ND[i,"after"] = affit$coefficients[2]
  ND[i,"diff"] = bffit$coefficients[2]-affit$coefficients[2]
}

H_Result = head(arrange(ND,ND$diff),30)
most = H_Result[1,]$TDAY
i = which(ND$TDAY==most)
dt = ND[(i-30):(i+30),]$Close %>% nor_sd()
print(dt)
bf = dt[1:30]
af = dt[31:60]
bf_dt = data.frame(bf,seq)
af_dt = data.frame(af,seq)

bffit = lm(bf~seq,data=bf_dt)
affit = lm(af~seq,data=af_dt)

plot(bf~seq, data = bf_dt)
abline(bffit,col="red")

plot(af~seq, data = af_dt)
abline(affit,col="red")
