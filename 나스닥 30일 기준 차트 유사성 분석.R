#install.packages("plyr")
#install.packages("plyr")
#install.packages("ggplot2")
#install.packages("ggthemes")
library(dplyr)
library(plyr)
library(ggplot2)
library(ggthemes)
library(readr)

NasDaq_data <- read_csv("NasDaq data.csv")
ND <- NasDaq_data

#Normalization
nor_sd <- function(x){
  result = (x - mean(x)) / sd(x)
  return(result)
}

change_to_numeric<-function(x)
{
  res = as.numeric(substr(x,1,nchar(x)-1))
  return(res)
}

Days = 20
Now <- ND$종가[1:Days] %>% nor_sd()
Res = c()
Date = c()
for(i in Days:(5055-Days))
{
  Last_day = i+Days-1
  #Save Date
  Temp_Day  = paste0(ND$날짜[Last_day]," ~ ", ND$날짜[i])
  Date <- c(Date,Temp_Day)
  #Save Result
  V = ND$종가[i:Last_day] %>% nor_sd()
  if(length(V) != Days) break
  Temp_Matrix <- rbind(Now, V)
  Similarity <- 1-(-1)*as.numeric(dist(Temp_Matrix,method = "euclidean")[1][1])
  ans <- c(Similarity)
  Res = c(Res,ans)
}
Res <- Res %>% as.numeric()
Result <- data.frame(Date,Res)
H_Result = head(arrange(Result,Result$Res),10)
from_to <- Result[Result$Res==min(Res),1]
from <- strsplit(from_to," ~ ")[[1]][1]
to <- strsplit(from_to," ~ ")[[1]][2]
i_from <- which(ND$날짜==from)
i_to <- which(ND$날짜==to)
add_days = 30
Seq <- 1:(Days+add_days)
Data <- ND$종가[Days:1] %>% nor_sd()
Data = c(Data,rep(NA,add_days))
group <- paste0(ND$날짜[Days]," ~ ", ND$날짜[1])
Sim_data <- data.frame(Seq,Data,group)
for(i in 1:5)
{
  from_to <- Result[Result$Res==H_Result$Res[i],1]
  from <- strsplit(from_to," ~ ")[[1]][1]
  to <- strsplit(from_to," ~ ")[[1]][2]
  i_from <- which(ND$날짜==from)
  i_to <- which(ND$날짜==to)
  Data <- ND$종가[i_from:(i_to-add_days)] %>% nor_sd()
  group<- paste0(ND$날짜[i_from]," ~ ", ND$날짜[i_to])
  pdata <- data.frame(Seq,Data,group)
  Sim_data <- rbind(Sim_data,pdata)
}
ggplot(data=Sim_data, aes(x=Seq,y=Data,group=group,color=group))+geom_line()+scale_color_stata()
