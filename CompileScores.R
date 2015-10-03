library(tidyr)
library(dplyr)

# Read scores
scores <- read.csv("scores.csv", stringsAsFactors = FALSE)
scores$Date<- as.Date(scores$Date, format="%d/%m/%Y")
for(i in 2:dim(scores)[2]) { scores[,i]<-as.numeric(scores[,i])}
scores <- scores %>% mutate(GoalDiff=E1_Score-E2_Score)
winner <- function(x) {(x>=0)-(x<=0)}
scores <- scores %>% mutate(winner=winner(GoalDiff)) 

# Read players
joueurs <- read.csv("joueurs.csv", na.strings="", stringsAsFactors = FALSE, fileEncoding="latin1")
joueurs[joueurs=="E1"] <- 1
joueurs[joueurs=="E2"] <- -1
for(i in 2:dim(joueurs)[2]) { joueurs[,i]<-as.numeric(joueurs[,i])}
joueurs$Date<- as.Date(joueurs$Date, format="%d/%m/%Y")

# Basic check scores and players should have the same dates
if(sum(scores$Date!=joueurs$Date)>0)
  print("Mismatch between scores and players")

# Compute Goal differences
timesGD<-function(x) {x*scores$GoalDiff}
goalDiff <- joueurs %>% select(-Date) %>% mutate_each(funs(timesGD))
victories <- sapply(goalDiff, function(x){sum(x>0, na.rm=TRUE)})
defeats <- sapply(goalDiff, function(x){sum(x<0, na.rm=TRUE)})
draws <- sapply(goalDiff, function(x){sum(x==0, na.rm=TRUE)})
played <- victories+defeats+draws

# Compute count of points
givePoints <- function(x) { 3*(x>0)-0*(x<0)+1*(x==0)}
points <- goalDiff %>% mutate_each(funs(givePoints))
points[is.na(points)]<-0
points <- points %>% mutate_each(funs(cumsum))

#Remove NAs and add Date
goalDiff[is.na(goalDiff)] <- 0  
goalDiff <- goalDiff %>% mutate_each(funs(cumsum))
goalDiff[is.na(goalDiff)] <- 0  

maxGD <- max(max(goalDiff),-min(goalDiff))
finalScore <- goalDiff/(10*maxGD) + points

# Build score table
m <- dim(scores)[1] 
scoreTable <- rbind(points[m,],goalDiff[m,],finalScore[m,], victories, defeats, draws, played)
rownames(scoreTable)<-c("Points","GoalDifference","Score", "Victories", "Defeats", "Draws", "Played")
firstnames <- colnames(scoreTable)
view <- as.data.frame(t(scoreTable))
view <- view %>% mutate(pcVic = paste0(format(100*Victories/Played,digits=0),"%"), pcDef = paste0(format(100*Defeats/Played,digits=0),"%"), pcDraws = paste0(format(100*Draws/Played,digits=0),"%"))
rownames(view) <- firstnames
view$Names <- firstnames
view$Rank <- rank(-view$Score,ties.method="min")
view <- view %>% select(Names, Rank, Points, GoalDifference, Played, Victories, pcVic, Defeats, pcDef, Draws, pcDraws) %>% arrange(Rank)

points$Date <- scores$Date
goalDiff$Date <- scores$Date
finalScore$Date <- scores$Date

ncol<- dim(points)[2]
points <- gather(points, "Name","Score", 1:(ncol-1)) 
points$Name <- as.character(points$Name)
goalDiff <- gather(goalDiff, "Name", "GoalDiff", 1:(ncol-1))
goalDiff$Name <- as.character(goalDiff$Name)
finalScore <- gather(finalScore, "Name", "Score", 1:(ncol-1))
finalScore$Name <- as.character(finalScore$Name)
