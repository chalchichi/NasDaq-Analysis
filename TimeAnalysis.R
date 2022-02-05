#install.packages("plyr")
#install.packages("plyr")
#install.packages("ggplot2")
#install.packages("ggthemes")
#install.packages("RMySQL")
library(dplyr)
library(plyr)
library(ggplot2)
library(ggthemes)
library(readr)
library(ggiraph)


args = commandArgs(trailingOnly=TRUE)
Target_end_date  <- args[1]
Days <- as.numeric(args[2])
add_days <- as.numeric(args[3])
limitcount <- as.numeric(args[4])


#Target_end_date  <- "2022-05-17"
#Days <- 46
#add_days <- 10
#limitcount <- 10

print(Target_end_date)
print(Days)
print(add_days)
print(limitcount)

NasDaq_data <- read_csv("~/RProject/NasDaq-Analysis/TEMP.csv")
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



TARGET_END_DATE_INDEX=as.numeric(which(ND$TDAY==Target_end_date))
TARGET_START_DATE_INDEX=(TARGET_END_DATE_INDEX+Days-1)
Now <- ND$CLOSE[TARGET_END_DATE_INDEX:TARGET_START_DATE_INDEX] %>% nor_sd()
Res = c()
Date = c()
for(i in 1:nrow(ND))
{
  Last_day = i+Days-1
  #Save Date
  Temp_Day  = paste0(ND$TDAY[Last_day]," ~ ", ND$TDAY[i])
  Date <- c(Date,Temp_Day)
  #Save Result
  V = ND$CLOSE[i:Last_day] %>% nor_sd()
  if(length(V) != Days) break
  Temp_Matrix <- rbind(Now, V)
  Similarity <- 1-(-1)*as.numeric(dist(Temp_Matrix,method = "euclidean")[1][1])
  ans <- c(Similarity)
  Res = c(Res,ans)
}

Res <- Res %>% as.numeric()
Result <- data.frame(Date,Res)
H_Result = head(arrange(Result,Result$Res),limitcount)
from_to <- H_Result$Date[1]
from <- strsplit(from_to," ~ ")[[1]][1]
to <- strsplit(from_to," ~ ")[[1]][2]
i_from <- which(ND$TDAY==from)
i_to <- which(ND$TDAY==to)

Seq <- 1:(Days+add_days)
Data <- ND$CLOSE[TARGET_START_DATE_INDEX:TARGET_END_DATE_INDEX] %>% nor_sd()
Data = c(Data,rep(NA,add_days))
group <- paste0(ND$TDAY[TARGET_START_DATE_INDEX]," ~ ", ND$TDAY[TARGET_END_DATE_INDEX]," (TARGET)")
Sim_data <- data.frame(Seq,Data,group)

mostsimilaritydata_from = c()
mostsimilaritydata_to = c()
for(i in 2:limitcount)
{
  from_to <- H_Result$Date[i]
  from <- strsplit(from_to," ~ ")[[1]][1]
  to <- strsplit(from_to," ~ ")[[1]][2]
  i_from <- which(ND$TDAY==from)
  i_to <- which(ND$TDAY==to)
  if((i_to-add_days)<1) next;
  Data <- ND$CLOSE[i_from:(i_to-add_days)] %>% nor_sd()
  group<- paste0(ND$TDAY[i_from]," ~ ", ND$TDAY[i_to])
  mostsimilaritydata_from[length(mostsimilaritydata_from)+1]=from
  mostsimilaritydata_to[length(mostsimilaritydata_to)+1]=to
  pdata <- data.frame(Seq,Data,group)
  Sim_data <- rbind(Sim_data,pdata)
}
mostsim_data <- data.frame(mostsimilaritydata_from,mostsimilaritydata_to)
for(i in 1:nrow(mostsim_data))
{
  print(paste0(mostsim_data$mostsimilaritydata_from[i],",",mostsim_data$mostsimilaritydata_to[i]))
}


gg <- ggplot(Sim_data, aes(x = Seq, y = Data, 
                           colour = group, group = group)) +
  geom_line_interactive(aes(tooltip = group, data_id = group)) +
  scale_color_viridis_d() + 
  labs(title = ND$NAME[1])

x <- girafe(ggobj = gg, width_svg = 10, height_svg = 4,
            options = list(
              opts_hover_inv(css = "opacity:0.1;"),
              opts_hover(css = "stroke-width:2;")
            ))

htmltools::save_html(x, "/Users/ohyunhu/RProject/NasDaq-Analysis/myplot.html")
