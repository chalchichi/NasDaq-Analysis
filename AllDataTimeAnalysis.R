#install.packages("plyr")
#install.packages("plyr")
#install.packages("ggplot2")
#install.packages("ggthemes")
#install.packages("RMySQL")

#install.packages("DBI")

library(dplyr)
library(plyr)
library(ggplot2)
library(ggthemes)
library(readr)
library(ggiraph)
library(DBI)
library(RMySQL)

args = commandArgs(trailingOnly=TRUE)
Target_end_date  <- args[1]
Days <- as.numeric(args[2])
add_days <- as.numeric(args[3])
limitcount <- as.numeric(args[4])
email <- args[5]
mysqluser <- args[6]
mysqlpassword <- args[7]



jusoDB <- dbConnect(
  MySQL(),
  user = mysqluser,
  password = mysqlpassword,
  host = "127.0.0.1",
  dbname = 'StockDB'
)

dbSendQuery(jusoDB, 'set character set "utf8"')

ticker <- dbGetQuery(
  jusoDB,
  "SELECT * FROM TICKERS_MAS tm WHERE tm.IS_MAIN_STOCK =1 ;"
)

print(Target_end_date)
print(Days)
print(add_days)
print(limitcount)
Dataurl = paste0("~/RProject/NasDaq-Analysis/",email,".csv")
TargetData <- read_csv(Dataurl)

Days <- nrow(TargetData)

TickerList = ticker$Name
               
#Normalization
nor_sd <- function(x){
  result = (x - mean(x)) / sd(x)
  return(result)
}

Now <- TargetData$CLOSE %>% nor_sd()

for(t in 1:length(TickerList))
{
  ticker = TickerList[t]
  print(ticker)
  qry<- sprintf("SELECT * FROM MAIN_STOCK_20Y_INF A 
Left outer join TICKERS_MAS B 
on A.TICKER = B.Name 
WHERE TICKER = '%s' AND A.TDAY < '%s' ;",ticker,TargetData$TDAY[1])
  ND  <- dbGetQuery(
    jusoDB,qry
  )
  Res=c()
  start_days=c()
  end_days=c()
  for(i in 1:nrow(ND))
  {
    Last_day = i+Days-1
    #Save Date
    start_day = ND$TDAY[i]
    end_Day  = ND$TDAY[Last_day]
    start_days <- c(start_days,start_day)
    end_days <- c(end_days,end_Day)
    
    #Save Result
    V = ND$Close[i:Last_day] %>% nor_sd()
    
    if(length(V) != Days) print(V)
    
    Temp_Matrix <- rbind(Now, V)
    Similarity <- 1-(-1)*as.numeric(dist(Temp_Matrix,method = "euclidean")[1][1])
    ans <- c(Similarity)
    Res = c(Res,ans)
  }
  
  COMPANY_NAME = rep(ND$COMPANY_NAME[1],length(Res))
  Ticker = rep(ND$TICKER[1],length(Res))
  if(t==1)
  {
    ResDT <- data.frame(start_days,end_days,COMPANY_NAME,Res,Ticker)
  }
  else
  {
    newdt <-data.frame(start_days,end_days,COMPANY_NAME,Res,Ticker)
    ResDT <- rbind(ResDT,newdt)
  }
}

H_Result = head(arrange(ResDT,ResDT$Res),limitcount)
grp=c()
for(i in 1:nrow(H_Result))
{
  grp[i] = paste0(H_Result$start_days[i]," ~ ",H_Result$end_days[i]," (",H_Result$COMPANY_NAME[i],")")
}
H_Result[,"group"] = grp

H_Result$end_days = as.Date(H_Result$end_days)+add_days
H_Result = H_Result[1:nrow(H_Result),]

Targetgrp  = paste0(TargetData$TDAY[1]," ~ ",TargetData$TDAY[nrow(TargetData)]," (Target)")

TargetDT <- TargetData$CLOSE %>% nor_sd()

Sim_data=data.frame(Seq=1:nrow(TargetData),Data=TargetDT, group = rep(Targetgrp,nrow(TargetData)),TargetDate = TargetData$TDAY)

for(i in 1:nrow(H_Result))
{ 
  qry <- sprintf("SELECT TDAY AS TargetDate , Close AS Data FROM MAIN_STOCK_20Y_INF WHERE TICKER = '%s' and TDAY BETWEEN '%s' AND '%s';",H_Result$Ticker[i], H_Result$start_days[i], H_Result$end_days[i])
  DT  <- dbGetQuery(
    jusoDB,qry
  )
  data = DT$Data %>% nor_sd()
  DT[,"group"] = rep(H_Result$group[i],nrow(DT))
  DT[,"Seq"] = 1:nrow(DT)
  DT[,"Data"] = data
  
  Sim_data = rbind(Sim_data,DT)
}

tooltip <- c()
for(i in 1:nrow(Sim_data))
{
  tooltip[i] = paste0(Sim_data$group[i],"\n","value: ",Sim_data$Data[i])
}

Simdata <- cbind(Sim_data,tooltip)
Sim_data <- transform(Sim_data,
                      group = factor(group, levels = c(paste0(TargetData$TDAY[1]," ~ ",TargetData$TDAY[nrow(TargetData)]," (Target)"),H_Result$group)))

gg <- ggplot(Sim_data, aes(x = Seq, y = Data, 
                           colour = group, group = group , label = group)) +ggtitle(TargetData$NAME[1]) +
  geom_line_interactive(aes(tooltip = tooltip, data_id = group)) +
  geom_point_interactive(aes(tooltip = TargetDate, data_id = group),size=1)

x <- girafe(ggobj = gg, width_svg = 10, height_svg = 4,
            options = list(
              opts_hover_inv(css = "opacity:0.1;"),
              opts_hover(css = "stroke-width:2;")
            ))
url = paste0("/Users/ohyunhu/RProject/NasDaq-Analysis/myplot_",email,".html")
htmltools::save_html(x,url)
