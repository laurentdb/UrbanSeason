library(tidyr)
library(dplyr)

# Read scores
scores0 <- read.csv("scoresComplet.csv", na.strings="", stringsAsFactors = FALSE, fileEncoding="UTF-8")
scores0$Date<- as.Date(scores0$Date, format="%d/%m/%Y")

data <- separate(scores0, Score, c("Score_E1","Score_E2"))
data$Score_E1 <- as.numeric(data$Score_E1)
data$Score_E2 <- as.numeric(data$Score_E2)
data <- separate(data, Equipe1, paste0("E1_J",1:5),sep="[ ]+")
data <- separate(data, Equipe2, paste0("E2_J",1:5),sep="[ ]+")

data <- data %>% mutate(goalDiff=Score_E1-Score_E2)
data <- tidyr::gather(data, Team, Name, 4:13 ) 
data$Team <- gsub("_J.","", data$Team)

data$GoalAvg <- (data$Score_E1-data$Score_E2)*(1*(data$Team=="E1")-1*(data$Team=="E2"))
data <- data %>% mutate(Win = 1*(GoalAvg>0), Def = 1*(GoalAvg<0), Draw = 1*(GoalAvg==0), Points = 3*Win+Draw)

summary <- data %>% group_by(Name) %>% arrange(Date) %>% mutate(TotalPoints=cumsum(Points), TotalGoal =cumsum(GoalAvg), TotalWin = cumsum(Win), TotalDef = cumsum(Def), TotalDraw = cumsum(Draw), TotalPlayed =TotalWin+TotalDef+TotalDraw)
maxGD <- max(max(summary$TotalGoal),-min(summary$TotalGoal))
summary <- summary %>% mutate(FinalScore=TotalPoints+TotalGoal/(10*maxGD))

view <- summary %>% filter(Date==max(Date)) %>% ungroup %>% mutate(Rank = rank(-FinalScore,ties.method="min")) %>% 
  select(Rank, Name, Points=TotalPoints, GoalAverage = TotalGoal, FinalScore, Win = TotalWin, Draw = TotalDraw, Lose = TotalDef, Played = TotalPlayed) %>%
  mutate(pcWin = paste0(format(100*Win/Played,digits=0),"%"), pcLose = paste0(format(100*Lose/Played,digits=0),"%"), pcDraw = paste0(format(100*Draw/Played,digits=0),"%")) %>%
  select(Rank, Name, Points, GoalAverage, FinalScore, Played, Win, pcWin, Draw, pcDraw, Lose, pcLose) %>% 
  arrange(Rank)


